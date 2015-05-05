<!-- README.md is generated from README.Rmd. Please edit that file -->
OTC derivatives data
====================

Liquidity and pricing in the over-the-counter (OTC) derivative markets have tended to have less transparent than their exchange traded (lit) equivalents. The Bank of International Settlements (BIS) has [published statistics](http://www.bis.org/statistics/derstats.htm) of trading in the OTC markets on a triennual basis. However, representative statistics of volume and pricing data on a more frequent basis has been near impossible to obtain. Post-GFC derivatives reforms have lifted the veil in these markets.

Swap execution facilities
-------------------------

Some Over-The-Counter (OTC) derivatives have been Made Available for Trade (MAT) by the CTFC. This means they must be traded on [Swap Execution Facilities (SEFs)](http://www.cftc.gov/IndustryOversight/TradingOrganizations/SEF2/index.htm). These SEFs are compelled to make publically available trading volume and prices for these MAT derivatives on a daily basis.

Some of the most widely used SEFs are run by [Bloomberg](http://www.bloombergsef.com), [ICAP](http://www.icap.com/what-we-do/global-broking/sef.aspx), [Tullett Prebon](http://www.tullettprebon.com/swap_execution_facility/index.aspx) and [Tradeweb](http://www.tradeweb.com/Institutional/Derivatives/SEF-Center/) among others.

Swap data repositories
----------------------

The key economic terms of traded swaps must be reported to an authorised [Swap Data Repository (SDR)](http://www.cftc.gov/IndustryOversight/DataRepositories/index.htm). Some of the most widely used SDRs are the [DTCC Data Repository](http://www.dtcc.com/data-and-repository-services/global-trade-repository/gtr-us.aspx), [Bloomberg's SDR](http://www.bloombergsdr.com), [ICE Trade Vault](https://www.icetradevault.com) and the [CME's SDR](http://www.cmegroup.com/trading/global-repository-services/cme-swap-data-repository.html). The [CFTC provides weekly snapshots](http://www.cftc.gov/MarketReports/SwapsReports/index.htm) of data collected by these SDRs on a weekly basis.

dataonderivatives
=================

[![Build Status](https://travis-ci.org/imanuelcostigan/dataonderivatives.svg?branch=master)](https://travis-ci.org/imanuelcostigan/dataonderivatives)

You can source OTC derivatives data from supported sources. Supported sources include BloombergSEF and the DTCC's DDR. Further sources will be added over time (and pull requests to that end are welcome).

Installation
------------

You can install a development version from GitHub:

``` r
# install.packages("devtools")
# install.packages("lubridate") 
# devtools::install_github("imanuelcostigan/dataonderivatives")
```

My intention is to submit this package to [CRAN](http://cran.rstudio.com) soon.

Usage
-----

You can download daily trade data executed on the BloombergSEF:

``` r
library("dataonderivatives")
get_bsef_data(lubridate::ymd(20150504))
#> Downloading and reading BSEF data for the CR asset class on 04-May-2015...
#> Downloading and reading BSEF data for the EQ asset class on 04-May-2015...
#> Downloading and reading BSEF data for the FX asset class on 04-May-2015...
#> Downloading and reading BSEF data for the IR asset class on 04-May-2015...
#> Downloading and reading BSEF data for the CO asset class on 04-May-2015...
#> Formatting BSEF data...
#> Source: local data frame [94 x 13]
#> 
#>          date assetclass                      security currency  priceopen
#> 1  2015-05-04         CR        CDX EM CDSI S23 5Y PRC      USD  90.860000
#> 2  2015-05-04         CR            CDX IG CDSI S22 5Y      USD  54.690000
#> 3  2015-05-04         CR MARKIT CDX.NA.HY.24 06/20 ICE      USD 107.375000
#> 4  2015-05-04         CR            CDX IG CDSI S23 5Y      USD  62.240000
#> 5  2015-05-04         CR        CDX HY CDSI S23 5Y PRC      USD 108.420000
#> 6  2015-05-04         CR        CDX HY CDSI S24 5Y PRC      USD 107.350000
#> 7  2015-05-04         CR            CDX IG CDSI S24 5Y      USD  62.570000
#> 8  2015-05-04         FX       NDF-EURBRL-EUR-20150617      EUR   3.490216
#> 9  2015-05-04         FX             NDF-USDBRL-BRL-1M      USD   3.120800
#> 10 2015-05-04         FX             NDF-USDBRL-USD-1M      USD   3.123700
#> ..        ...        ...                           ...      ...        ...
#> Variables not shown: pricehigh (dbl), pricelow (dbl), priceclose (dbl),
#>   pricesettlement (dbl), totalvolume (dbl), blocktradevolume (dbl),
#>   totalvolumeusd (dbl), blocktradevolumeusd (dbl)
```

You can also download the data reported to the DTCC's SDR:

``` r
get_ddr_data(lubridate::ymd(20150504), "IR")
#> Downloading DDR zip file for RATES on 2015-05-04...
#> Unzipping DDR file ...
#> Deleting the zip file ...
#> Reading DDR data for 04-May-2015...
#> Deleting the DDR temp directories...
#> Source: local data frame [3,531 x 44]
#> 
#>    DISSEMINATION_ID ORIGINAL_DISSEMINATION_ID ACTION EXECUTION_TIMESTAMP
#> 1          28754581                        NA    NEW 2015-05-04 01:36:25
#> 2          28755698                        NA    NEW 2015-05-04 04:17:03
#> 3          28755714                        NA    NEW 2015-05-04 04:18:04
#> 4          28755719                        NA    NEW 2015-05-04 04:19:42
#> 5          28755050                        NA    NEW 2015-05-04 02:38:19
#> 6          28755051                        NA    NEW 2015-05-04 02:38:32
#> 7          28755056                        NA    NEW 2015-05-04 02:38:55
#> 8          28755059                        NA    NEW 2015-05-04 02:35:49
#> 9          28755097                        NA    NEW 2015-05-04 02:41:09
#> 10         28754613                        NA    NEW 2015-05-04 01:35:29
#> ..              ...                       ...    ...                 ...
#> Variables not shown: CLEARED (chr), INDICATION_OF_COLLATERALIZATION (chr),
#>   INDICATION_OF_END_USER_EXCEPTION (chr),
#>   INDICATION_OF_OTHER_PRICE_AFFECTING_TERM (chr),
#>   BLOCK_TRADES_AND_LARGE_NOTIONAL_OFF-FACILITY_SWAPS (chr),
#>   EXECUTION_VENUE (chr), EFFECTIVE_DATE (date), END_DATE (date),
#>   DAY_COUNT_CONVENTION (chr), SETTLEMENT_CURRENCY (chr), ASSET_CLASS
#>   (chr), SUB-ASSET_CLASS_FOR_OTHER_COMMODITY (chr), TAXONOMY (chr),
#>   PRICE_FORMING_CONTINUATION_DATA (chr), UNDERLYING_ASSET_1 (chr),
#>   UNDERLYING_ASSET_2 (chr), PRICE_NOTATION_TYPE (chr), PRICE_NOTATION
#>   (dbl), ADDITIONAL_PRICE_NOTATION_TYPE (chr), ADDITIONAL_PRICE_NOTATION
#>   (dbl), NOTIONAL_CURRENCY_1 (chr), NOTIONAL_CURRENCY_2 (chr),
#>   ROUNDED_NOTIONAL_AMOUNT_1 (dbl), ROUNDED_NOTIONAL_AMOUNT_2 (dbl),
#>   PAYMENT_FREQUENCY_1 (chr), PAYMENT_FREQUENCY_2 (chr), RESET_FREQUENCY_1
#>   (chr), RESET_FREQUENCY_2 (chr), EMBEDED_OPTION (chr),
#>   OPTION_STRIKE_PRICE (dbl), OPTION_TYPE (chr), OPTION_FAMILY (chr),
#>   OPTION_CURRENCY (chr), OPTION_PREMIUM (dbl), OPTION_LOCK_PERIOD (date),
#>   OPTION_EXPIRATION_DATE (date), PRICE_NOTATION2_TYPE (chr),
#>   PRICE_NOTATION2 (dbl), PRICE_NOTATION3_TYPE (chr), PRICE_NOTATION3 (dbl)
```
