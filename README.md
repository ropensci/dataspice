
<!-- README.md is generated from README.Rmd. Please edit that file -->
dataspice
=========

The goal of dataspice is to make it easier for researchers to create basic, lightweight and concise metadata files for their datasets. These basic files can then be used to:

-   make useful information available during analysis.
-   create a helpful dataset README webpage.
-   produce more complex metadata formats to aid dataset discovery.

Metadata fields are based on [schema.org](http://schema.org/Dataset) and other metadata standards.

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

| fileName        | variableName                        | description | unitText |
|:----------------|:------------------------------------|:------------|:---------|
| BroodTables.csv | Stock.ID                            | NA          | NA       |
| BroodTables.csv | Species                             | NA          | NA       |
| BroodTables.csv | Stock                               | NA          | NA       |
| BroodTables.csv | Ocean.Region                        | NA          | NA       |
| BroodTables.csv | Region                              | NA          | NA       |
| BroodTables.csv | Sub.Region                          | NA          | NA       |
| BroodTables.csv | Jurisdiction                        | NA          | NA       |
| BroodTables.csv | Lat                                 | NA          | NA       |
| BroodTables.csv | Lon                                 | NA          | NA       |
| BroodTables.csv | UseFlag                             | NA          | NA       |
| BroodTables.csv | BroodYear                           | NA          | NA       |
| BroodTables.csv | TotalEscapement                     | NA          | NA       |
| BroodTables.csv | R0.1                                | NA          | NA       |
| BroodTables.csv | R0.2                                | NA          | NA       |
| BroodTables.csv | R0.3                                | NA          | NA       |
| BroodTables.csv | R0.4                                | NA          | NA       |
| BroodTables.csv | R0.5                                | NA          | NA       |
| BroodTables.csv | R1.1                                | NA          | NA       |
| BroodTables.csv | R1.2                                | NA          | NA       |
| BroodTables.csv | R1.3                                | NA          | NA       |
| BroodTables.csv | R1.4                                | NA          | NA       |
| BroodTables.csv | R1.5                                | NA          | NA       |
| BroodTables.csv | R2.1                                | NA          | NA       |
| BroodTables.csv | R2.2                                | NA          | NA       |
| BroodTables.csv | R2.3                                | NA          | NA       |
| BroodTables.csv | R2.4                                | NA          | NA       |
| BroodTables.csv | R3.1                                | NA          | NA       |
| BroodTables.csv | R3.2                                | NA          | NA       |
| BroodTables.csv | R3.3                                | NA          | NA       |
| BroodTables.csv | R3.4                                | NA          | NA       |
| BroodTables.csv | R4.1                                | NA          | NA       |
| BroodTables.csv | R4.2                                | NA          | NA       |
| BroodTables.csv | R4.3                                | NA          | NA       |
| BroodTables.csv | TotalRecruits                       | NA          | NA       |
| SourceInfo.csv  | Source.ID                           | NA          | NA       |
| SourceInfo.csv  | Source                              | NA          | NA       |
| StockInfo.csv   | X1                                  | NA          | NA       |
| StockInfo.csv   | Stock.ID                            | NA          | NA       |
| StockInfo.csv   | Species                             | NA          | NA       |
| StockInfo.csv   | Stock                               | NA          | NA       |
| StockInfo.csv   | Date.data.obtained                  | NA          | NA       |
| StockInfo.csv   | Date.data.incorporated              | NA          | NA       |
| StockInfo.csv   | Ocean.Region                        | NA          | NA       |
| StockInfo.csv   | Region                              | NA          | NA       |
| StockInfo.csv   | Sub.Region                          | NA          | NA       |
| StockInfo.csv   | Jurisdiction                        | NA          | NA       |
| StockInfo.csv   | Lat                                 | NA          | NA       |
| StockInfo.csv   | Lon                                 | NA          | NA       |
| StockInfo.csv   | Source.ID                           | NA          | NA       |
| StockInfo.csv   | Comment..we.will.update.this.later. | NA          | NA       |

**Shiny apps**

Each of the metadata templates can be edited interactively using a shiny app

-   `editAttritubes()` opens a shiny app that can be used to edit `attributes.csv`. The shiny app dispalys the attributes table and lets the user fill in an informative description and units (e.g. meters, hectares, etc.) for each variable.
-   `editAccess()`
-   `editCreators()`
-   `editBiblio()`

gif of shiny app in use

Completed metadata tables in this example will look like this:

| fileName        | name            | contentUrl | fileFormat |
|:----------------|:----------------|:-----------|:-----------|
| StockInfo.csv   | StockInfo.csv   | NA         | CSV        |
| BroodTables.csv | BroodTables.csv | NA         | CSV        |
| SourceInfo.csv  | SourceInfo.csv  | NA         | CSV        |

| fileName        | variableName                        | description                                                                                                   | unitText |
|:----------------|:------------------------------------|:--------------------------------------------------------------------------------------------------------------|:---------|
| BroodTables.csv | Stock.ID                            | Unique stock identifier                                                                                       | NA       |
| BroodTables.csv | Species                             | species of stock                                                                                              | NA       |
| BroodTables.csv | Stock                               | Stock name, generally river where stock is found                                                              | NA       |
| BroodTables.csv | Ocean.Region                        | Ocean region                                                                                                  | NA       |
| BroodTables.csv | Region                              | Region of stock                                                                                               | NA       |
| BroodTables.csv | Sub.Region                          | Sub.Region of stock                                                                                           | NA       |
| BroodTables.csv | Jurisdiction                        | Management jurisdiction                                                                                       | NA       |
| BroodTables.csv | Lat                                 | Latitude                                                                                                      | degree   |
| BroodTables.csv | Lon                                 | Longitude                                                                                                     | degree   |
| BroodTables.csv | UseFlag                             | Indicates if data should be used in analysis                                                                  | NA       |
| BroodTables.csv | BroodYear                           | Brood Year                                                                                                    | NA       |
| BroodTables.csv | TotalEscapement                     | Total escapement value                                                                                        | number   |
| BroodTables.csv | R0.1                                | number of recruits in 0.1 age class                                                                           | number   |
| BroodTables.csv | R0.2                                | number of recruits in 0.2 age class                                                                           | number   |
| BroodTables.csv | R0.3                                | number of recruits in 0.3 age class                                                                           | number   |
| BroodTables.csv | R0.4                                | number of recruits in 0.4 age class                                                                           | number   |
| BroodTables.csv | R0.5                                | number of recruits in 0.5 age class                                                                           | number   |
| BroodTables.csv | R1.1                                | number of recruits in 1.1 age class                                                                           | number   |
| BroodTables.csv | R1.2                                | number of recruits in 1.2 age class                                                                           | number   |
| BroodTables.csv | R1.3                                | number of recruits in 1.3 age class                                                                           | number   |
| BroodTables.csv | R1.4                                | number of recruits in 1.4 age class                                                                           | number   |
| BroodTables.csv | R1.5                                | number of recruits in 1.5 age class                                                                           | number   |
| BroodTables.csv | R2.1                                | number of recruits in 2.1 age class                                                                           | number   |
| BroodTables.csv | R2.2                                | number of recruits in 2.2 age class                                                                           | number   |
| BroodTables.csv | R2.3                                | number of recruits in 2.3 age class                                                                           | number   |
| BroodTables.csv | R2.4                                | number of recruits in 2.4 age class                                                                           | number   |
| BroodTables.csv | R3.1                                | number of recruits in 3.1 age class                                                                           | number   |
| BroodTables.csv | R3.2                                | number of recruits in 3.2 age class                                                                           | number   |
| BroodTables.csv | R3.3                                | number of recruits in 3.3 age class                                                                           | number   |
| BroodTables.csv | R3.4                                | number of recruits in 3.4 age class                                                                           | number   |
| BroodTables.csv | R4.1                                | number of recruits in 4.1 age class                                                                           | number   |
| BroodTables.csv | R4.2                                | number of recruits in 4.2 age class                                                                           | number   |
| BroodTables.csv | R4.3                                | number of recruits in 4.3 age class                                                                           | number   |
| BroodTables.csv | TotalRecruits                       | number of total recruits                                                                                      | number   |
| SourceInfo.csv  | Source.ID                           | Source.ID as seen in stock info table                                                                         | NA       |
| SourceInfo.csv  | Source                              | Source description                                                                                            | NA       |
| StockInfo.csv   | Stock.ID                            | Unique stock identifier                                                                                       | NA       |
| StockInfo.csv   | Species                             | species of stock                                                                                              | NA       |
| StockInfo.csv   | Stock                               | Stock name, generally river where stock is found                                                              | NA       |
| StockInfo.csv   | Date.data.obtained                  | Date data was obtained; if original data did not specify the day, the day is recorded as 01                   | NA       |
| StockInfo.csv   | Date.data.incorporated              | Date data was incorporated into database; if original data did not specify the day, the day is recorded as 01 | NA       |
| StockInfo.csv   | Ocean.Region                        | Ocean region                                                                                                  | NA       |
| StockInfo.csv   | Region                              | Region of stock                                                                                               | NA       |
| StockInfo.csv   | Sub.Region                          | Sub.Region of stock                                                                                           | NA       |
| StockInfo.csv   | Jurisdiction                        | Management jurisdiction                                                                                       | NA       |
| StockInfo.csv   | Lat                                 | Latitude                                                                                                      | degree   |
| StockInfo.csv   | Lon                                 | Longitude                                                                                                     | degree   |
| StockInfo.csv   | Source.ID                           | Source.ID, matches source.ID in source info file                                                              | NA       |
| StockInfo.csv   | Comment..we.will.update.this.later. | stock comments                                                                                                | NA       |

| title                                                                 | description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | datePublished       | citation | keywords                   | license | funder | geographicDescription |  northBoundCoord|  eastBoundCoord|  southBoundCoord|  westBoundCoord| wktString | startDate           | endDate             |
|:----------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------|:---------|:---------------------------|:--------|:-------|:----------------------|----------------:|---------------:|----------------:|---------------:|:----------|:--------------------|:--------------------|
| Compiled annual statewide Alaskan salmon escapement counts, 1921-2017 | The number of mature salmon migrating from the marine environment to freshwater streams is defined as escapement. Escapement data are the enumeration of these migrating fish as they pass upstream, and are a widely used index of spawning salmon abundance. These data are important for fisheries management, since most salmon harvest occurs near the mouths of rivers where salmon spawn during this migration. Escapement data are collected in a variety of ways. Stationary projects utilize observers stationed along freshwater corridors who count salmon as they pass upriver through weirs or past elevated towers. Sonar equipment placed in the river can also give a stationary escapement count. These counts usually represent a sample, and are expanded to represent a 24h period. Escapement data can also be collected using aerial surveys, where observers in an aircraft provide an index to estimate escapement. In general, escapement counts do not represent total abundance, but instead an index of abundance. Surveys are usually timed to coincide with peak spawning activity, generally in the summer, but in the case of Coho salmon in the fall as well. Some data about non-salmon species are also included. This dataset contains compiled annual data from multiple sources. The .Rmd merges all datasets, identifies and flags duplicate records, and performs quality assurance checks by filtering and graphing results. | 2018-02-12 08:00:00 | NA       | salmon, alaska, escapement | NA      | NA     | NA                    |               78|            -131|               47|            -171| NA        | 1921-01-01 08:00:00 | 2017-01-01 08:00:00 |

| id  | givenName | familyName | affiliation                                           | email                      |
|:----|:----------|:-----------|:------------------------------------------------------|:---------------------------|
| NA  | Jeanette  | Clark      | National Center for Ecological Analysis and Synthesis | <jclark@nceas.ucsb.edu>    |
| NA  | Rich      | Brenner    | Alaska Department of Fish and Game                    | richard.brenner.alaska.gov |

### Save json-ld file

-   `write_spice()` generates a json-ld file ("linked data") to aid in [dataset discovery](https://developers.google.com/search/docs/data-types/dataset), creation of more extensive metadata (e.g. [EML](https://knb.ecoinformatics.org/#api)), and creating a website.

### Build website

-   `build_site()` generates an index.html file in the repository `docs` folder, to create a website that shows a simple view of the dataset with the metadata and an interactive map.

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
