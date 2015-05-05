# Reverse engineering API:
# http://www.bloombergsdr.com/assets/js/search.js
download_bsdr_data_single <- function (from, to, asset_class, currency = NULL,
  notional_range = NULL) {
  msg <- paste0('Downloading and reading BSDR data for the ', asset_class,
    ' asset class for the period from ', format(from, '%d-%b-%Y'), " to ",
    format(to, '%d-%b-%Y'))
  if (!is.null(currency)) {
    msg <- paste0(msg, " for currency ", currency)
  }
  if (!is.null(notional_range)) {
    msg <- paste0(msg, " with notional range in ", notional_range[1], " to ",
      notional_range[2])
  }
  msg <- paste0(msg, '...')
  message(msg)
  start_date <- paste0(format(from, '%Y-%m-%d'), 'T00:00:00.000000Z')
  end_date <- paste0(format(to, '%Y-%m-%d'), 'T00:00:00.000000Z')
  # Build POST body
  body <- list(
    data_type = "FULL",
    asset_class = asset_class,
    datetime_low = start_date,
    datetime_high = end_date)
  if (!is.null(currency)) {
    body <- c(body, currency = currency)
  }
  if (!is.null(notional_range)) {
    body <- c(body,
      notional_low = notional_range[1], notional_high = notional_range[2])
  }
  body <- list(Request = list(pubRequest = body))
  response <- httr::POST(url = bsdr_url(), body = body, encode = 'json')
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
