
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

[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing) [![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/dataonderivatives)](https://CRAN.R-project.org/package=dataonderivatives) [![Travis Build Status](https://travis-ci.org/imanuelcostigan/dataonderivatives.svg?branch=master)](https://travis-ci.org/imanuelcostigan/dataonderivatives) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/imanuelcostigan/dataonderivatives?branch=master&svg=true)](https://ci.appveyor.com/project/imanuelcostigan/dataonderivatives) [![Coverage status](https://codecov.io/gh/imanuelcostigan/dataonderivatives/branch/master/graph/badge.svg)](https://codecov.io/github/imanuelcostigan/dataonderivatives?branch=master)

You can source OTC derivatives data from supported sources. Supported sources include BloombergSEF and several U.S. domiciled SDRs including DTCC's DDR, Bloomberg's SDR and CME. SDRs in other jurisdictions do not provide trade level data and consequently these sources are unsupported. Further sources that provide trade level data will be added over time (and pull requests to that end are welcome).

Usage
-----

You can download daily trade data executed on the BloombergSEF:

``` r
library("dataonderivatives")
bsef(lubridate::ymd(20150504), "IR")
#> # A tibble: 49 x 12
#>    tradeDate        security       priceOpen priceHigh priceLow priceClose
#>  * <chr>            <chr>          <chr>     <chr>     <chr>    <chr>     
#>  1 2015-05-04T00:0… EUR SWAP VS 6… 0.9265    0.9265    0.9265   0.9265    
#>  2 2015-05-04T00:0… EUR SWAP VS 6… 0.167     0.167     0.167    0.167     
#>  3 2015-05-04T00:0… EUR SWAP VS 6… 0.3205    0.3487    0.312    0.3404    
#>  4 2015-05-04T00:0… EUR SWAP VS 6… 0.0905    0.1068    0.0878   0.1068    
#>  5 2015-05-04T00:0… EUR SWAP VS 6… 0.7155    0.7155    0.707    0.712     
#>  6 2015-05-04T00:0… EUR SWAP VS 6… 1.062     1.168     1.062    1.168     
#>  7 2015-05-04T00:0… USD MAC 3M JU… 1.25      1.25      1.25     1.25      
#>  8 2015-05-04T00:0… SWA USD P 3.5… 3.5       3.5       3.5      3.5       
#>  9 2015-05-04T00:0… SWA USD R 3.2… 3.25      3.25      3.25     3.25      
#> 10 2015-05-04T00:0… USD S/A 3M JU… 2.6619    2.6619    2.6619   2.6619    
#> # ... with 39 more rows, and 6 more variables: settlementPrice <chr>,
#> #   totalVolume <chr>, blockTradeVolume <chr>, totalVolumeUsd <chr>,
#> #   blockTradeVolumeUsd <chr>, currency <chr>
```

And BloombergSDR:

``` r
bsdr(lubridate::ymd(20150504), "IR")
#> # A tibble: 272 x 38
#>    dissemination_id  org_dissemination… exec_timestamp      action cleared
#>    <chr>             <chr>              <chr>               <chr>  <chr>  
#>  1 6145124147303546… 0                  2015-05-04T21:00:0… New    C      
#>  2 6145122631180091… 0                  2015-05-04T20:54:1… New    C      
#>  3 6145121802251141… 0                  2015-05-04T20:51:0… New    C      
#>  4 6145118417817174… 0                  2015-05-04T20:37:5… New    C      
#>  5 6145115729167646… 0                  2015-05-04T20:27:2… New    C      
#>  6 6145115724872941… 0                  2015-05-04T20:27:2… New    C      
#>  7 6145115720577712… 0                  2015-05-04T20:27:2… New    C      
#>  8 6145114410612948… 0                  2015-05-04T20:22:2… New    C      
#>  9 6145114255993602… 0                  2015-05-04T20:21:4… New    C      
#> 10 6145114092785631… 0                  2015-05-04T20:21:0… New    C      
#> # ... with 262 more rows, and 33 more variables: collateralization <chr>,
#> #   end_user_excpetion <chr>, bespoke_swap <chr>, block_trade <chr>,
#> #   exec_venue <chr>, effective_date <chr>, end_date <chr>,
#> #   day_count_convention <chr>, settlement_currency <chr>,
#> #   asset_class <chr>, asset_subclass <chr>, contract_type <chr>,
#> #   contract_subtype <lgl>, taxonomy <chr>,
#> #   price_forming_continuation_data <chr>, underlying_asset_1 <chr>,
#> #   underlying_asset_2 <chr>, price_notation_type <chr>,
#> #   price_notation <chr>, additional_price_notation_type <list>,
#> #   additional_price_notation <chr>, unique_product_id <chr>,
#> #   notional_currency_1 <chr>, notional_currency_amount_1 <chr>,
#> #   notional_currency_2 <chr>, payment_frequency <chr>,
#> #   payment_frequency_2 <chr>, reset_frequency_2 <chr>,
#> #   option_strike_price <chr>, option_family <chr>, option_premium <chr>,
#> #   submission_timestamp <chr>, publication_timestamp <chr>
```

You can also download the data reported to the DTCC's SDR:

``` r
ddr(lubridate::ymd(20150504), "IR")
#> # A tibble: 3,531 x 44
#>    DISSEMINATION_ID ORIGINAL_DISSEMINA… ACTION EXECUTION_TIMESTAMP CLEARED
#>               <int>               <int> <chr>  <dttm>              <chr>  
#>  1         28754581                  NA NEW    2015-05-04 01:36:25 C      
#>  2         28755698                  NA NEW    2015-05-04 04:17:03 U      
#>  3         28755714                  NA NEW    2015-05-04 04:18:04 U      
#>  4         28755719                  NA NEW    2015-05-04 04:19:42 U      
#>  5         28755050                  NA NEW    2015-05-04 02:38:19 U      
#>  6         28755051                  NA NEW    2015-05-04 02:38:32 U      
#>  7         28755056                  NA NEW    2015-05-04 02:38:55 U      
#>  8         28755059                  NA NEW    2015-05-04 02:35:49 U      
#>  9         28755097                  NA NEW    2015-05-04 02:41:09 U      
#> 10         28754613                  NA NEW    2015-05-04 01:35:29 U      
#> # ... with 3,521 more rows, and 39 more variables:
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
