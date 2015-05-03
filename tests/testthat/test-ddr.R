context("DDR")
library("lubridate")

test_that('DDR URL scheme still valid', {
  for (asset_class in ASSET_CLASSES) {
    expect_is(httr::url_ok(ddr_url(ymd(20150430), asset_class)))
  }
})

test_that("DDR zip can be downloaded", {
  expect_equal(download_ddr_zip(ymd(20150430), "IR"), 0)
})
