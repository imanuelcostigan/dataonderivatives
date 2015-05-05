# OTC derivatives data

Liquidity and pricing in the over-the-counter (OTC) derivative markets have tended to have less transparent than their exchange traded (lit) equivalents. The Bank of International Settlements (BIS) has [published statistics](http://www.bis.org/statistics/derstats.htm) of trading in the OTC markets on a triennual basis. However, representative statistics of volume and pricing data on a more frequent basis has been near impossible to obtain. Post-GFC derivatives reforms have lifted the veil in these markets.

## Swap execution facilities

Some Over-The-Counter (OTC) derivatives have been Made Available for Trade (MAT) by the CTFC. This means they must be traded on [Swap Execution Facilities (SEFs)](http://www.cftc.gov/IndustryOversight/TradingOrganizations/SEF2/index.htm). These SEFs are compelled to make publically available trading volume and prices for these MAT derivatives on a daily basis. 

Some of the most widely used SEFs are run by [Bloomberg](http://www.bloombergsef.com), [ICAP](http://www.icap.com/what-we-do/global-broking/sef.aspx), [Tullett Prebon](http://www.tullettprebon.com/swap_execution_facility/index.aspx) and [Tradeweb](http://www.tradeweb.com/Institutional/Derivatives/SEF-Center/) among others.

## Swap data repositories

The key economic terms of traded swaps must be reported to an authorised [Swap Data Repository (SDR)](http://www.cftc.gov/IndustryOversight/DataRepositories/index.htm). Some of the most widely used SDRs are the [DTCC Data Repository](http://www.dtcc.com/data-and-repository-services/global-trade-repository/gtr-us.aspx), [Bloomberg's SDR](http://www.bloombergsdr.com), [ICE Trade Vault](https://www.icetradevault.com) and the [CME's SDR](http://www.cmegroup.com/trading/global-repository-services/cme-swap-data-repository.html). The [CFTC provides weekly snapshots](http://www.cftc.gov/MarketReports/SwapsReports/index.htm) of data collected by these SDRs on a weekly basis.

# dataonderivatives

[![Build Status](https://travis-ci.org/imanuelcostigan/dataonderivatives.svg?branch=master)](https://travis-ci.org/imanuelcostigan/dataonderivatives)

You can source OTC derivatives data from supported sources. Supported sources include BloombergSEF and the DTCC's DDR. Further sources will be added over time (and pull requests to that end are welcome).

## Installation

You can install a development version from GitHub:

```R
# install.packages("devtools")
# install.packages("lubridate") 
devtools::install_github("imanuelcostigan/dataonderivatives")
```

My intention is to submit this package to [CRAN](http://cran.rstudio.com) soon.

## Usage

You can download daily trade data executed on the BloombergSEF:

```R
library("dataonderivatives")
get_bsef_data(lubridate::ymd(20150504))
```

You can also download the data reported to the DTCC's SDR:

```R
get_ddr_data(lubridate::ymd(20150504), "IR")
```
