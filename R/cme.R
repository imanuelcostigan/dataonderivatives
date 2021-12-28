#' Get CME SDR data
#'
#' The CME Swap Data Repository (SDR) is a registered U.S. swap data repository
#' that allows market participants to fulfil their public disclosure obligations
#' under U.S. legislation. CME is required to make publicly available price,
#' trading volume and other trading data. It publishes this data on an FTP site.
#' Column specs are inferred from all records in the file (i.e. `guess_max` is
#' set to `Inf` when calling [readr::read_csv]).
#'
#' @param date the date for which data is required as Date or DateTime object.
#'   It will only use the year, month and day elements to determine the set of
#'   trades to return. It will return the set of trades for the day starting on
#'   `date`.
#' @param asset_class the asset class for which you would like to download trade
#'   data. Valid inputs are  `"IR"` (rates), `"FX"` (foreign exchange), `"CO"`
#'   (commodities). This must be a string.
#' @inheritParams readr::read_csv
#' @return a tibble containing the requested data, or an empty tibble if data is
#'   unavailable
#' @references [CME SDR](http://www.cmegroup.com/trading/global-repository-services/cme-swap-data-repository.html)
#' @examples
#' \dontrun{
#' cme(as.Date("2015-05-06"), "CO")
#' }
#' @export

  assertthat::assert_that(
    lubridate::is.instant(date), length(date) == 1,
    assertthat::is.string(asset_class),
    asset_class %in% c("FX", "IR", "CO")
  )
  on.exit(unlink(zip_path, recursive = TRUE))
  zip_path <- cme_download(date, asset_class)
  on.exit(unlink(csv_path, recursive = TRUE), add = TRUE)
  csv_path <- unzip_(zip_path)
  if(is.na(csv_path)) {
    tibble::tibble()
  } else {
    readr::read_csv(csv_path, show_col_types = show_col_types, guess_max = Inf)
  }
}

cme_ftp_url <- function (date, asset_class) {
  # Eg URLS. See #35
  # ftp://ftp.cmegroup.com/sdr/fx/2015/03/RT.FX.20150301.zip
  # ftp://ftp.cmegroup.com/sdr/fx/2020/12/RT.FX.20201201.csv.zip
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
