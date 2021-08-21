
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geodrawr

<!-- badges: start -->

[![CRAN](https://www.r-pkg.org/badges/version/geodrawr)](https://cran.r-project.org/package=geodrawr)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/geodrawr)](https://www.r-pkg.org/pkg/geodrawr)
<!-- badges: end -->

An interactive tool for making geo-spatial objects by clicks on the map

## Installation

To install the stable version from CRAN, simply run the following from
an R console:

``` r
install.packages('geodrawr')
```

To install the latest development builds directly from GitHub, run this
instead:

``` r
if (!require('devtools')) install.packages('devtools')
devtools::install_github('Curycu/geodrawr')
```

## How to Use?

There are three draw tools :

``` r
library(geodrawr)

draw_polygons()
draw_lines()
draw_points()
```

#### case polygons

![draw\_polygons](draw_polygons.gif)

  - click the map to make edges  
  - push **Make** button to make a polygon from the edges  
  - push **Save** button to save polygons as rds file  
  - push **Load** button to load polygons from rds file

#### case lines

![draw\_lines](draw_lines.gif)

  - click the map to make edges  
  - push **Make** button to make a line from the edges  
  - push **Save** button to save lines as rds file  
  - push **Load** button to load lines from rds file

#### case points

![draw\_points](draw_points.gif)

  - click the map to make a point  
  - push **Save** button to save points on the map as a rds file  
  - push **Load** button to load points from rds file
