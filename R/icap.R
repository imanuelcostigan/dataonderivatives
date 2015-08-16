if (getRversion() >= "2.15.1") {
  utils::globalVariables(c('date', 'security', 'assetclass', '.'))
}

#' Get ICAP (IGDL & ICAP US) SEF data
#'
#' ICAP offers customers the ability to execute derivative instruments on two
#' SEF faciltiies: one domiciled in the UK (IGDL) and the other domiciled in the
#' US (ICAP US). IGDL offers G3 rates products (USD, EUR and GBP - IRS, OIS,
#' FRAs, IROs, Swaptions, Inflation and Exotic Swaps and Options) only as the
#' Made Available for Trade (MAT) determinations create the greatest need for a
#' cross-border solution for many instruments within this product set. All other
#' products and instruments will continue to be serviced on ICAP's existing US
#' SEF, ICAP SEF (US) LLC. Irrespectively of the entity, is required to make
#' publicly available price, trading volume and other trading
#' data. It publishes complete historical data sets in two zip files: one for
#' IGDL and the other for ICAP US. These are downloaded, unzipped and data for
#' the date requested is formatted and returned to you.
#'
#' @inheritParams get_bsef_data
#' @param clean flag indicating whether ICAP temp files should be cleaned
#' (default: \code{TRUE})
#' @return a data frame containing the requested data, or an empty data frame
#' if data is unavailable
#' @references
#' \href{http://www.icap.com/what-we-do/global-broking/sef.aspx}{ICAP SEF}
#' @importFrom dplyr %>%
#' @examples
#' \dontrun{
#' library (lubridate)
#' get_icap_data(ymd(20140528))
#' }
#' @keywords internal
get_icap_data <- function (date, clean = TRUE) {
  download_icap_zip()
  df <- read_icap_files(date) %>% format_icap_data(.)
  if (clean) clean_icap_files()
  df
}

url_icap_zip <- function (uk = TRUE) {
  # UK SEF is G3 rates since 12 May 2014. Previously everything on US SEF.
  if (uk)
    'http://www2.icap.com/sef/marketdata/igdl/ICAPSEFMarketDataReport.zip'
  else
    'http://www2.icap.com/sef/marketdata/ussef/ICAPSEFMarketDataReport.zip'
}

download_icap_zip <- function () {
  tmpfile_uk <- tempfile(pattern = 'igdl', fileext = '.zip')
  tmpfile_us <- tempfile(pattern = 'icus', fileext = '.zip')
  message('Downloading ICAPUS and IGDL zip files...')
  downloader::download(url = url_icap_zip(TRUE), destfile = tmpfile_uk,
    quiet = TRUE)
  downloader::download(url = url_icap_zip(FALSE), destfile = tmpfile_us,
    quiet = TRUE)
  message('Unzipping ICAPUS and IGDL files...')
  unzip(tmpfile_uk, exdir = file.path(tempdir(), 'igdl'))
  unzip(tmpfile_us, exdir = file.path(tempdir(), 'icus'))
  message('Deleting the zip files...')
  unlink(c(tmpfile_uk, tmpfile_us))
}

read_icap_files <- function (date) {
  message('Reading ICAP data for ', format(date, '%d-%b-%Y'), '...')
  matched_files <- list.files(path = file.path(tempdir(), c('igdl', 'icus')),
    pattern = format(date, '%Y%m%d'), full.names = TRUE)
  if (length(matched_files) < 1L) {
    return(list())
  } else {
    dfs <- list()
    for (i in 1:NROW(matched_files)) {
      dfs[[i]] <- readr::read_csv(matched_files[i])
      dfs[[i]]$venue <- stringr::str_extract(matched_files[i], 'icus|igdl')
    }
    return(dfs)
  }
}

align_icap_data <- function (df) {
  message('Aligning ICAP data...')
  cols <- colnames(df)
  col_date <- stringr::str_detect(cols, stringr::perl('date|Date|DATE'))
  col_security <- stringr::str_detect(cols, stringr::perl('inst|Inst|INST'))
  col_assetclass <- stringr::str_detect(cols, stringr::perl('asset|Asset|ASSET'))
  col_totalvolumeusd <- stringr::str_detect(cols,
    stringr::perl('((t|T)(rade|RADE))+.*V(ol|OL)(ume|UME).*USD.*'))
  col_totalvolume <- stringr::str_detect(cols,
    stringr::perl('((t|T)(rade|RADE))+.*V(ol|OL)(ume|UME).*')) &
    !col_totalvolumeusd
  col_priceopen <- stringr::str_detect(cols, stringr::perl('OPEN|Open|open'))
  col_pricehigh <- stringr::str_detect(cols, stringr::perl('HIGH|High|high'))
  col_pricelow <- stringr::str_detect(cols, stringr::perl('LOW|Low|low'))
  col_priceclose <- stringr::str_detect(cols, stringr::perl('CLOSE|Close|close'))
  grab_column <- function (df, flags) if (sum(flags) == 1) df[, flags] else NA
  dplyr::data_frame(
    date = grab_column(df, col_date),
    security = grab_column(df, col_security),
    assetclass = grab_column(df, col_assetclass),
    totalvolume = grab_column(df, col_totalvolume),
    totalvolumeusd = grab_column(df, col_totalvolumeusd),
    priceopen = grab_column(df, col_priceopen),
    pricehigh = grab_column(df, col_pricehigh),
    pricelow = grab_column(df, col_pricelow),
    priceclose = grab_column(df, col_priceclose))
}

format_icap_data <- function (dfs) {
  if (identical(dfs, list())) {
    return(dplyr::data_frame())
  } else {
    message('Formatting ICAP data...')
    dfs <- lapply(dfs, align_icap_data)
    suppressWarnings(dfs <- dplyr::rbind_all(dfs))
    return(dfs %>% dplyr::mutate(date = lubridate::mdy(as.character(date))))
  }
}

clean_icap_files <- function () {
  message('Deleting the ICAP temp directories...')
  unlink(file.path(tempdir(), c('igdl', 'icus')), recursive = TRUE)
}

