test_that('BSEF API accesible', {
  skip_on_cran()
  non_empty_data <- bsef(lubridate::ymd(20140918), lubridate::ymd(20140919), "IR")
  expect_false(identical(non_empty_data, tibble::tibble()))
  empty_data <- bsef(lubridate::ymd(20140920), asset_class = "IR")
  expect_true(identical(empty_data, tibble::tibble()))
})
