# Reverse engineering API:
# http://www.bloombergsdr.com/assets/js/search.js
download_bsdr_data_single <- function (date_range, asset_class, currency = NULL,
  notional_range = NULL) {
  # If only one date is specified for date_range, then add one day to this to
  # define the end date (i.e. we want date range starting from the date
  # specified)
  if (length(date_range) == 1) {
    date_range <- date_range + lubridate::days(0:1)
  }
  # Build message string
  msg <- paste0('Downloading and reading BSDR data for the ', asset_class,
    ' asset class for the period from ',
    paste(format(date_range, "%Y-%m-%dT%H:%M:%OS6Z"), collapse = " to "))
  if (!is.null(currency)) {
    msg <- paste0(msg, " for currency ", currency)
  }
  if (!is.null(notional_range)) {
    msg <- paste0(msg, " with notional range in ", notional_range[1], " to ",
      notional_range[2])
  }
  msg <- paste0(msg, '...')
  message(msg)
  # Format dates to format expected by BBG API
  date_range <- format(date_range, "%Y-%m-%dT%H:%M:%OS6Z")
  # Build payload to BBG API. NB: the payload build process in search.js
  # does not assume datetime_low and _high are specified. However, form always
  # has datetime_low pre-populated. Given logic at start of function, we can
  # assume that both are defined in this scope.
  body <- list(
    data_type = "FULL",
    asset_class = asset_class,
    datetime_low = date_range[1],
    datetime_high = date_range[2])
  if (!is.null(currency)) {
    body <- c(body, currency = currency)
  }
  if (!is.null(notional_range)) {
    body <- c(body, notional_low = notional_range[1],
      notional_high = notional_range[2])
  }
  body <- list(Request = list(pubRequest = body))
  response <- httr::POST(url = bsdr_url(), body = body, config = bsef_header(),
    encode = 'json')
  # Convert response's content to JSON from raw
  # Some nested data frames. So flatten these out.
  response <- jsonlite::fromJSON(rawToChar(response$content), flatten = TRUE)
  # Drill down response to data set that we are interested in
  df <- response$Response$pubResponse$public_recs
  # Create asset_class field if necesary
  if (!is.null(df)) {
    if (is.list(df)) df <- dplyr::as_data_frame(df)
    return(df)
  } else {
    df <- dplyr::data_frame()
    return(df)
  }
}

bsdr_url <- function () {
 "http://www.bloombergsdr.com/bas/bsdrweb"
}

# Header isn't specified in search.js. However, added for sake of consistency
# with BSEF spec.
bsdr_header <- function (version = 1.3) {
  httr::add_headers('bas-version' = version)
}
