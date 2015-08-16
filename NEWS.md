# Version 0.2

- Added ability to source trade data from SDRs (DTCC, Bloomberg and CME) (#7) 
- Can now specify `asset_class` in `get_bsef_data()`. Defaults to downloading data for all asset classes
- Can now specify whether or not raw data extracted from various data sources should be processed or not using the `curate` argument.
- Deprecated ICAP SEF capabilities (unstable)
- Removed packrat-sourced download() method in favour of downloader package

# Version 0.1

- Initial version
