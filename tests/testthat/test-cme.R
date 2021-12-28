test_that("CME SDR URL works",  {
  skip_on_cran()
  expect_equal(cme_ftp_url(as.Date("2015-03-01"), "FX"),
    "ftp://ftp.cmegroup.com/sdr/fx/2015/03/RT.FX.20150301.csv.zip")
  expect_equal(cme_ftp_url(as.Date("2013-07-02"), "IR"),
    "ftp://ftp.cmegroup.com/sdr/rates/2013/07/RT.IRS.20130702.csv.zip")
  expect_equal(cme_ftp_url(as.Date("2015-02-01"), "CO"),
    "ftp://ftp.cmegroup.com/sdr/commodities/2015/02/RT.COMMODITY.20150201.csv.zip")
})

test_that("CME SDR download works",  {
  skip_on_cran()
  expect_error(cme_download(as.Date("2016-12-13"), "FX"), NA)
  expect_true(is.na(cme_download(as.Date("2005-03-01"), "FX")))
})


test_that("CME SDR file parses",  {
  skip_on_cran()
  expect_true(nrow(cme(as.Date("2016-12-13"), "FX")) > 0)
  expect_true(nrow(cme(as.Date("2005-03-01"), "FX")) == 0)
})
