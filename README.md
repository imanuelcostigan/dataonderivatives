
<!-- README.md is generated from README.Rmd. Please edit that file -->

# OTC derivatives data

Liquidity and pricing in the over-the-counter (OTC) derivative markets
have tended to have less transparent than their exchange traded (lit)
equivalents. The Bank of International Settlements (BIS) has [published
statistics](https://www.bis.org/statistics/derstats.htm) of trading in
the OTC markets on a triennial basis. However, representative statistics
of volume and pricing data on a more frequent basis has been near
impossible to obtain. Post-GFC derivatives reforms have lifted the veil
in these markets.

## Swap execution facilities

Some Over-The-Counter (OTC) derivatives have been Made Available for
Trade (MAT) by the CTFC. This means they must be traded on [Swap
Execution Facilities
(SEFs)](https://www.cftc.gov/IndustryOversight/TradingOrganizations/SEF2/index.htm).
These SEFs are compelled publish trading volume and prices for these MAT
derivatives on a daily basis.

Some of the most widely used SEFs are run by
[Bloomberg](https://www.bloomberg.com/professional/product/swap-execution-facility/),
[ICAP](https://tpicap.com/tpicap/regulatory-hub/tp-icap-sef), [Tullett
Prebon](https://www.tullettprebon.com/swap-execution-facility/) and
[Tradeweb](https://www.tradeweb.com/our-markets/market-regulation/sef/)
among others.

## Swap data repositories

The key economic terms of traded swaps must be reported to an authorised
[Swap Data Repository
(SDR)](https://www.cftc.gov/IndustryOversight/DataRepositories/index.htm).
Some of the most widely used SDRs are the [DTCC Data
Repository](https://www.dtcc.com/repository-and-derivatives-services/repository-services/gtr-north-america),
[ICE Trade Vault](https://www.theice.com/technology/post-trade) and the
[CME’s
SDR](https://www.cmegroup.com/trading/global-repository-services/cme-swap-data-repository.html).
The [CFTC provides weekly
snapshots](https://www.cftc.gov/MarketReports/SwapsReports/index.htm) of
data collected by these SDRs on a weekly basis. SDRs domiciled in
different regulatory jurisdictions are expected to provide differing
levels of data. [U.S.
regulations](https://www.cftc.gov/IndustryOversight/DataRepositories/index.htm)
compel U.S. domiciled SDRs to provide (anonymised) trade level data to
the public while SDRs in other jurisdictions (e.g. in
[Europe](https://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2013:052:0033:0036:EN:PDF))
expected far less granular, and typically only aggregated, data.

# dataonderivatives

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/dataonderivatives)](https://CRAN.R-project.org/package=dataonderivatives)
[![R-CMD-check](https://github.com/imanuelcostigan/dataonderivatives/workflows/R-CMD-check/badge.svg)](https://github.com/imanuelcostigan/dataonderivatives/actions)
[![Codecov test
coverage](https://codecov.io/gh/imanuelcostigan/dataonderivatives/branch/master/graph/badge.svg)](https://app.codecov.io/gh/imanuelcostigan/dataonderivatives?branch=master)
<!-- badges: end -->

You can source OTC derivatives data from supported sources. Supported
sources include BloombergSEF and several U.S. domiciled SDRs including
DTCC’s DDR, Bloomberg’s SDR and CME. SDRs in other jurisdictions do not
provide trade level data and consequently these sources are unsupported.
Further sources that provide trade level data will be added over time
(and pull requests to that end are welcome).

## Usage

You can download daily trade data executed on the BloombergSEF:

``` r
library("dataonderivatives")
bsef(as.Date("2021-12-13"), asset_class = "IR")
#> # A tibble: 333 × 13
#>    tradeDate   security  priceOpen priceHigh priceLow priceClose settlementPrice
#>    <chr>       <chr>     <chr>     <chr>     <chr>    <chr>      <chr>          
#>  1 2021-12-13… AUD SWAP… 2.234     2.234     2.234    2.234      2.234          
#>  2 2021-12-13… AUD SWAP… 2.55625   2.55625   2.26     2.26       2.26           
#>  3 2021-12-13… CAD SWAP… 1.94      1.94      1.94     1.94       1.94           
#>  4 2021-12-13… CAD SWAP… 1.363362  1.4839    0.87616  0.87616    0.87616        
#>  5 2021-12-13… CAD SWAP… 2.419     2.419     2.419    2.419      2.419          
#>  6 2021-12-13… CAD SWAP… 2.419     2.419     2.419    2.419      2.419          
#>  7 2021-12-13… CAD SWAP… 2.3765    2.3765    2.3585   2.3585     2.3585         
#>  8 2021-12-13… CHF SWAP… -0.4344   -0.4344   -0.4344  -0.4344    -0.4344        
#>  9 2021-12-13… CHF SWAP… -0.25     -0.25     -0.25    -0.25      -0.25          
#> 10 2021-12-13… EUR MAC … 0.25      0.25      0.25     0.25       0.25           
#> # … with 323 more rows, and 6 more variables: totalVolume <chr>,
#> #   blockTradeVolume <chr>, totalVolumeUsd <chr>, blockTradeVolumeUsd <chr>,
#> #   currency <chr>, premiumVolatilityOtherFlag <chr>
# Get more than one day's data
bsef(as.Date("2021-12-13"), as.Date("2021-12-17"), asset_class = "IR")
#> # A tibble: 1,523 × 13
#>    tradeDate   security  priceOpen priceHigh priceLow priceClose settlementPrice
#>    <chr>       <chr>     <chr>     <chr>     <chr>    <chr>      <chr>          
#>  1 2021-12-13… AUD SWAP… 2.234     2.234     2.234    2.234      2.234          
#>  2 2021-12-13… AUD SWAP… 2.55625   2.55625   2.26     2.26       2.26           
#>  3 2021-12-13… CAD SWAP… 1.94      1.94      1.94     1.94       1.94           
#>  4 2021-12-13… CAD SWAP… 1.363362  1.4839    0.87616  0.87616    0.87616        
#>  5 2021-12-13… CAD SWAP… 2.419     2.419     2.419    2.419      2.419          
#>  6 2021-12-13… CAD SWAP… 2.419     2.419     2.419    2.419      2.419          
#>  7 2021-12-13… CAD SWAP… 2.3765    2.3765    2.3585   2.3585     2.3585         
#>  8 2021-12-13… CHF SWAP… -0.4344   -0.4344   -0.4344  -0.4344    -0.4344        
#>  9 2021-12-13… CHF SWAP… -0.25     -0.25     -0.25    -0.25      -0.25          
#> 10 2021-12-13… EUR MAC … 0.25      0.25      0.25     0.25       0.25           
#> # … with 1,513 more rows, and 6 more variables: totalVolume <chr>,
#> #   blockTradeVolume <chr>, totalVolumeUsd <chr>, blockTradeVolumeUsd <chr>,
#> #   currency <chr>, premiumVolatilityOtherFlag <chr>
```

You can also download the data reported to the DTCC’s and CME’s SDRs:

``` r
ddr(as.Date("2021-12-13"), "IR")
#> # A tibble: 13,891 × 69
#>    `Dissemination ID` `Original Dissemi… `Primary Asset C… `Product ID`   Action
#>                 <dbl>              <dbl> <chr>             <chr>          <chr> 
#>  1          248871220                 NA IR                InterestRate:… NEW   
#>  2          248871315                 NA IR                InterestRate:… NEW   
#>  3          248871316                 NA IR                InterestRate:… NEW   
#>  4          248871317                 NA IR                InterestRate:… NEW   
#>  5          248871481          248870394 IR                InterestRate:… CANCEL
#>  6          248871482          248870394 IR                InterestRate:… CORRE…
#>  7          248771101                 NA IR                InterestRate:… NEW   
#>  8          248770933                 NA IR                InterestRate:… NEW   
#>  9          248815618          248815527 IR                InterestRate:… CANCEL
#> 10          248815621          248815582 IR                InterestRate:… CANCEL
#> # … with 13,881 more rows, and 64 more variables: Transaction Type <chr>,
#> #   Block Trade Election Indicator <chr>, Cleared <chr>,
#> #   Clearing Exception or Exemption Indicator <chr>,
#> #   Day Count Convention <chr>, Effective Date <date>,
#> #   Embedded Option Type <chr>, Event Timestamp <dttm>, Exchange Rate <lgl>,
#> #   Exchange Rate Basis <lgl>, Execution Timestamp <dttm>,
#> #   Expiration Date <date>, First Exercise Date <date>, Fixed Rate 1 <dbl>, …
cme(as.Date("2021-12-13"), "CO")
#> # A tibble: 406 × 64
#>    Event     `Execution Timestamp` `Dissemination Time` Cleared Collateralizati…
#>    <chr>     <chr>                 <chr>                <chr>   <chr>           
#>  1 New Trade 12/10/2021 14:36:48   12/10/2021 14:36:48  Unclea… Partially Colla…
#>  2 New Trade 12/10/2021 14:44:23   12/10/2021 14:44:23  Unclea… Partially Colla…
#>  3 New Trade 12/10/2021 16:35:19   12/10/2021 16:35:19  Unclea… Partially Colla…
#>  4 New Trade 12/10/2021 14:44:54   12/10/2021 14:44:54  Unclea… Partially Colla…
#>  5 New Trade 12/10/2021 14:44:54   12/10/2021 14:44:54  Unclea… Partially Colla…
#>  6 New Trade 12/10/2021 23:26:03   12/10/2021 23:26:03  Unclea… Partially Colla…
#>  7 New Trade 12/10/2021 15:57:47   12/10/2021 15:57:47  Unclea… Partially Colla…
#>  8 New Trade 12/10/2021 17:04:18   12/10/2021 17:04:18  Unclea… Partially Colla…
#>  9 New Trade 12/10/2021 18:41:16   12/10/2021 18:41:16  Unclea… Partially Colla…
#> 10 New Trade 12/10/2021 22:19:05   12/10/2021 22:19:05  Unclea… Partially Colla…
#> # … with 396 more rows, and 59 more variables: End-User Exception <lgl>,
#> #   Bespoke <chr>, Block/Off Facility <chr>, Execution Venue <chr>, UPI <lgl>,
#> #   Product <chr>, Asset Class <chr>, Contract Type <chr>,
#> #   Effective Date <chr>, Maturity Date <chr>, Sub Asset Class <chr>,
#> #   Leg 1 Total Notional <lgl>, Price <dbl>, Settlement Method <chr>,
#> #   Settlement Currency <chr>, Leg 1 Type <chr>, Leg 1 Fixed Payment <dbl>,
#> #   Leg 1 Fixed Payment Currency <chr>, Leg 1 Index <chr>, …
```
