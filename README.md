
<!-- README.md is generated from README.Rmd. Please edit that file -->
dataspice
=========

The goal of dataspice is to make it easier for researchers to create basic, lightweight and concise metadata files for their datasets. These basic files can then be used to:

-   make useful information available during analysis.
-   create a helpful dataset README webpage.
-   produce more complex metadata formats to aid dataset discovery.

Metadata fields are based on [schema.org](http://schema.org/Dataset) and other metadata standards.

A fully worked example can be found [here](https://github.com/amoeba/dataspice-example) and a live preview of the output [here](https://amoeba.github.io/dataspice-example/). An example of how Google sees this can be found [here](https://search.google.com/structured-data/testing-tool/u/0/#url=https%3A%2F%2Famoeba.github.io%2Fdataspice-example%2F).

Installation
------------

You can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ropenscilabs/dataspice")
```

Example
-------

``` r
create_spice()
write_spice() 
build_site()
```

![worfklow](man/figures/dataspice_workflow.png)

### Create spice

-   `create_spice()` creates template metadata spreadsheets in a folder (by default created in the `data` folder)

The template files are:

-   **attributes.csv** - explains each of the variables in the dataset
-   **biblio.csv** - for spatial and temporal coverage, dataset name, keywords, etc.
-   **access.csv** - for files and file types
-   **creators.csv** - for data authors

### Fill in templates

The user needs to fill in the details of the 4 template files. These csv files can be directly modified, or they can be edited using some helper functions and/or a shiny app. **Helper functions**

-   `prep_attributes()` populates the **fileName** and **variableName** columns of the attributes.csv file using the header row of the data files.

To see an example of how this works, load the data files that ship with the package:

``` r
data_files <- list.files(system.file("example-dataset/", 
                                     package = "dataspice"), 
                         pattern = ".csv",
                        full.names = TRUE)
```

This function assumes that the metadata templates are in a folder called `metadata` within a `data` folder.

``` r
attributes_path <- here::here("data", "metadata",
 "attributes.csv")
```

Using `purrr::map()`, this function can be applied over multiple files to populate the header names

``` r
data_files %>% purrr::map(~prep_attributes(.x, attributes_path),
                         attributes_path = attributes_path)
```

The output of `prep_attributes()` has the first two columns filled out:

    #> Parsed with column specification:
    #> cols(
    #>   fileName = col_character(),
    #>   variableName = col_character(),
    #>   description = col_character(),
    #>   unitText = col_character()
    #> )

<table>
<thead>
<tr>
<th style="text-align:left;">
fileName
</th>
<th style="text-align:left;">
variableName
</th>
<th style="text-align:left;">
description
</th>
<th style="text-align:left;">
unitText
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Stock.ID
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Species
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Stock
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Ocean.Region
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Region
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Sub.Region
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Jurisdiction
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Lat
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Lon
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
UseFlag
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
BroodYear
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
TotalEscapement
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R0.1
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R0.2
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R0.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R0.4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R0.5
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R1.1
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R1.2
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R1.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R1.4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R1.5
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R2.1
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R2.2
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R2.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R2.4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R3.1
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R3.2
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R3.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R3.4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R4.1
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R4.2
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
R4.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
TotalRecruits
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
SourceInfo.csv
</td>
<td style="text-align:left;">
Source.ID
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
SourceInfo.csv
</td>
<td style="text-align:left;">
Source
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
X1
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Stock.ID
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Species
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Stock
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Date.data.obtained
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Date.data.incorporated
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Ocean.Region
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Region
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Sub.Region
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Jurisdiction
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Lat
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Lon
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Source.ID
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
Comment..we.will.update.this.later.
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
</tbody>
</table>
**Shiny apps**

Each of the metadata templates can be edited interactively using a shiny app

-   `editAttritubes()` opens a shiny app that can be used to edit `attributes.csv`. The shiny app dispalys the attributes table and lets the user fill in an informative description and units (e.g. meters, hectares, etc.) for each variable.
-   `editAccess()`
-   `editCreators()`
-   `editBiblio()`

gif of shiny app in use

Completed metadata tables in this example will look like this:

`access.csv` has one row for each file

<table>
<thead>
<tr>
<th style="text-align:left;">
fileName
</th>
<th style="text-align:left;">
name
</th>
<th style="text-align:left;">
contentUrl
</th>
<th style="text-align:left;">
fileFormat
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
StockInfo.csv
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
CSV
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
CSV
</td>
</tr>
<tr>
<td style="text-align:left;">
SourceInfo.csv
</td>
<td style="text-align:left;">
SourceInfo.csv
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
CSV
</td>
</tr>
</tbody>
</table>
`attributes.csv` has one row for each variable in each file

<table>
<thead>
<tr>
<th style="text-align:left;">
fileName
</th>
<th style="text-align:left;">
variableName
</th>
<th style="text-align:left;">
description
</th>
<th style="text-align:left;">
unitText
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Stock.ID
</td>
<td style="text-align:left;">
Unique stock identifier
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Species
</td>
<td style="text-align:left;">
species of stock
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Stock
</td>
<td style="text-align:left;">
Stock name, generally river where stock is found
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Ocean.Region
</td>
<td style="text-align:left;">
Ocean region
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Region
</td>
<td style="text-align:left;">
Region of stock
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
BroodTables.csv
</td>
<td style="text-align:left;">
Sub.Region
</td>
<td style="text-align:left;">
Sub.Region of stock
</td>
<td style="text-align:left;">
NA
</td>
</tr>
</tbody>
</table>
`biblio.csv` is one row containing descriptors including spatial and temporal coverage

<table>
<thead>
<tr>
<th style="text-align:left;">
title
</th>
<th style="text-align:left;">
description
</th>
<th style="text-align:left;">
datePublished
</th>
<th style="text-align:left;">
citation
</th>
<th style="text-align:left;">
keywords
</th>
<th style="text-align:left;">
license
</th>
<th style="text-align:left;">
funder
</th>
<th style="text-align:left;">
geographicDescription
</th>
<th style="text-align:right;">
northBoundCoord
</th>
<th style="text-align:right;">
eastBoundCoord
</th>
<th style="text-align:right;">
southBoundCoord
</th>
<th style="text-align:right;">
westBoundCoord
</th>
<th style="text-align:left;">
wktString
</th>
<th style="text-align:left;">
startDate
</th>
<th style="text-align:left;">
endDate
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Compiled annual statewide Alaskan salmon escapement counts, 1921-2017
</td>
<td style="text-align:left;">
The number of mature salmon migrating from the marine environment to freshwater streams is defined as escapement. Escapement data are the enumeration of these migrating fish as they pass upstream, and are a widely used index of spawning salmon abundance. These data are important for fisheries management, since most salmon harvest occurs near the mouths of rivers where salmon spawn during this migration. Escapement data are collected in a variety of ways. Stationary projects utilize observers stationed along freshwater corridors who count salmon as they pass upriver through weirs or past elevated towers. Sonar equipment placed in the river can also give a stationary escapement count. These counts usually represent a sample, and are expanded to represent a 24h period. Escapement data can also be collected using aerial surveys, where observers in an aircraft provide an index to estimate escapement. In general, escapement counts do not represent total abundance, but instead an index of abundance. Surveys are usually timed to coincide with peak spawning activity, generally in the summer, but in the case of Coho salmon in the fall as well. Some data about non-salmon species are also included. This dataset contains compiled annual data from multiple sources. The .Rmd merges all datasets, identifies and flags duplicate records, and performs quality assurance checks by filtering and graphing results.
</td>
<td style="text-align:left;">
2018-02-12 08:00:00
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
salmon, alaska, escapement
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
78
</td>
<td style="text-align:right;">
-131
</td>
<td style="text-align:right;">
47
</td>
<td style="text-align:right;">
-171
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
1921-01-01 08:00:00
</td>
<td style="text-align:left;">
2017-01-01 08:00:00
</td>
</tr>
</tbody>
</table>
`creators.csv` has one row for each of the dataset authors

<table>
<thead>
<tr>
<th style="text-align:left;">
id
</th>
<th style="text-align:left;">
givenName
</th>
<th style="text-align:left;">
familyName
</th>
<th style="text-align:left;">
affiliation
</th>
<th style="text-align:left;">
email
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
Jeanette
</td>
<td style="text-align:left;">
Clark
</td>
<td style="text-align:left;">
National Center for Ecological Analysis and Synthesis
</td>
<td style="text-align:left;">
<jclark@nceas.ucsb.edu>
</td>
</tr>
<tr>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
Rich
</td>
<td style="text-align:left;">
Brenner
</td>
<td style="text-align:left;">
Alaska Department of Fish and Game
</td>
<td style="text-align:left;">
richard.brenner.alaska.gov
</td>
</tr>
</tbody>
</table>
### Save json-ld file

-   `write_spice()` generates a json-ld file ("linked data") to aid in [dataset discovery](https://developers.google.com/search/docs/data-types/dataset), creation of more extensive metadata (e.g. [EML](https://knb.ecoinformatics.org/#api)), and creating a website.

### Build website

-   `build_site()` generates an index.html file in the repository `docs` folder, to create a website that shows a simple view of the dataset with the metadata and an interactive map. For example, this [repository](https://github.com/amoeba/dataspice-example) results in a [website](https://amoeba.github.io/dataspice-example/)

![dataspice-website](man/figures/screenshot.png)

Contributors
------------

This package was developed at rOpenSci's 2018 unconf by (in alphabetical order):

-   [Carl Boettiger](https://github.com/cboettig)
-   [Scott Chamberlain](https://github.com/sckott)
-   [Auriel Fournier](https://github.com/aurielfournier)
-   [Kelly Hondula](https://github.com/khondula)
-   [Anna Krystalli](https://github.com/annakrystalli)
-   [Bryce Mecum](https://github.com/amoeba)
-   [Maëlle Salmon](https://github.com/maelle)
-   [Kate Webbink](https://github.com/magpiedin)
-   [Kara Woo](https://github.com/karawoo)
