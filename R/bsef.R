#' Get Bloomberg SEF data
#'
#' The Bloomberg Swap Execution Facility (SEF) offers customers the ability to
#' execute derivative instruments across a number of different asset classes. It
#' is required to make publicly available price, trading volume and other trading
#' data. It publishes this data on its website. I have reverse engineered the
#' JavaScript libraries used by its website to call the Bloomberg Application
#' Service using \code{POST} requests to a target URL.
#'
#' @param date the date for which data is required as Date or DateTime
#' object. Only the year, month and day elements of the object are used.
#' @param asset_class the derivatives asset class for which data is required.
#' Must be one of the following (case-invariant): \code{'CR'} (credit),
#' \code{'EQ'} (equity), \code{'FX'} (foreign exchange), \code{'IR'} (interest
#' rates), \code{'CO'} (commodities).
#' @return a data frame containing the requested data, or if no data is available,
#' \code{NULL}.
#' @importFrom assertthat assert_that
#' @importFrom dplyr %>%
#' @export

get_bsef_data <- function (date, asset_class)
{
  # Process and check argument values
  asset_class <- toupper(asset_class)
  assert_that(asset_class %in% c('CR', 'EQ', 'FX', 'IR', 'CO'))
  download_bsef_data_single(date, asset_class) %>% format_bsef_data(.)
}

#' @importFrom httr POST
#' @importFrom jsonlite fromJSON
download_bsef_data_single <- function (date, asset_class)
{
  # BAS doesn't appear to accept an end_date different from date: the
  # response is empty.
  start_date <- paste0(format(date, '%Y-%m-%d'), 'T00:00:00.000000Z')
  end_date <- start_date
  # Build POST body
  body <- list(list(tradeDays = list(startDay = start_date, endDay = end_date)))
  names(body) <- bsef_data_requestor(asset_class)
  body <- list(Request = body)
  response <- POST(url = bsef_url(), config = bsef_header(), body = body,
    encode = 'json')
  # Convert response's content to JSON from raw
  response <- fromJSON(rawToChar(response$content))
  # Drill down response to data set that we are interested in
  response$response[[bsef_data_responder(asset_class)]]$BsefEodData
}

#' @importFrom dplyr mutate select %>%
format_bsef_data <- function (df)
{
  df %>%
    mutate(date = ymd_hms(tradeDate),
      security = factor(security),
      currency = factor(currency),
      priceopen = as.numeric(priceOpen),
      pricehigh = as.numeric(priceHigh),
      pricelow = as.numeric(priceLow),
      priceclose = as.numeric(priceClose),
      pricesettlement = as.numeric(settlementPrice),
      totalvolume = as.numeric(totalVolume),
      blocktradevolume = as.numeric(blockTradeVolume),
      totalvolumeusd = as.numeric(totalVolumeUsd),
      blocktradevolumeusd = as.numeric(blockTradeVolumeUsd)) %>%
    select(date, security, currency, priceopen, pricehigh, pricelow, priceclose,
      pricesettlement, totalvolume, blocktradevolume, totalvolumeusd,
      blocktradevolumeusd)
}

# URL target for data request
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 19 Sep 2014
bsef_url <- function ()
  'http://data.bloombergsef.com/bas/blotdatasvc'

# Bloomberg BAS version number
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 19 Sep 2014
#' @importFrom httr add_headers
bsef_header <- function (version = '1.9')
  add_headers('bas-version' = version)

# Way to tell Bloomberg which market data set is wanted
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 19 Sep 2014
bsef_data_requestor <- function (asset_class) {
  paste0('getBsefEod', switch(asset_class,
    CR = 'Cds', EQ = 'Eqt', FX = 'Fx', IR = 'Irs', CO = 'Cmd'),
    'DataRequest')
}

# Way to drill down into the data response that is provided
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 19 Sep 2014
bsef_data_responder <- function (asset_class) {
  paste0('getBsefEod', switch(asset_class,
    CR = 'Cds', EQ = 'Eqt', FX = 'Fx', IR = 'Irs', CO = 'Cmd'),
    'DataResponse')
}
