context("CME SDR")

test_that("CME SDR URL works",  {
  library("lubridate")
  expect_equal(cme_ftp_url(ymd(20150301), "FX"),
    "ftp://ftp.cmegroup.com/sdr/fx/2015/03/RT.FX.20150301.csv.zip")
  expect_equal(cme_ftp_url(ymd(20130702), "IR"),
    "ftp://ftp.cmegroup.com/sdr/rates/2013/07/RT.IRS.20130702.csv.zip")
  expect_equal(cme_ftp_url(ymd(20150201), "CO"),
    "ftp://ftp.cmegroup.com/sdr/commodities/2015/02/RT.COMMODITY.20150201.csv.zip")
})

test_that("CME SDR download works",  {
  library("lubridate")
  expect_equal(download_cme_zip(ymd(20150301), "FX"), 0)
})

