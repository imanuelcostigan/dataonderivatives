context("BSDR")

test_that('BSDR API accesible', {
  skip_on_cran()
  df1 <- bsdr(lubridate::ymd(20170519), "IR")
  expect_is(df1, "data.frame")
  df2 <- bsdr(lubridate::ymd(20150519, 20150523), "IR")
  expect_is(df2, "data.frame")
  expect_true(nrow(df1) <= nrow(df2))
})
