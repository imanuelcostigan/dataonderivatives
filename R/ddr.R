#' Get DDR data
#'
#' The DTCC Data Repository is a registered U.S. swap data repository that
#' allows market participants to fulfil their public disclosure obligations
#' under U.S. legislation. This function will give you the ability to download
#' trade-level data that is reported by market participants. Column specs are
#' inferred from all records in the file (i.e. `guess_max` is set to `Inf`
#' when calling [readr::read_csv]).
#'
#' @param date the date for which data is required as Date or DateTime object.
#'   Only the year, month and day elements of the object are used and it must of
#'   be length one.
#' @param asset_class the asset class for which you would like to download trade
#'   data. Valid inputs are `"CR"` (credit), `"IR"` (rates),
#'   `"EQ"` (equities), `"FX"` (foreign exchange), `"CO"`
#'   (commodities). This must be a string.
#' @param show_col_types if `FALSE` (default), do not show the guessed column
#'   types. If `TRUE` always show the column types, even if they are supplied.
#'   If `NULL` only show the column types if they are not explicitly supplied by
#'   the col_types argument.
#' @return a tibble that contains the requested data. If no data exists
#'   on that date, an empty tibble is returned.
#' @examples
#' \dontrun{
#' ddr(as.Date("2017-05-25"), "IR") # Not empty
#' ddr(as.Date("2020-12-01"), "CR") # Not empty
#' }
#' @references [DDR Real Time Dissemination Platform](https://pddata.dtcc.com/gtr/)
#' @export

ddr <- function(date, asset_class, show_col_types = FALSE) {
  vetr::vetr(
    Sys.Date() || Sys.time(),
    character(1L) && . %in% c('CR', 'EQ', 'FX', 'IR', 'CO'),
    logical(1)
  )
  on.exit(unlink(zip_path, recursive = TRUE))
  zip_path <- ddr_download(date, asset_class)
  on.exit(unlink(csv_path, recursive = TRUE), add = TRUE)
  csv_path <- unzip_(zip_path)
  if(is.na(csv_path)) {
    tibble::tibble()
  } else {
    readr::read_csv(csv_path, show_col_types = show_col_types, guess_max = Inf)
  }
}

ddr_download <- function(date, asset_class) {
  file_url <- ddr_url(date, asset_class)
  zip_path <- file.path(tempdir(), paste0(ddr_file_name(date, asset_class)))
  res <- file_url |>
    request_dod() |>
    httr2::req_error(is_error = function (resp) FALSE) |>
    httr2::req_perform(path = zip_path)
  if (!httr2::resp_is_error(res)) return(zip_path) else return(NA)
}

ddr_file_name <- function (date, asset_class) {
  asset_map <- c("CR" = "CREDITS", 'EQ' = "EQUITIES", 'FX' = "FOREX",
    'IR' = "RATES", 'CO' = "COMMODITIES")
  if (date <= as.Date("2020-11-30")) {
    prefix <- "CUMULATIVE_"
  } else {
    prefix <- "CFTC_CUMULATIVE_"
  }
  paste0(prefix, asset_map[asset_class], "_", format(date, "%Y_%m_%d"), ".zip")
}

# URL format for ZIP file (as at 27 May 2017):
# https://kgc0418-tdw-data2-0.s3.amazonaws.com/slices/CUMULATIVE_CREDITS_YYYY_MM_DD.zip
# URL format for ZIP file (as at 1 Dec 2020)
# https://kgc0418-tdw-data-0.s3.amazonaws.com/cftc/eod/CFTC_CUMULATIVE_CREDITS_YYYY_MM_DD.zip

ddr_url <- function (date, asset_class) {
  if (date <= as.Date("2020-11-30")) {
    stump <- "https://kgc0418-tdw-data2-0.s3.amazonaws.com/slices/"
  } else {
    stump <- "https://kgc0418-tdw-data-0.s3.amazonaws.com/cftc/eod/"
  }
  paste0(stump, ddr_file_name(date, asset_class))
}
