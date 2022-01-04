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
#' @param show_col_types if `FALSE` (default), do not show the guessed column
#'   types. If `TRUE` always show the column types, even if they are supplied.
#'   If `NULL` only show the column types if they are not explicitly supplied by
#'   the col_types argument.
#' @return a tibble containing the requested data, or an empty tibble if data is
#'   unavailable
#' @references [CME SDR](https://www.cmegroup.com/trading/global-repository-services/cme-swap-data-repository.html)
#' @examples
#' \dontrun{
#' cme(as.Date("2015-05-06"), "CO")
#' }
#' @export

cme <- function(date, asset_class, show_col_types = FALSE) {
  vetr::vetr(
    Sys.Date() || Sys.time(),
    character(1L) && . %in% c('CR', 'EQ', 'FX', 'IR', 'CO'),
    logical(1)
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

cme_download <- function(date, asset_class) {
  zip_path <- file.path(
    tempdir(),
    cme_file_name(date, asset_class, new = TRUE)
  )
  # CME file names are inconsistent over time. Some are suffixed just with .zip
  # while others are suffixed with .csv.zip. There are other variations that
  # are not picked up below. Needed to use tryCatch() as the
  # req_error(is_error = FALSE) approach doesn't swallow ftp errors.
  tryCatch(expr = {
    cme_base_req(date, asset_class, TRUE) |>
      httr2::req_perform(path = zip_path)
    return(zip_path)
  },
    error = function(e) {
      tryCatch(expr = {
        cme_base_req(date, asset_class, FALSE) |>
          httr2::req_perform(path = zip_path)
        return(zip_path)
      },
        error = function(e) {
          return(NA_character_)
        }
      )
    }
  )
}

cme_base_req <- function(date, asset_class, new) {
  request_dod("ftp://ftp.cmegroup.com/sdr") |>
    httr2::req_url_path_append(cme_asset_class_folder(asset_class)) |>
    httr2::req_url_path_append(format(date, "%Y/%m")) |>
    httr2::req_url_path_append(cme_file_name(date, asset_class, new)) |>
    httr2::req_error(is_error = \(resp) FALSE)
}

cme_file_name <- function(date, asset_class, new) {
  paste0(
    paste(
      "RT",
      cme_asset_class_file(asset_class),
      format(date, "%Y%m%d"),
      sep = "."
    ),
    if(new) ".csv" else NULL,
    ".zip"
  )
}

cme_asset_class_folder <- function(short) {
  switch(short,
    CO = "commodities",
    CR = "credit",
    EQ = "equity",
    FX = "fx",
    IR = "rates"
  )
}

cme_asset_class_file <- function(short) {
  switch(short,
    CO = "COMMODITY",
    CR = "CDS",
    EQ = "EQUITY",
    FX = "FX",
    IR = "IRS"
  )
}
