#' Get DDR data
#'
#' The DTCC Data Repository is a registered U.S. swap data repository that
#' allows market participants to fulfil their public disclosure obligations
#' under U.S. legislation. This function will give you the ability to download
#' trade-level data that is reported by market participants. The field names are
#' (and is assumed to be) the same for each asset class.
#'
#' @param date the date for which data is required as Date or DateTime object.
#'   Only the year, month and day elements of the object are used and it must of
#'   be length one.
#' @param asset_class the asset class for which you would like to download trade
#'   data. Valid inputs are \code{"CR"} (credit), \code{"IR"} (rates),
#'   \code{"EQ"} (equities), \code{"FX"} (foreign exchange), \code{"CO"}
#'   (commodities). This must be a string.
#' @param field_specs a valid column specification that is passed to
#'   [readr::read_csv()] with a default value provided by `ddr_field_specs()`
#' @return a tibble that contains the requested data. If no data exists
#'   on that date, an empty tibble is returned.
#' @examples
#' \dontrun{
#' library("lubridate")
#' ddr(ymd(20170525), "IR") # Not empty
#' }
#' @references \href{https://rtdata.dtcc.com/gtr/}{DDR Real Time Dissemination
#' Platform}
#' @export

ddr <- function(date, asset_class, field_specs = ddr_field_specs()) {
  assertthat::assert_that(
    lubridate::is.instant(date), length(date) == 1,
    assertthat::is.string(asset_class),
    asset_class %in% c("CR", "EQ", "FX", "IR", "CO")
  )
  on.exit(unlink(zip_path, recursive = TRUE))
  zip_path <- ddr_download(date, asset_class)
  on.exit(unlink(csv_path, recursive = TRUE), add = TRUE)
  csv_path <- unzip_(zip_path)
  if(is.na(csv_path)) {
    tibble::tibble()
  } else {
    readr::read_csv(csv_path, col_types = field_specs)
  }
}

ddr_download <- function(date, asset_class) {
  file_url <- ddr_url(date, asset_class)
  zip_path <- file.path(tempdir(),
    paste0(ddr_file_name(date, asset_class), ".zip"))
  tryCatch(expr = {
    res <- utils::download.file(file_url, zip_path, quiet = TRUE)
    if (res == 0) return(zip_path) else return(NA)},
    error = function(e) return(NA),
    warning = function(w) return(NA)
  )
}

#' @rdname ddr
#' @export
ddr_field_specs <- function() {
  readr::cols(
    .default = readr::col_character(),
    DISSEMINATION_ID = readr::col_integer(),
    ORIGINAL_DISSEMINATION_ID = readr::col_integer(),
    EXECUTION_TIMESTAMP = readr::col_datetime(format = ""),
    EFFECTIVE_DATE = readr::col_date(format = ""),
    END_DATE = readr::col_date(format = ""),
    PRICE_NOTATION = readr::col_number(),
    ADDITIONAL_PRICE_NOTATION = readr::col_number(),
    OPTION_STRIKE_PRICE = readr::col_number(),
    OPTION_PREMIUM = readr::col_number(),
    OPTION_EXPIRATION_DATE = readr::col_date(format = "")
  )
}

# URL format for ZIP file (as at 27 May 2017):
# https://kgc0418-tdw-data2-0.s3.amazonaws.com/slices/CUMULATIVE_CREDITS_2017_05_26.zip

ddr_file_name <- function (date, asset_class) {
  asset_map <- c("CR" = "CREDITS", 'EQ' = "EQUITIES", 'FX' = "FOREX",
    'IR' = "RATES", 'CO' = "COMMODITIES")
  paste0("CUMULATIVE_", asset_map[asset_class], "_", format(date, "%Y_%m_%d"))
}

ddr_url <- function (date, asset_class) {
  stump <- "https://kgc0418-tdw-data2-0.s3.amazonaws.com/slices/"
  paste0(stump, ddr_file_name(date, asset_class), ".zip")
}
