context("ICAP")
test_that('ICAP files available', {
    expect_equal(download.file(url_icap_zip(TRUE), tempfile(), quiet = TRUE), 0L)
    expect_equal(download.file(url_icap_zip(FALSE), tempfile(), quiet = TRUE), 0L)
})
