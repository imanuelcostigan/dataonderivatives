if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("ASSET_CLASSES"))
}

ASSET_CLASSES <- c("CR" = "CREDITS", 'EQ' = "EQUITIES", 'FX' = "FOREX",
  'IR' = "RATES", 'CO' = "COMMODITIES")

ddr_file_name <- function (date, asset_class) {
  paste0(paste("CUMULATIVE", ASSET_CLASSES[asset_class], format(date, "%Y"),
    format(date, "%m"), format(date, "%d"), sep="_"))
}

ddr_url <- function (date, asset_class) {
  assertthat::assert_that(assertthat::has_name(ASSET_CLASSES, asset_class))
  stump <- "https://kgc0418-tdw-data-0.s3.amazonaws.com/slices/"
  # "https://kgc0418-tdw-data-0.s3.amazonaws.com/slices/CUMULATIVE_CREDITS_2015_04_29.zip"
  paste0(stump, ddr_file_name(date, asset_class), ".zip")
}

download_ddr_zip <- function (date, asset_class) {
  zip_url <- ddr_url(date, asset_class)
  message('Downloading DDR zip file for ', ASSET_CLASSES[asset_class],
    ' on ', date, '...')
  tmpfile_pattern <- paste0("ddr/", ddr_file_name(date, asset_class))
  tmpfile <- tempfile(pattern = tmpfile_pattern, fileext = ".zip")
  # Need to use libcurl for https access
  download.file(url = zip_url, destfile = tmpfile, method = "libcurl")
  message("Unzipping DDR file ...")
  # Create date/asset_class dir as CSV file name in zip does not reflect date.
  # This makes it harder to ensure read_ddr_file picks up the right file.
  tmpdir <- file.path(tempdir(), 'ddr/', date, "/", asset_class, '/')
  unzip(tmpfile, exdir = tmpdir)
  message('Deleting the zip file ...')
  unlink(tmpfile)
}

read_ddr_file <- function (date, asset_class) {
  message('Reading DDR data for ', format(date, '%d-%b-%Y'), '...')
  tmpdir <- file.path(tempdir(), 'ddr/', date, "/", asset_class, '/')
  ddrfile <- list.files(tmpdir, ASSET_CLASSES[asset_class], full.names = TRUE)
  if (length(ddrfile) < 1L) {
    return(dplyr::data_frame())
  } else {
    # Should only have one file per day. Use first if multiple matches
    return(readr::read_csv(ddrfile))
  }
}

clean_ddr_files <- function () {
  message('Deleting the DDR temp directories...')
  unlink(file.path(tempdir(), 'ddr'))
}

get_ddr_data <- function (date, asset_class, clean = TRUE) {
  download_ddr_zip(date, asset_class)
  on.exit(if (clean) clean_icap_files())
  read_ddr_file(date, asset_class)
  clean_ddr_files()
}
