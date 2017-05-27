#' Get CME SDR data
#'
#' The CME Swap Data Repository (SDR) is a registered U.S. swap data repository
#' that allows market participants to fulfil their public disclosure
#' obligations under U.S. legislation. CME is required to make publicly
#' available price, trading volume and other trading data. It publishes this
#' data on an FTP site.
#'
#' @param date the date for which data is required as Date or DateTime object.
#'   It will only use the year, month and day elements to
#'   determine the set of trades to return. It will return the set of trades
#'   for the day starting on \code{date}.
#' @param asset_class the asset class for which you would like to download trade
#'   data. Valid inputs are  \code{"IR"} (rates), \code{"FX"} (foreign
#'   exchange), \code{"CO"} (commodities). This must be a string.
#' @param field_specs a valid column specification that is passed to
#'   [readr::read_csv()] with a default value provided by `cme_field_specs()`.
#'   Note that you will likely need to set your own spec as the CME file formats
#'   have changed over time.
#' @return a tibble containing the requested data, or an empty tibble
#'   if data is unavailable
#' @references \href{http://www.cmegroup.com/trading/global-repository-services/cme-swap-data-repository.html}{CME SDR}
#' @examples
#' \dontrun{
#' library(lubridate)
#' cme(ymd(20150506), "CO")
#' }
#' @export

cme <- function(date, asset_class, field_specs = NULL) {
  assertthat::assert_that(
    lubridate::is.instant(date), length(date) == 1,
    assertthat::is.string(asset_class),
    asset_class %in% c("FX", "IR", "CO")
  )
  field_specs <- field_specs %||% cme_field_specs(asset_class)
  on.exit(unlink(zip_path, recursive = TRUE))
  zip_path <- cme_download(date, asset_class)
  on.exit(unlink(csv_path, recursive = TRUE), add = TRUE)
  csv_path <- unzip_(zip_path)
  if(is.na(csv_path)) {
    tibble::tibble()
  } else {
    readr::read_csv(csv_path, col_types = field_specs)
  }
}

cme_ftp_url <- function (date, asset_class) {
  # Eg URLS
  # ftp://ftp.cmegroup.com/sdr/fx/2015/03/RT.FX.20150301.csv.zip
  # ftp://ftp.cmegroup.com/sdr/rates/2013/07/RT.IRS.20130702.csv.zip
  # ftp://ftp.cmegroup.com/sdr/commodities/2015/02/RT.COMMODITY.20150201.csv.zip
  asset_map <- c(CO = "commodities", CR = "credit", FX = "fx", IR = "rates")
  asset_class_long <- asset_map[asset_class]
  paste0("ftp://ftp.cmegroup.com/sdr/", tolower(asset_class_long), "/",
    format(date, "%Y/%m"), "/", cme_file_name(date, asset_class), ".zip")
}

cme_file_name <- function (date, asset_class) {
  asset_map <- c(CO = "commodity", CR = "CDS", FX = "fx", IR = "irs")
  paste0("RT.", toupper(asset_map[asset_class]), format(date, ".%Y%m%d.csv"))
}


cme_download <- function(date, asset_class) {
  file_url <- cme_ftp_url(date, asset_class)
  zip_path <- file.path(tempdir(),
    paste0(cme_file_name(date, asset_class), ".zip"))
  tryCatch(expr = {
      res <- utils::download.file(file_url, zip_path, quiet = TRUE)
      if (res == 0) return(zip_path) else return(NA)},
    error = function(e) return(NA),
    warning = function(w) return(NA)
  )
}

#' @rdname cme
#' @export
cme_field_specs <- function(asset_class) {
  switch(asset_class,
    CO = cme_co_field_specs(),
    IR = cme_ir_field_specs(),
    FX = cme_fx_field_specs()
  )
}

cme_co_field_specs <- function() {
  # Based on 25 May 2017 file with some mods
  readr::cols(
    .default = readr::col_character(),
    `Leg 1 Total Notional` = readr::col_integer(),
    Price = readr::col_double(),
    `Leg 1 Fixed Payment` = readr::col_double(),
    `Leg 1 Spread` = readr::col_double(),
    `Leg 2 Fixed Payment` = readr::col_double(),
    `Leg 2 Spread` = readr::col_double(),
    `Option Strike Price` = readr::col_double(),
    `Option Premium` = readr::col_double(),
    `Leg 2 Total Notional` = readr::col_double(),
    `Upfront Payment` = readr::col_double()
  )
}


cme_ir_field_specs <- function() {
  # Based on 21 Apr 2017 file with some mods
  readr::cols(
    .default = readr::col_character(),
    `Upfront Payment` = readr::col_double(),
    `Leg 1 Fixed Rate` = readr::col_double(),
    `Leg 1 Spread` = readr::col_double(),
    `Leg 1 Notional` = readr::col_double(),
    `Leg 2 Fixed Rate` = readr::col_double(),
    `Leg 2 Spread` = readr::col_double(),
    `Leg 2 Notional` = readr::col_double(),
    `Option Strike Price` = readr::col_double(),
    `Option Premium` = readr::col_double(),
    `Future Value Notional` = readr::col_double()
  )
}


cme_fx_field_specs <- function() {
  # Based on 13 Dec 2016 file with some mods
  readr::cols(
    .default = readr::col_character(),
    `Notional Amount 1` = readr::col_double(),
    `Notional Amount 2` = readr::col_double(),
    `Exchange Rate` = readr::col_double(),
    `Option Strike Price` = readr::col_double(),
    `Option Premium` = readr::col_double(),
    `Upfront Payment` = readr::col_double()
  )
}
