## Summary

Major rewrite of package and bug fix. 

* Package dependencies have been updated including bumping required version of 
  R to 4.1.0.
* Minor user facing changes and a bug fix.

## Reverse dependencies

No reverse dependency issues.

## Test environments

* MacOS-latest: R-release
* Windows-latest: R-release
* Ubuntu-latest: R-release
* Ubuntu-latest: R-devel (r81417)

## Test results

* Error on testing oldrel (R 4.0.5) as the package requires 4.1.0 (use of the
  new pipe operator).
* Otherwise, no issues across environments: 0 errors ✓ | 0 warnings ✓ | 0 notes ✓
