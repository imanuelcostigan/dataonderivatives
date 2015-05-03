# Source:
# https://github.com/rstudio/packrat/blob/145364480ae13dd1b65c21fd871819526caef59f/R/downloader.R
# This function is not exported. Contributions by Kevin Ushey and Joe Cheng based
# on git blame.

download <- function(url, ...) {
  # First, check protocol. If http or https, check platform:
  if (grepl('^https?://', url)) {

    # If Windows, call setInternet2, then use download.file with defaults.
    if (.Platform$OS.type == "windows") {

      # If we directly use setInternet2, R CMD CHECK gives a Note on Mac/Linux
      seti2 <- `::`(utils, 'setInternet2')

      # Store initial settings, and restore on exit
      internet2_start <- seti2(NA)
      on.exit(suppressWarnings(seti2(internet2_start)))

      # Needed for https. Will get warning if setInternet2(FALSE) already run
      # and internet routines are used. But the warnings don't seem to matter.
      suppressWarnings(seti2(TRUE))

      # download.file will complain about file size with something like:
      #       Warning message:
      #         In download.file(url, ...) : downloaded length 19457 != reported length 200
      # because apparently it compares the length with the status code returned (?)
      # so we supress that
      suppressWarnings(download.file(url, ...))

    } else {
      # If non-Windows, check for curl/wget/lynx, then call download.file with
      # appropriate method.

      if (nzchar(Sys.which("wget")[1])) {
        method <- "wget"
      } else if (nzchar(Sys.which("curl")[1])) {
        method <- "curl"

        # curl needs to add a -L option to follow redirects.
        # Save the original options and restore when we exit.
        orig_extra_options <- getOption("download.file.extra")
        on.exit(options(download.file.extra = orig_extra_options))

        options(download.file.extra = paste("-L", orig_extra_options))

      } else if (nzchar(Sys.which("lynx")[1])) {
        method <- "lynx"
      } else {
        stop("no download method found")
      }

      download.file(url, method = method, ...)
    }

  } else {
    download.file(url, ...)
  }
}
