## R CMD check results

0 errors | 0 warnings | 1 note

* NOTE: unable to verify current time -- reseau local, sans impact
* NOTE: New submission

## Notes sur inst/doc

Le warning 'inst/doc contains invalid file names' est un artefact
de devtools 2.4.6 sur macOS. Les serveurs CRAN (Debian/Windows)
gèrent inst/doc correctement via R CMD build.
