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

bsdr_api <- function(dates, asset_class, currency = NULL, notionals = NULL) {
  # Set things up
  body <- init_bsdr_body()
  dates <- to_bsdr_time_format(dates)

  # Define POST body
  body$asset_class <- toupper(asset_class)
  body$datetime_low <- dates[1]
  body$datetime_high <- dates[2]
  body$currency <- toupper(currency %||% body$currency)
  body$notional_low <- notionals %||% c_input(notionals)[1]
  body$notional_high <- notionals %||% c_input(notionals)[2]

  # Get number of records returned by query
  body <- c(body, limit = 0)
  response <- httr::POST(url = bsdr_url(), body = body, encode = 'json')
  if (httr::http_error(response)) {
    return(BSDR_API(response, tibble::tibble()))
  }
  value <- httr::content(response, as = "parsed",
    simplifyVector = TRUE, flatten = TRUE)
  nrecs <- as.numeric(value[["Response"]][["pubResponse"]][["total"]])

  # Get all records
  if (nrecs == 0 || is.null(nrecs)) {
    return(BSDR_API(response, value))
  } else {
    # Seems to be a limit on size of payload that can be returned.
    # By trial and error, 2500 records seems to be safe.
    pulled <- 0; i <- 1; response <- vector("list");
    value <- list(public_recs = NULL, total = nrecs)
    pb <- utils::txtProgressBar(style = 3)
    while (pulled < nrecs) {
      body$offset <- pulled
      body$limit  <- min(nrecs - pulled, 2500)
      response[[i]] <- httr::POST(url = bsdr_url(), body = body, encode = 'json')
      value[["public_recs"]][[i]] <- parse_bsdr_content(response[[i]])
      pulled <- pulled + body$limit; i <- i + 1
      utils::setTxtProgressBar(pb, pulled / nrecs)
    }
    value[["public_recs"]] <- dplyr::bind_rows(value[["public_recs"]])
    close(pb)
    return(BSDR_API(response, value))
  }
}

BSDR_API <- function(response, parsed, path = "bas/bsdrweb") {
  structure(list(
    response = response,
    parsed = parsed,
    path = path
  ), class = "bsdr_api")
}

init_bsdr_body <- function() {
  list(
    source = "search",
    sorting_column = list(),
    asset_class = "",
    datetime_low = "",
    datetime_high = "",
    currency = "",
    notional_low = "",
    notional_high = "",
    offset = 0
  )
}

print.bsdr_api <- function(x, ...) {
  cat("<BSDR ", x$path, ">\n", sep = "")
  str(x$parsed, max.level = 1)
  invisible(x)
}

parse_bsdr_content <- function(response) {
  # Unwrap output a bit. Other elements of response are XML cruft
  value <- httr::content(response, as = "parsed",
    simplifyVector = TRUE, flatten = TRUE)
  out <- value[["Response"]][["pubResponse"]][["public_recs"]]
  tibble::as_tibble(out)
}


to_bsdr_time_format <- function(dates) {
  # Format dates to format expected by BBG API
  tz <- sub("(^\\+[[:digit:]]{2})([[:digit:]]{2}$)", "\\1:\\2",
    format(dates, "%z"))
  res <- paste0(format(dates, "%Y-%m-%dT%H:%M:%OS3"), tz)
  c_input(res, "")
}

c_input <- function(input, value = "") {
  if (length(input) == 1) {
    return(c(input, value))
  } else {
    return(input)
  }
}

bsdr_url <- function () {
  "http://www.bloombergsdr.com/bas/bsdrweb"
}
