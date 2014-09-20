url_icap_zip <- function (uk = true)
{
  # UK SEF is G3 rates since 12 May 2014. Previously everything on US SEF.
  if (uk)
    'http://www2.icap.com/sef/marketdata/igdl/ICAPSEFMarketDataReport.zip'
  else
    'http://www2.icap.com/sef/marketdata/ussef/ICAPSEFMarketDataReport.zip'
}

download_icap_zip <- function ()
{
  tmpfile_uk <- tempfile(pattern = 'igdl', fileext = '.zip')
  tmpfile_us <- tempfile(pattern = 'icus', fileext = '.zip')
  message('Downloading ICAPUS and IGDL zip files...')
  download.file(url_icap_zip(TRUE), tmpfile_uk, quiet = TRUE)
  download.file(url_icap_zip(FALSE), tmpfile_us, quiet = TRUE)
  message('Unzipping ICAPUS and IGDL files...')
  unzip(tmpfile_uk, exdir = file.path(tempdir(), 'igdl'))
  unzip(tmpfile_us, exdir = file.path(tempdir(), 'icus'))
  message('Deleting the zip files...')
  unlink(c(tmpfile_uk, tmpfile_us))
}

#' @importFrom dplyr rbind_all
#' @importFrom assertthat assert_that
read_icap_files <- function (date)
{
  message('Reading ICAP data for ', format(date, '%d-%b-%Y'), '...')
  matched_files <- list.files(path = file.path(tempdir(), c('igdl', 'icus')),
    pattern = format(date, '%Y%m%d'), full.names = TRUE)
  assert_that(length(matched_files) >= 1L)
  dfs <- list()
  for (i in 1:NROW(matched_files))
    dfs[[i]] <- read.csv(matched_files[i])
  suppressWarnings(rbind_all(dfs))
}

#' @importFrom assertthat assert_that
#' @importFrom dplyr setequal %>% mutate select
#' @importFrom lubridate mdy
format_icap_data <- function (df)
{
  message('Formatting ICAP data...')
  cols <- c('BATCHDATE', 'TRADEINSTRID', 'ASSETCLASS', 'Trade.Volume..USD.',
    'Trade.Volume..Local.Currency.', 'OPENPRICE', 'HIGHPRICE', 'LOWPRICE',
    'CLOSEPRICE')
  assert_that(setequal(colnames(df), cols))
  df %>%
    mutate(date = mdy(as.character(BATCHDATE)),
      security = factor(TRADEINSTRID),
      assetclass = factor(ASSETCLASS),
      totalvolume = Trade.Volume..Local.Currency.,
      totalvolumeusd = Trade.Volume..USD.,
      priceopen = OPENPRICE,
      pricehigh = HIGHPRICE,
      pricelow = LOWPRICE,
      priceclose = CLOSEPRICE) %>%
    select(date, security, assetclass, totalvolume, totalvolumeusd,
      priceopen, pricehigh, pricelow, priceclose)
}

clean_icap_files <- function () {
  message('Deleting the ICAP temp directories...')
  unlink(file.path(tempdir(), c('igdl', 'icus')))
}

#' @importFrom dplyr %>%
get_icap_data <- function (date, clean = TRUE)
{
  download_icap_zip()
  df <- read_icap_files(date) %>% format_icap_data(.)
  if (clean) clean_icap_files()
  return (df)
}
