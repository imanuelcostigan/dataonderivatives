## Summary

Initial submission to CRAN. Tests OK.

## Test environments

* local OS X install, R 3.2.2
* ubuntu 12.04 (on travis-ci), R 3.2.2
* win-builder (devel and release)

## R CMD check results

There were no ERRORs, WARNINGs. Only travis-ci yielded two notes. 

Note 1: 

> * checking CRAN incoming feasibility ... NOTE
> Maintainer: ‘Imanuel Costigan <i.costigan@me.com>’
> New submission
> Checking URLs requires 'libcurl' support in the R build

As far as I can tell, neither my package or its upstream dependencies **require** libcurl. 

Note 2:

> * checking package dependencies ... NOTE
>   No repository set, so cyclic dependency check skipped

I believe this is a note specific to the travis-ci environment.

## Downstream dependencies

New package. There are currently no downstream dependencies for this package. 
