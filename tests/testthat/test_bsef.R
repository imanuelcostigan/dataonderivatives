context("BSEF")
test_that('BSEF API accesible', {
    expect_false(identical(download_bsef_data_single('IR', ymd(20140918)),
        data.frame()))
    expect_true(identical(get_bsef_data(ymd(20140920)), data.frame()))
})
