#' Get EOD data from Bloomberg SEF
#'
#' The Bloomberg Swap Execution Facility (SEF) offers customers the ability to
#' execute derivative instruments across a number of different asset classes. It
#' is required to make publicly available price, trading volume and other trading
#' data. It publishes this data on its website. I have reverse engineered the
#' JavaScript libraries used by its website to call the Bloomberg Application
#' Service using \code{POST} requests to a target URL.
#'
#' @param asset_class the derivatives asset class for which data is required.
#' Must be one of the following (case-invariant): \code{'CR'} (credit),
#' \code{'EQ'} (equity), \code{'FX'} (foreign exchange), \code{'IR'} (interest
#' rates), \code{'CO'} (commodities).
#' @param start_date the date for which data is required as Date or DateTime
#' object. Only the year, month and day elements of the object are used.
#' @return a data frame containing the requested data, or if no data is available,
#' \code{NULL}.
#' @importFrom assertthat assert_that
#' @importFrom httr POST
#' @importFrom jsonlite fromJSON
#' @export
get_bsef_eod_data <- function (asset_class, start_date)
{
  # Process and check argument values
  asset_class <- toupper(asset_class)
  assert_that(asset_class %in% c('CR', 'EQ', 'FX', 'IR', 'CO'))
  # BAS doesn't appear to accept an end_date different from start_date: the
  # response is empty.
  start_date <- paste0(format(start_date, '%Y-%m-%d'), 'T00:00:00.000000Z')
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
  df <- response$response[[bsef_data_responder(asset_class)]]$BsefEodData
  data.frame(
    tradedate = ymd_hms(df$tradeDate),
    security = factor(df$security),
    currency = factor(df$currency)
    priceopen = as.numeric(df$priceOpen),
    pricehigh = as.numeric(df$priceHigh),
    pricelow = as.numeric(df$priceLow),
    priceclose = as.numeric(df$priceClose),
    pricesettlement = as.numeric(df$settlementPrice),
    totalvolume = as.numeric(df$totalVolume),
    blocktradevolume = as.numeric(df$blockTradeVolume),
    totalvolumeusd = as.numeric(df$totalVolumeUsd),
    blocktradevolumeusd = as.numeric(df$blockTradeVolumeUsd))
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
