ddr_url <- function (date, asset_class) {
  asset_classes <- c("CR" = "CREDITS", 'EQ' = "EQUITIES", 'FX' = "FOREX",
    'IR' = "RATES", 'CO' = "COMMODITIES")
  assertthat::assert_that(assertthat::has_name(asset_classes, asset_class))
  stump <- "https://kgc0418-tdw-data-0.s3.amazonaws.com/slices/"
  # "https://kgc0418-tdw-data-0.s3.amazonaws.com/slices/CUMULATIVE_CREDITS_2015_04_29.zip"
  paste0(stump,
    paste("CUMULATIVE", asset_classes[asset_class], format(date, "%Y"),
      format(date, "%m"), format(date, "%d"), sep="_"), ".zip")
}

download_ddr_zip <- function (date, asset_class) {
  asset_classes <- c("CR" = "CREDITS", 'EQ' = "EQUITIES", 'FX' = "FOREX",
    'IR' = "RATES", 'CO' = "COMMODITIES")
  zip_url <- ddr_url(date, asset_class)
  message('Downloading DDR zip file for ', asset_classes[asset_class],
    ' on ', date, '...')
  tmp_file <- tempfile(pattern = "ddr", fileext = ".zip")
  # Need to use libcurl for https access
  download.file(url = zip_url, destfile = tmp_file, method = "libcurl")
  message("Unzipping DDR file ...")
  unzip(tmp_file, exdir = file.path(tempdir(), 'ddr'))
  message('Deleting the zip file ...')
  unlink(tmp_file)
}
