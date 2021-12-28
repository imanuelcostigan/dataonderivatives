test_that("CME SDR URL works",  {
  skip_on_cran()
  expect_equal(cme_base_req(as.Date("2015-03-01"), "FX", TRUE)$url,
    "ftp://ftp.cmegroup.com/sdr/fx/2015/03/RT.FX.20150301.csv.zip")
  expect_equal(cme_base_req(as.Date("2015-03-01"), "FX", FALSE)$url,
    "ftp://ftp.cmegroup.com/sdr/fx/2015/03/RT.FX.20150301.zip")
  expect_equal(cme_base_req(as.Date("2013-07-02"), "IR", TRUE)$url,
    "ftp://ftp.cmegroup.com/sdr/rates/2013/07/RT.IRS.20130702.csv.zip")
  expect_equal(cme_base_req(as.Date("2015-02-01"), "CO", TRUE)$url,
    "ftp://ftp.cmegroup.com/sdr/commodities/2015/02/RT.COMMODITY.20150201.csv.zip")
  expect_equal(cme_base_req(as.Date("2021-12-01"), "CO", TRUE)$url,
    "ftp://ftp.cmegroup.com/sdr/commodities/2021/12/RT.COMMODITY.20211201.csv.zip")
})

test_that("CME SDR download works",  {
  skip_on_cran()
  expect_error(cme_download(as.Date("2016-12-13"), "FX"), NA)
  expect_true(is.na(cme_download(as.Date("2005-03-01"), "FX")))
})

