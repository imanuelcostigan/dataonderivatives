#' Get Bloomberg SDR data
#'
#' The Bloomberg Swap Data Repository (BSDR) is a registered U.S. swap data
#' repository that allows market participants to fulfil their public disclosure
#' obligations under U.S. legislation. BSDR is required to make publicly
#' available price, trading volume and other trading data reported to its U.S.
#' repository. It publishes this data on its website in real-time and also on a
#' historical basis. I have reverse engineered the JavaScript libraries used by
#' its website to call the Bloomberg Application Service using \code{POST}
#' requests to a target URL.
#'
#' @param date the date for which data is required as Date or DateTime object.
#'   It will use all date-time elements including year, month, day, hour,
#'   minute, second (incl. fractional seconds) and  time zone information to
#'   determine the set of trades to return. It will return the set of trades
#'   for the day starting on \code{date}.
#' @param asset_class the asset class for which you would like to download
#'   trade data. Valid inputs are \code{"CR"} (credit), \code{"IR"} (rates),
#'   \code{"EQ"} (equities), \code{"FX"} (foreign exchange), \code{"CO"}
#'   (commodities). Can be a vector of these. Defaults to \code{NULL} which
#'   corresponds to all asset classes.
#' @param curate a logical flag indicating whether raw data should be returned
#'   or whether the raw data should be processed (default). The latter involves
#'   selecting particular fields and formatting these as seemed appropriate
#'   based on data and API reviews at the time the formatting was coded.
#' @return a data frame containing the requested data, or an empty data frame
#'   if data is unavailable
#' @importFrom dplyr %>%
#' @references \href{http://www.bloombergsdr.com/search}{BSDR search}
#' @examples
#' \dontrun{
#' library (lubridate)
#' # All asset classes for day starting 6 May 2015
#' get_bsdr_data(ymd(20150506))
#' # Only IR and FX asset classes
#' get_bsdr_data(ymd(20150506), c("IR", "FX"))
#' }
#' @export

get_bsdr_data <- function (date, asset_class = NULL, curate = TRUE) {
  valid_asset_classes <- c('CR', 'EQ', 'FX', 'IR', 'CO')
  if (is.null(asset_class)) {
    asset_class <- valid_asset_classes
  }
  assertthat::assert_that(all(asset_class %in% valid_asset_classes),
    lubridate::is.instant(date), length(date) == 1)
  df <- download_bsdr_data(date, asset_class)
  if (!curate) {
    return(df)
  } else {
    return(df %>% format_bsdr_data())
  }
}
