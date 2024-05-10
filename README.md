
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gdallocationinfo

<!-- badges: start -->
<!-- badges: end -->

The goal of gdallocationinfo is to look up values on a raster source.

Input is a character string to the GDAL readable source, and matrix of
lon,lat.

## Installation

You can install the development version of gdallocationinfo like so:

``` r
devtools::install_github("hypertidy/gdallocationinfo")
```

## Example

This is a basic example, lookup GEBCO 2023 values on world cities:

``` r
library(gdallocationinfo)
#options(parallelly.fork.enable = TRUE, future.rng.onMisuse = "ignore")
#library(furrr); plan(multicore)

loc <- locationinfo("/vsicurl/https://gebco2023.s3.valeria.science/gebco_2023_land_cog.tif", 
                    as.matrix(maps::world.cities[1:100, c("long", "lat")]))
#> 
#> Attaching package: 'purrr'
#> The following object is masked from 'package:base':
#> 
#>     %||%

str(loc)
#>  num [1:100] 79 86 140 17 331 ...
#plan(sequential)
maps::world.cities$name[which.max(loc)]
#> [1] "'Amran"
```

## Code of Conduct

Please note that the gdallocationinfo project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
