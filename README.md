<!-- README.md is generated from README.Rmd. Please edit that file -->
OTC derivatives data
====================

Liquidity and pricing in the over-the-counter (OTC) derivative markets have tended to have less transparent than their exchange traded (lit) equivalents. The Bank of International Settlements (BIS) has [published statistics](http://www.bis.org/statistics/derstats.htm) of trading in the OTC markets on a triennual basis. However, representative statistics of volume and pricing data on a more frequent basis has been near impossible to obtain. Post-GFC derivatives reforms have lifted the veil in these markets.

Swap execution facilities
-------------------------

Some Over-The-Counter (OTC) derivatives have been Made Available for Trade (MAT) by the CTFC. This means they must be traded on [Swap Execution Facilities (SEFs)](http://www.cftc.gov/IndustryOversight/TradingOrganizations/SEF2/index.htm). These SEFs are compelled publish trading volume and prices for these MAT derivatives on a daily basis.

Some of the most widely used SEFs are run by [Bloomberg](http://www.bloombergsef.com), [ICAP](http://www.icap.com/what-we-do/global-broking/sef.aspx), [Tullett Prebon](http://www.tullettprebon.com/swap_execution_facility/index.aspx) and [Tradeweb](http://www.tradeweb.com/Institutional/Derivatives/SEF-Center/) among others.

Swap data repositories
----------------------

The key economic terms of traded swaps must be reported to an authorised [Swap Data Repository (SDR)](http://www.cftc.gov/IndustryOversight/DataRepositories/index.htm). Some of the most widely used SDRs are the [DTCC Data Repository](http://www.dtcc.com/data-and-repository-services/global-trade-repository/gtr-us.aspx), [Bloomberg's SDR](http://www.bloombergsdr.com), [ICE Trade Vault](https://www.icetradevault.com) and the [CME's SDR](http://www.cmegroup.com/trading/global-repository-services/cme-swap-data-repository.html). The [CFTC provides weekly snapshots](http://www.cftc.gov/MarketReports/SwapsReports/index.htm) of data collected by these SDRs on a weekly basis. SDRs domiciled in different regulatory jurisdications are expected to provide differing levels of data. [U.S. regulations](http://www.cftc.gov/IndustryOversight/DataRepositories/index.htm) compel U.S. domiciled SDRs to provide (anonymised) trade level data to the public while SDRs in other jurisdictions (e.g. in [Europe](http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2013:052:0033:0036:EN:PDF)) expected far less granular, and typically only aggregated, data.

dataonderivatives
=================

[![Build Status](https://travis-ci.org/imanuelcostigan/dataonderivatives.svg?branch=master)](https://travis-ci.org/imanuelcostigan/dataonderivatives) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/imanuelcostigan/dataonderivatives?branch=master&svg=true)](https://ci.appveyor.com/project/imanuelcostigan/dataonderivatives) [![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/dataonderivatives)](https://CRAN.R-project.org/package=dataonderivatives)

You can source OTC derivatives data from supported sources. Supported sources include BloombergSEF and several U.S. domiciled SDRs including DTCC's DDR, Bloomberg's SDR and CME. SDRs in other jurisdictions do not provide trade level data and consequently these sources are unsupported. Further sources that provide trade level data will be added over time (and pull requests to that end are welcome).

Usage
-----

You can download daily trade data executed on the BloombergSEF:

``` r
library("dataonderivatives")
bsef(lubridate::ymd(20150504), "IR")
#> # A tibble: 49 x 12
#>                           tradeDate                       security
#>  *                            <chr>                          <chr>
#>  1 2015-05-04T00:00:00.000000+00:00            EUR SWAP VS 6M 15YR
#>  2 2015-05-04T00:00:00.000000+00:00             EUR SWAP VS 6M 3YR
#>  3 2015-05-04T00:00:00.000000+00:00             EUR SWAP VS 6M 5YR
#>  4 2015-05-04T00:00:00.000000+00:00             EUR SWAP VS 6M 2YR
#>  5 2015-05-04T00:00:00.000000+00:00            EUR SWAP VS 6M 10YR
#>  6 2015-05-04T00:00:00.000000+00:00            EUR SWAP VS 6M 30YR
#>  7 2015-05-04T00:00:00.000000+00:00           USD MAC 3M JU15 JU17
#>  8 2015-05-04T00:00:00.000000+00:00 SWA USD P 3.50 12/17/44 SWAP C
#>  9 2015-05-04T00:00:00.000000+00:00 SWA USD R 3.25 6/17/45 SWAP CN
#> 10 2015-05-04T00:00:00.000000+00:00           USD S/A 3M JU15 JU45
#> # ... with 39 more rows, and 10 more variables: priceOpen <chr>,
#> #   priceHigh <chr>, priceLow <chr>, priceClose <chr>,
#> #   settlementPrice <chr>, totalVolume <chr>, blockTradeVolume <chr>,
#> #   totalVolumeUsd <chr>, blockTradeVolumeUsd <chr>, currency <chr>
```

You can also download the data reported to the DTCC's SDR:

``` r
ddr(lubridate::ymd(20150504), "IR")
#> # A tibble: 3,531 x 44
#>    DISSEMINATION_ID ORIGINAL_DISSEMINATION_ID ACTION EXECUTION_TIMESTAMP
#>               <int>                     <int>  <chr>              <dttm>
#>  1         28754581                        NA    NEW 2015-05-04 01:36:25
#>  2         28755698                        NA    NEW 2015-05-04 04:17:03
#>  3         28755714                        NA    NEW 2015-05-04 04:18:04
#>  4         28755719                        NA    NEW 2015-05-04 04:19:42
#>  5         28755050                        NA    NEW 2015-05-04 02:38:19
#>  6         28755051                        NA    NEW 2015-05-04 02:38:32
#>  7         28755056                        NA    NEW 2015-05-04 02:38:55
#>  8         28755059                        NA    NEW 2015-05-04 02:35:49
#>  9         28755097                        NA    NEW 2015-05-04 02:41:09
#> 10         28754613                        NA    NEW 2015-05-04 01:35:29
#> # ... with 3,521 more rows, and 40 more variables: CLEARED <chr>,
#> #   INDICATION_OF_COLLATERALIZATION <chr>,
#> #   INDICATION_OF_END_USER_EXCEPTION <chr>,
#> #   INDICATION_OF_OTHER_PRICE_AFFECTING_TERM <chr>,
#> #   `BLOCK_TRADES_AND_LARGE_NOTIONAL_OFF-FACILITY_SWAPS` <chr>,
#> #   EXECUTION_VENUE <chr>, EFFECTIVE_DATE <date>, END_DATE <date>,
#> #   DAY_COUNT_CONVENTION <chr>, SETTLEMENT_CURRENCY <chr>,
#> #   ASSET_CLASS <chr>, `SUB-ASSET_CLASS_FOR_OTHER_COMMODITY` <chr>,
#> #   TAXONOMY <chr>, PRICE_FORMING_CONTINUATION_DATA <chr>,
#> #   UNDERLYING_ASSET_1 <chr>, UNDERLYING_ASSET_2 <chr>,
#> #   PRICE_NOTATION_TYPE <chr>, PRICE_NOTATION <dbl>,
#> #   ADDITIONAL_PRICE_NOTATION_TYPE <chr>, ADDITIONAL_PRICE_NOTATION <dbl>,
#> #   NOTIONAL_CURRENCY_1 <chr>, NOTIONAL_CURRENCY_2 <chr>,
#> #   ROUNDED_NOTIONAL_AMOUNT_1 <chr>, ROUNDED_NOTIONAL_AMOUNT_2 <chr>,
#> #   PAYMENT_FREQUENCY_1 <chr>, PAYMENT_FREQUENCY_2 <chr>,
#> #   RESET_FREQUENCY_1 <chr>, RESET_FREQUENCY_2 <chr>,
#> #   EMBEDED_OPTION <chr>, OPTION_STRIKE_PRICE <dbl>, OPTION_TYPE <chr>,
#> #   OPTION_FAMILY <chr>, OPTION_CURRENCY <chr>, OPTION_PREMIUM <dbl>,
#> #   OPTION_LOCK_PERIOD <chr>, OPTION_EXPIRATION_DATE <date>,
#> #   PRICE_NOTATION2_TYPE <chr>, PRICE_NOTATION2 <chr>,
#> #   PRICE_NOTATION3_TYPE <chr>, PRICE_NOTATION3 <chr>
```
