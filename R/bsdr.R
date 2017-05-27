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
#' @param dates the dates for which data is required as Date or DateTime object.
#'   It will use all date-time elements including year, month, day, hour,
#'   minute, second (up to milliseconds) and  time zone information to determine
#'   the set of trades to return. It will return the set of trades for the day
#'   starting on \code{dates} if `dates` is of length one or the set of trades
#'   between the first and second elements of `dates` if `dates` has a length
#'   greater than one.
#' @param asset_class the asset class for which you would like to download trade
#'   data. Valid inputs are \code{"CR"} (credit), \code{"IR"} (rates),
#'   \code{"EQ"} (equities), \code{"FX"} (foreign exchange), \code{"CO"}
#'   (commodities).
#' @param currency the currency for which you would like to get trades for.
#'   These should be the currency's [ISO code](https://en.wikipedia.org/wiki/ISO_4217)
#' @return a tibble containing the requested data, or an empty tibble if
#'   data is unavailable. Note that fields containing notional information are
#'   not necessarily numeric values are capped in public data to meet CFTC
#'   requirements.
#' @references [BSDR search](http://www.bloombergsdr.com/search)
#' [Bloomberg SDR API](https://www.bloombergsdr.com/api)
#' @examples
#' \dontrun{
#' library (lubridate)
#' # Interest rate trades for day starting 19 May 2017
#' bsdr(ymd(20170519), "IR")
#' # Interest rate trades for the period between 19 May 2017 and 23 May 2017
#' bsdr(ymd(20170519, 20170523), "IR")
#' }
#' @export

bsdr <- function(dates, asset_class, currency = NULL) {
  assertthat::assert_that(
    lubridate::is.instant(dates),
    assertthat::is.string(asset_class),
    asset_class %in% c("IR", "FX", "CO", "CR", "EQ"),
    is.null(currency) || assertthat::is.string(currency)
  )
  res <- bsdr_api(dates, asset_class, currency = currency, notionals = NULL)
  tibble::as_tibble(res)
}

bsdr_api <- function(dates, asset_class, currency = NULL, notionals = NULL) {
  # Set things up
  body <- init_bsdr_body()
  strdates <- to_bsdr_time_format(dates)

  # Define POST body
  body$asset_class <- toupper(asset_class)
  body$datetime_low <- strdates[1]
  body$datetime_high <- strdates[2]
  if (is.na(strdates[2])) {
    # This happens when dates is of length one.
    body$datetime_high <- to_bsdr_time_format(dates[1] + lubridate::days(1))
  }
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

  value <- list(public_recs = NULL, total = nrecs)
  # Get all records
  if (nrecs == 0 || is.null(nrecs)) {
    value[["public_recs"]] <- tibble::tibble()
    return(BSDR_API(response, value))
  } else {
    # Seems to be a limit on size of payload that can be returned.
    # By trial and error, 2500 records seems to be safe.
    pulled <- 0; i <- 1; response <- vector("list");
    while (pulled < nrecs) {
      body$offset <- pulled
      body$limit  <- min(nrecs - pulled, 2500)
      response[[i]] <- httr::POST(url = bsdr_url(), body = body, encode = 'json')
      value[["public_recs"]][[i]] <- parse_bsdr_content(response[[i]])
      pulled <- pulled + body$limit; i <- i + 1
    }
    value[["public_recs"]] <- do.call(rbind, value[["public_recs"]])
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
  paste0(format(dates, "%Y-%m-%dT%H:%M:%OS3"), tz)
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

`%||%` <- function (x, y) {
  if (is.null(x)) y else x
}

#' @importFrom tibble as_tibble
as_tibble.bsdr_api <- function(x, ...) {
  x[["parsed"]][["public_recs"]]
}


