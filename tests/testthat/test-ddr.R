test_that('DDR URL scheme still valid', {
  skip_on_cran()
  for (asset_class in c("CR", "EQ", "FX", "IR", "CO")) {
    ddr_url(as.Date("2015-04-30"), asset_class) |>
      httr2::request() |>
      httr2::req_user_agent("dataonderivatives (https://imanuelcostigan.github.io/dataonderivatives/)") |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform() |>
      httr2::resp_is_error() |>
      expect_false()
    ddr_url(as.Date("2021-05-03"), asset_class) |>
      httr2::request() |>
      httr2::req_user_agent("dataonderivatives (https://imanuelcostigan.github.io/dataonderivatives/)") |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform() |>
      httr2::resp_is_error() |>
      expect_false()
    ddr_url(Sys.Date() + 2, asset_class) |>
      httr2::request() |>
      httr2::req_user_agent("dataonderivatives (https://imanuelcostigan.github.io/dataonderivatives/)") |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform() |>
      httr2::resp_is_error() |>
      expect_true()
  }
})
