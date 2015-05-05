if (getRversion() >= "2.15.1") {
  utils::globalVariables(c('tradeDate', 'assetclass', 'security', 'currency',
    'priceOpen', 'priceHigh', 'priceLow', 'priceClose', 'settlementPrice',
    'totalVolume', 'blockTradeVolume', 'totalVolumeUsd', 'blockTradeVolumeUsd',
    'priceopen', 'pricehigh', 'pricelow', 'priceclose', 'pricesettlement',
    'totalvolume', 'blocktradevolume', 'totalvolumeusd', 'blocktradevolumeusd'))
}

#' Get Bloomberg SEF data
#'
#' The Bloomberg Swap Execution Facility (SEF) offers customers the ability to
#' execute derivative instruments across a number of different asset classes. It
#' is required to make publicly available price, trading volume and other trading
#' data. It publishes this data on its website. I have reverse engineered the
#' JavaScript libraries used by its website to call the Bloomberg Application
#' Service using \code{POST} requests to a target URL. The \code{POST} calls
#' are done by asset class. This function iterates across all asset classes
#' (credit, equities, foreign exchange, rates and commodities).
#'
#' @param date the date for which data is required as Date or DateTime
#' object. Only the year, month and day elements of the object are used. Must
#' be of length one.
#' @return a data frame containing the requested data, or an empty data frame
#' if data is unavailable
#' @importFrom dplyr %>%
#' @references
#' \href{http://data.bloombergsef.com}{Bloomberg SEF data}
#' @examples
#' library (lubridate)
#' get_bsef_data(ymd(20140528))
#' @export

get_bsef_data <- function (date) {
  assertthat::assert_that(assertthat::is.date(date), length(date) == 1)
  download_bsef_data(date) %>% format_bsef_data()
}

download_bsef_data <- function (date) {
  asset_class <- c('CR', 'EQ', 'FX', 'IR', 'CO')
  dplyr::bind_rows(Map(download_bsef_data_single, date, asset_class))
}

download_bsef_data_single <- function (date, asset_class) {
  message('Downloading and reading BSEF data for the ', asset_class,
    ' asset class on ', format(date, '%d-%b-%Y'), '...')
  assertthat::assert_that(asset_class %in% c('CR', 'EQ', 'FX', 'IR', 'CO'))
  # BAS doesn't appear to accept an end_date different from date: the
  # response is empty.
  start_date <- paste0(format(date, '%Y-%m-%d'), 'T00:00:00.000000Z')
  end_date <- start_date
  # Build POST body
  body <- list(list(tradeDays = list(startDay = start_date, endDay = end_date)))
  names(body) <- bsef_data_requestor(asset_class)
  body <- list(Request = body)
  response <- httr::POST(url = bsef_url(), config = bsef_header(), body = body,
    encode = 'json')
  # Convert response's content to JSON from raw
  response <- jsonlite::fromJSON(rawToChar(response$content))
  # Drill down response to data set that we are interested in
  df <- response$response[[bsef_data_responder(asset_class)]]$BsefEodData
  # Create asset_class field if necesary
  if (!is.null(df)) {
    if (is.list(df)) df <- dplyr::as_data_frame(df)
    df$assetclass <- asset_class
    return(df)
  } else {
    df <- dplyr::data_frame()
    return(df)
  }
}

#' @importFrom dplyr %>%
format_bsef_data <- function (df) {
  if (all(dim(df) == c(0, 0))) {
    return(dplyr::data_frame())
  } else {
    message('Formatting BSEF data...')
    df %>%
      dplyr::mutate(date = lubridate::ymd_hms(tradeDate),
        assetclass = factor(assetclass),
        security = factor(security),
        currency = factor(toupper(currency)),
        priceopen = as.numeric(priceOpen),
        pricehigh = as.numeric(priceHigh),
        pricelow = as.numeric(priceLow),
        priceclose = as.numeric(priceClose),
        pricesettlement = as.numeric(settlementPrice),
        totalvolume = as.numeric(totalVolume),
        blocktradevolume = as.numeric(blockTradeVolume),
        totalvolumeusd = as.numeric(totalVolumeUsd),
        blocktradevolumeusd = as.numeric(blockTradeVolumeUsd)) %>%
      dplyr::select(date, assetclass, security, currency, priceopen, pricehigh,
        pricelow, priceclose, pricesettlement, totalvolume, blocktradevolume,
        totalvolumeusd, blocktradevolumeusd)
  }
}

# URL target for data request
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 19 Sep 2014
bsef_url <- function () {
  'http://data.bloombergsef.com/bas/blotdatasvc'
}

# Bloomberg BAS version number
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 19 Sep 2014
bsef_header <- function (version = '1.9') {
  httr::add_headers('bas-version' = version)
}

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
