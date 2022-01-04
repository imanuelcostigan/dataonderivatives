#' Get Bloomberg SEF data
#'
#' The Bloomberg Swap Execution Facility (SEF) offers customers the ability to
#' execute derivative instruments across a number of different asset classes.
#' It is required to make publicly available price, trading volume and other
#' trading data. It publishes this data on its website. I have reverse
#' engineered the JavaScript libraries used by its website to call the
#' Bloomberg Application Service using `POST` requests to a target URL.
#'
#' @param start the date from which data is required as Date or DateTime object.
#'   Only the year, month and day elements of the object are used. Must be of
#'   length one.
#' @param end the date for which data is required as Date or DateTime object.
#'   Only the year, month and day elements of the object are used. Must be of
#'   length one. Defaults to the `start` date.
#' @param asset_class the asset class for which you would like to download
#'   trade data. Valid inputs are `"CR"` (credit), `"IR"` (rates),
#'   `"EQ"` (equities), `"FX"` (foreign exchange), `"CO"`
#'   (commodities) and must be a string.
#' @return a tibble containing the requested data, or an empty tibble
#'   if data is unavailable
#' @references [Bloomberg SEF data](https://data.bloombergsef.com)
#' @examples
#' \dontrun{
#' bsef(as.Date("2021-05-12"), as.Date("2021-05-14"), "IR")
#' }
#' @export

bsef <- function(start, end = start, asset_class) {

  vetr::vetr(
    Sys.Date() || Sys.time(),
    Sys.Date() || Sys.time(),
    character(1) && . %in% c('CR', 'EQ', 'FX', 'IR', 'CO')
  )

  sub_request <- list(
    tradeDays = list(
      # BBG API does not permit HMS filtering
      startDay = format(start, '%Y-%m-%dT00:00:00.000000Z'),
      endDay = format(end, '%Y-%m-%dT00:00:00.000000Z')
    )
  )
  req = list(sub_request)
  names(req) <- bsef_data_requestor(asset_class)

  res <- "https://data.bloombergsef.com/bas/blotdatasvc" |>
    request_dod() |>
    httr2::req_body_json(
      list(Request = req)
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)

  res[["response"]][[bsef_data_responder(asset_class)]][["BsefEodData"]] |>
    tibble::as_tibble()

}

# Way to tell Bloomberg which market data set is wanted
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 24 Dec 21
bsef_data_requestor <- function (asset_class) {
  paste0('getBsefEod', bsef_asset_class_map(asset_class), 'DataRequest')
}

# Way to drill down into the data response that is provided
# Source: http://data.bloombergsef.com/assets/js/ticker.js
# Date accessed: 24 Dec 21
bsef_data_responder <- function (asset_class) {
  paste0('getBsefEod', bsef_asset_class_map(asset_class), 'DataResponse')
}

bsef_asset_class_map <- function (asset_class) {
  asset_classes <- c(CR = 'Cds', EQ = 'Eqt', FX = 'Fx', IR = 'Irs', CO = 'Cmd')
  unname(asset_classes[asset_class])
}
