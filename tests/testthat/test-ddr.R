context("DDR")

test_that('DDR URL scheme still valid', {
  skip_on_cran()
  for (asset_class in c("CR", "EQ", "FX", "IR", "CO")) {
    expect_false(httr::http_error(
      ddr_url(lubridate::ymd(20150430), asset_class))
    )
    expect_true(httr::http_error(
      ddr_url(lubridate::today() + lubridate::days(2), asset_class))
    )
  }
})

test_that("DDR file parsed correctly", {
  skip_on_cran()
  for (asset_class in c("CR", "EQ", "FX", "IR", "CO")) {
    res <- ddr(lubridate::ymd(20150430), asset_class)
    expect_equal(nrow(readr::problems(res)), 0)
  }
})
