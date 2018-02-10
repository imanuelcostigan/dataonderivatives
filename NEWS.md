# Version 0.3.1

- Fixed BSDR payload which caused bsdr() to fail (#28)
- Published a package website
- Added code coverage

# Version 0.3.0

## NEW:

- `bsdr()` to retrieve Bloomberg SDR data (also closes #23)
- `bsef()` to retrieve Bloomberg SEF data
- `ddr()` to retrieve DTCC Data Repository data (also closes #25)
- `cme()` to retrieve CME SDR data


## DEFUNCT:

- `get_bsdr_data()` is defunct. Use the new function `bsdr()` instead which has a different interface to `get_bsdr_data()`.
- `get_bsef_data()` is defunct. Use the new function `bsef()` instead which has a different interface to `get_bsef_data()`.
- `get_ddr_data()` is defunct. Use the new function `ddr()` instead which has a different interface to `get_ddr_data()`.
- `get_cme_data()` is defunct. Use the new function `cme()` instead which has a different interface to `get_cme_data()`.

## OTHER:

- Bumped minimum version requirements for `R` as well as `readr`, `httr` and `utils` packages. The latter to ensure that `downloader::download()` can be replaced by an implementation of `utils::download.file()` that supports `https:` URLs.
- Replaced calls to `httr::url_ok()` with expressions containing `httr::status_code()` as the former is deprecated
- Expanded CI support to macOS (Travis) and Windows (Appveyor)
 

# Version 0.2.1

- Network dependent tests disabled on CRAN as they may not be reliable.
- Suppress CME warnings. Their FTP server demonstrates poor behaviour for non-existent files.

# Version 0.2.0

- Added ability to source trade data from SDRs (DTCC, Bloomberg and CME) (#7) 
- Can now specify `asset_class` in `get_bsef_data()`. Defaults to downloading data for all asset classes
- Getters return an empty data frame if data is unavailable for the date requested (#16)
- Can now specify whether or not raw data extracted from various data sources should be processed or not using the `curate` argument.
- Deprecated ICAP SEF capabilities (unstable)
- Removed packrat-sourced download() method in favour of downloader package (#12)
- Messages are no longer printed to the REPL (#18)

# Version 0.1.0

- Implemented ability to access Bloomberg and ICAP SEF data
