test_that('BSEF API accesible', {
  skip_on_cran()
  non_empty_data <- bsef(as.Date("2014-09-18"), as.Date("2014-09-19"), "IR")
  expect_false(identical(non_empty_data, tibble::tibble()))
  empty_data <- bsef(as.Date("2014-09-20"), asset_class = "IR")
  expect_true(identical(empty_data, tibble::tibble()))
})
