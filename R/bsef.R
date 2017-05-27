#' Get Bloomberg SEF data
#'
#' The Bloomberg Swap Execution Facility (SEF) offers customers the ability to
#' execute derivative instruments across a number of different asset classes.
#' It is required to make publicly available price, trading volume and other
#' trading data. It publishes this data on its website. I have reverse
#' engineered the JavaScript libraries used by its website to call the
#' Bloomberg Application Service using \code{POST} requests to a target URL.
#'
#' @param date the date for which data is required as Date or DateTime object.
#'   Only the year, month and day elements of the object are used. Must be of
#'   length one.
#' @param asset_class the asset class for which you would like to download
#'   trade data. Valid inputs are \code{"CR"} (credit), \code{"IR"} (rates),
#'   \code{"EQ"} (equities), \code{"FX"} (foreign exchange), \code{"CO"}
#'   (commodities) and must be a string.
#' @return a tibble containing the requested data, or an empty tibble
#'   if data is unavailable
#' @references \href{http://data.bloombergsef.com}{Bloomberg SEF data}
#' @examples
#' \dontrun{
#' library (lubridate)
#' # All asset classes
#' bsef(ymd(20140528), "IR")
#' }
#' @export

bsef <- function(date, asset_class) {
  assertthat::assert_that(
    lubridate::is.instant(date), length(date) == 1,
    assertthat::is.string(asset_class),
    asset_class %in% c('CR', 'EQ', 'FX', 'IR', 'CO')
  )
  res <- bsef_api(date, asset_class)
  tibble::as_tibble(res)
}

bsef_api <- function(date, asset_class) {
  # BSEF doesn't appear to accept an end_date different from date: the
  # response is empty.
  start_date <- format(date, '%Y-%m-%dT00:00:00.000000Z')
  end_date <- start_date

  body <- list(list(tradeDays = list(startDay = start_date, endDay = end_date)))
  names(body) <- bsef_data_requestor(asset_class)
  body <- list(Request = body)
  response <- httr::POST(url = bsef_url(), config = bsef_header(), body = body,
    encode = 'json')

  if (httr::http_error(response)) {
    return(BSEF_API(response, tibble::tibble()))
  } else {
    parsed <- parse_bsef_content(response, bsef_data_responder(asset_class))
    return(BSEF_API(response, parsed))
  }
}

BSEF_API <- function(response, parsed, path = "bas/blotdatasvc") {
  structure(list(
    response = response,
    parsed = parsed,
    path = path
  ), class = "bsef_api")
}

parse_bsef_content <- function(response, getter) {
  value <- httr::content(response, as = "parsed",
    simplifyVector = TRUE, flatten = FALSE)
  out <- value[["response"]][[getter]][["BsefEodData"]]
  tibble::as_tibble(out)
}

as_tibble.bsef_api <- function(x, ...) {
  x[["parsed"]]
}

# URL target for data request
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 27 May 2017
bsef_url <- function () {
  'http://data.bloombergsef.com/bas/blotdatasvc'
}

# Bloomberg BAS version number
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 27 May 2017
bsef_header <- function (version = '1.9') {
  httr::add_headers('bas-version' = version)
}

# Way to tell Bloomberg which market data set is wanted
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 27 May 2017
bsef_data_requestor <- function (asset_class) {
  paste0('getBsefEod', bsef_asset_class_map(asset_class), 'DataRequest')
}

# Way to drill down into the data response that is provided
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 27 May 2017
bsef_data_responder <- function (asset_class) {
  paste0('getBsefEod', bsef_asset_class_map(asset_class), 'DataResponse')
}

bsef_asset_class_map <- function (asset_class) {
  asset_classes <- c(CR = 'Cds', EQ = 'Eqt', FX = 'Fx', IR = 'Irs', CO = 'Cmd')
  unname(asset_classes[asset_class])
}
