# Version 0.3

## NEW:

- `bsdr()` to retrieve Bloomberg SDR data
- `bsef()` to retrieve Bloomberg SEF data

## BREAKING:

- `get_bsdr_data()` is defunct. Use the new function `bsdr()` instead which has a different interface to `get_bsdr_data()`.
- `get_bsef_data()` is defunct. Use the new function `bsef()` instead which has a different interface to `get_bsef_data()`.

## OTHER:

- Bumped minimum version requirements for `readr` and `httr` packages
- Replaced calls to `httr::url_ok()` with expressions containing `httr::status_code()` as the former is deprecated
 

# Version 0.2.1

- Network dependent tests disabled on CRAN as they may not be reliable.
- Suppress CME warnings. Their FTP server demonstrates poor behaviour for non-existent files.

# Version 0.2

- Added ability to source trade data from SDRs (DTCC, Bloomberg and CME) (#7) 
- Can now specify `asset_class` in `get_bsef_data()`. Defaults to downloading data for all asset classes
- Getters return an empty data frame if data is unavailable for the date requested (#16)
- Can now specify whether or not raw data extracted from various data sources should be processed or not using the `curate` argument.
- Deprecated ICAP SEF capabilities (unstable)
- Removed packrat-sourced download() method in favour of downloader package (#12)
- Messages are no longer printed to the REPL (#18)

# Version 0.1

- Implemented ability to access Bloomberg and ICAP SEF data
