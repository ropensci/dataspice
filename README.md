
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dataspice

[![Build
Status](https://travis-ci.com/ropenscilabs/dataspice.svg?branch=master)](https://travis-ci.com/ropenscilabs/dataspice)

The goal of dataspice is to make it easier for researchers to create
basic, lightweight and concise metadata files for their datasets. These
basic files can then be used to:

  - make useful information available during analysis.
  - create a helpful dataset README webpage.
  - produce more complex metadata formats to aid dataset discovery.

Metadata fields are based on [schema.org](http://schema.org/Dataset) and
other metadata standards.

## Example

A fully worked example can be found
[here](https://github.com/amoeba/dataspice-example) and a live preview
of the output [here](https://amoeba.github.io/dataspice-example/). An
example of how Google sees this can be found
[here](https://search.google.com/structured-data/testing-tool/u/0/#url=https%3A%2F%2Famoeba.github.io%2Fdataspice-example%2F).

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ropenscilabs/dataspice")
```

## Workflow

``` r
create_spice()
write_spice() 
build_site()
```

![worfklowdiagram](man/figures/dataspice_workflow.png)

### Create spice

  - `create_spice()` creates template metadata spreadsheets in a folder
    (by default created in the `data` folder)

The template files are:

  - **attributes.csv** - explains each of the variables in the dataset
  - **biblio.csv** - for spatial and temporal coverage, dataset name,
    keywords, etc.
  - **access.csv** - for files and file types
  - **creators.csv** - for data authors

### Fill in templates

The user needs to fill in the details of the 4 template files. These csv
files can be directly modified, or they can be edited using some helper
functions and/or a shiny app. **Helper functions**

  - `prep_attributes()` populates the **fileName** and **variableName**
    columns of the attributes.csv file using the header row of the data
    files.

To see an example of how this works, load the data files that ship with
the package:

``` r
data_files <- list.files(system.file("example-dataset/", 
                                     package = "dataspice"), 
                         pattern = ".csv",
                        full.names = TRUE)
```

This function assumes that the metadata templates are in a folder called
`metadata` within a `data` folder.

``` r
attributes_path <- here::here("data", "metadata",
 "attributes.csv")
```

Using `purrr::map()`, this function can be applied over multiple files
to populate the header names

``` r
data_files %>% purrr::map(~prep_attributes(.x, attributes_path),
                         attributes_path = attributes_path)
```

The output of `prep_attributes()` has the first two columns filled out:

| fileName        | variableName | description | unitText |
| :-------------- | :----------- | :---------- | :------- |
| BroodTables.csv | Stock.ID     | NA          | NA       |
| BroodTables.csv | Species      | NA          | NA       |
| BroodTables.csv | Stock        | NA          | NA       |
| BroodTables.csv | Ocean.Region | NA          | NA       |
| BroodTables.csv | Region       | NA          | NA       |
| BroodTables.csv | Sub.Region   | NA          | NA       |

**Shiny apps**

Each of the metadata templates can be edited interactively using a shiny
app

  - `editAttritubes()` opens a shiny app that can be used to edit
    `attributes.csv`. The shiny app dispalys the attributes table and
    lets the user fill in an informative description and units
    (e.g. meters, hectares, etc.) for each variable.
  - `editAccess()`
  - `editCreators()`
  - `editBiblio()`

![shinygif](man/figures/before123.gif)

Completed metadata tables in this example will look like this:

`access.csv` has one row for each
    file

    #> Warning in rbind(names(probs), probs_f): number of columns of result is not
    #> a multiple of vector length (arg 2)
    #> Warning: 1 parsing failure.
    #> row # A tibble: 1 x 5 col     row col   expected  actual    file                                     expected   <int> <chr> <chr>     <chr>     <chr>                                    actual 1     4 <NA>  4 columns 1 columns '/Library/Frameworks/R.framework/Versio… file # A tibble: 1 x 5

| fileName        | name            | contentUrl | fileFormat |
| :-------------- | :-------------- | :--------- | :--------- |
| StockInfo.csv   | StockInfo.csv   | NA         | CSV        |
| BroodTables.csv | BroodTables.csv | NA         | CSV        |
| SourceInfo.csv  | SourceInfo.csv  | NA         | CSV        |
| NA              | NA              | NA         | NA         |

`attributes.csv` has one row for each variable in each
file

| fileName        | variableName | description                                      | unitText |
| :-------------- | :----------- | :----------------------------------------------- | :------- |
| BroodTables.csv | Stock.ID     | Unique stock identifier                          | NA       |
| BroodTables.csv | Species      | species of stock                                 | NA       |
| BroodTables.csv | Stock        | Stock name, generally river where stock is found | NA       |
| BroodTables.csv | Ocean.Region | Ocean region                                     | NA       |
| BroodTables.csv | Region       | Region of stock                                  | NA       |
| BroodTables.csv | Sub.Region   | Sub.Region of stock                              | NA       |

`biblio.csv` is one row containing descriptors including spatial and
temporal
coverage

| title                                                                 | description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | datePublished       | citation | keywords                   | license | funder | geographicDescription | northBoundCoord | eastBoundCoord | southBoundCoord | westBoundCoord | wktString | startDate           | endDate             |
| :-------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------ | :------- | :------------------------- | :------ | :----- | :-------------------- | --------------: | -------------: | --------------: | -------------: | :-------- | :------------------ | :------------------ |
| Compiled annual statewide Alaskan salmon escapement counts, 1921-2017 | The number of mature salmon migrating from the marine environment to freshwater streams is defined as escapement. Escapement data are the enumeration of these migrating fish as they pass upstream, and are a widely used index of spawning salmon abundance. These data are important for fisheries management, since most salmon harvest occurs near the mouths of rivers where salmon spawn during this migration. Escapement data are collected in a variety of ways. Stationary projects utilize observers stationed along freshwater corridors who count salmon as they pass upriver through weirs or past elevated towers. Sonar equipment placed in the river can also give a stationary escapement count. These counts usually represent a sample, and are expanded to represent a 24h period. Escapement data can also be collected using aerial surveys, where observers in an aircraft provide an index to estimate escapement. In general, escapement counts do not represent total abundance, but instead an index of abundance. Surveys are usually timed to coincide with peak spawning activity, generally in the summer, but in the case of Coho salmon in the fall as well. Some data about non-salmon species are also included. This dataset contains compiled annual data from multiple sources. The .Rmd merges all datasets, identifies and flags duplicate records, and performs quality assurance checks by filtering and graphing results. | 2018-02-12 08:00:00 | NA       | salmon, alaska, escapement | NA      | NA     | NA                    |              78 |          \-131 |              47 |          \-171 | NA        | 1921-01-01 08:00:00 | 2017-01-01 08:00:00 |

`creators.csv` has one row for each of the dataset
authors

| id | givenName | familyName | affiliation                                           | email                      |
| :- | :-------- | :--------- | :---------------------------------------------------- | :------------------------- |
| NA | Jeanette  | Clark      | National Center for Ecological Analysis and Synthesis | <jclark@nceas.ucsb.edu>    |
| NA | Rich      | Brenner    | Alaska Department of Fish and Game                    | richard.brenner.alaska.gov |

### Save json-ld file

  - `write_spice()` generates a json-ld file (“linked data”) to aid in
    [dataset
    discovery](https://developers.google.com/search/docs/data-types/dataset),
    creation of more extensive metadata (e.g.
    [EML](https://knb.ecoinformatics.org/#api)), and creating a website.

### Build website

  - `build_site()` generates an index.html file in the repository `docs`
    folder, to create a website that shows a simple view of the dataset
    with the metadata and an interactive map. For example, this
    [repository](https://github.com/amoeba/dataspice-example) results in
    a [website](https://amoeba.github.io/dataspice-example/)

![dataspice-website](man/figures/screenshot.png)

## Contributors

This package was developed at rOpenSci’s 2018 unconf by (in alphabetical
order):

  - [Carl Boettiger](https://github.com/cboettig)
  - [Scott Chamberlain](https://github.com/sckott)
  - [Auriel Fournier](https://github.com/aurielfournier)
  - [Kelly Hondula](https://github.com/khondula)
  - [Anna Krystalli](https://github.com/annakrystalli)
  - [Bryce Mecum](https://github.com/amoeba)
  - [Maëlle Salmon](https://github.com/maelle)
  - [Kate Webbink](https://github.com/magpiedin)
  - [Kara Woo](https://github.com/karawoo)
