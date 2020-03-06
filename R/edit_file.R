#' Shinyapps for editing dataspice metadata tables
#'
#' Launch shinyapp for editing individual `dataspice` metadata tables. Use `edit_*()` where `*`
#' is one of the four `dataspice` metadata tables **`attributes`, `biblio`, `access` or `creators`**.
#' @param metadata_dir the directory containing the `dataspice` metadata `.csv` files. Defaults to
#'   `data/metadata/` directory in **current project root**.
#' @export
#' @examples
#' \dontrun{
#' edit_attributes()
#' edit_biblio()
#' edit_access()
#' edit_creators()
#'
#' # Specifying a different dataspice metadata directory
#' edit_attributes(metadata_dir = "analysis/data/metadata/"))
#'}
edit_attributes <- function(metadata_dir = here::here("data", "metadata")) {
  edit_file(metadata_dir, "attributes.csv")
}

#' @inherit edit_attributes
#' @export
edit_biblio <- function(metadata_dir = here::here("data", "metadata")) {
  edit_file(metadata_dir, "biblio.csv")
}

#' @inherit edit_attributes
#' @export
edit_access <- function(metadata_dir = here::here("data", "metadata")) {
  edit_file(metadata_dir, "access.csv")
}

#' @inherit edit_attributes
#' @export
edit_creators <- function(metadata_dir = here::here("data", "metadata")) {
  edit_file(metadata_dir, "creators.csv")
}


# Shinyapps for editing dataspice metadata tables
#' @import shiny
#' @import rhandsontable
#' @import ggplot2
#' @importFrom dplyr "%>%"
edit_file <- function(metadata_dir = here::here("data", "metadata"),
                      file = c("attributes.csv", "biblio.csv", "access.csv", "creators.csv")){

  file <- match.arg(file)

  ui <- shinyUI(
    fluidPage(
      titlePanel(paste0("Populate the ", file," table")),
      helpText("Shiny app to read in the", code("dataspice"),
               "metadata templates and populate with user supplied metadata"),

      # Header panel
      wellPanel(
        fluidRow(
          column(8,
                 uiOutput("message", inline=TRUE)
          ),
          column(4, align="right",
                 h3("Save table"),
                 actionButton("save", "Save Changes"))
        )
      ),
      # side panel
      sidebarLayout(
        # side panel contains reference details. conditional on file.
        sidebarPanel(
          if (file == "attributes.csv"){
            list(
              h4("Variable attribute metadata"),
              h6('fileName = the name of the input data file(s). Do Not Change.'),
              h6("variableName = the name of the measured variable. Do Not Change."),
              h6('Description = a written description of what that measured variable is'),
              h6("unitText = the units the variable was measured in"),
              helpText("use", code("prep_attributes()"), "to extract", strong("variableName"), "from data files")
            )
          },
          if (file == "biblio.csv"){
            list(
              h4("Bibliographic metadata"),
              h6('title = text: Title of the dataset(s) described.'),
              h6("description = text: Description of the dataset(s) described"),
              h6('datePublished = text: The date published in ISO 8601 format (YYYY-MM-DD)'),
              h6("citation = text: citation for the dataset(s) described"),
              h6("keywords = text: keywords, separated by commas, associated with the dataset(s) described"),
              h6("license = text: license under which data are published"),
              h6("funder = text: Name of funders associated with the work through which data where generated"),

              br(),
              h4("Spatial Coverage metadata"),
              h6('geographicDescription = text: Description of the area of study'),
              h6("northBoundCoord = numeric or text: southern latitudinal boundary of the data coverage area. For example 37.42242 (WGS 84)"),
              h6("eastBoundCoord = numeric or text: eastern longitudinal boundary of the data coverage area. For example -122.08585 (WGS 84)"),
              h6("southBoundCoord = numeric or text: northern latitudinal boundary of the data coverage area."),
              h6("westBoundCoord = numeric or text: western longitudinal boundary of the data coverage area."),
              h6("wktString = text: string of Well-known Text (WKT) formatted representation of geometry. see:",
                 a(href="https://ropensci.org/tutorials/wellknown_tutorial/", "pkg", code("wellknown")), "for details."),
              helpText("To provide a single point to describe the spatial
                             aspect of the dataset, provide the same coordinates
                             for east-west and north-south boundary definition"),
              br(),
              h4("Temporal Coverage metadata"),
              h6('startDate = text: The start date of the data temporal coverage in ISO 8601 format (YYYY-MM-DD)'),
              h6("endDate = text: The end date of the data temporal coverage in ISO 8601 format (YYYY-MM-DD)"),
              br(),
              plotOutput("bbmap")
            )},
          if (file == "access.csv"){
            list(
              h6('fileName = the filename of the input data file(s).'),
              h6("name = the human readable name for the file."),
              h6('contentUrl = a url to where the data is hosted, if applicable'),
              h6("encodingFormat = the file format.")
            )},
          if (file == "creators.csv"){
            list(
              h6('ID = text: ORCID or another ID'),
              h6("name = text: the name of the creator."),
              h6("unitText = text: affiliation of the creator.'")
            )}
        ),
        mainPanel(
          # table editing helptext
          helpText("Right-click on the table to delete/insert rows.",
                   "Double-click on a cell to edit"),
          # table
          rHandsontableOutput("hot"),
          br()
        )
      )
    )
  )

  server <- shinyServer(function(input, output) {

    filepath <- file.path(metadata_dir, file)


    ## bounding box map
    if (file == "biblio.csv"){
      output$bbmap <- renderPlot({
        world <- ggplot2::map_data("world")
        ggplot2::ggplot() +
          ggplot2::geom_map(data=world, map=world,
                            aes(x=long, y=lat, map_id=region),
                            color="black",fill="#7f7f7f")
      })
    }

    values <- reactiveValues()

    dat <- readr::read_csv(file = filepath,
                           col_types = readr::cols(
                             .default = readr::col_character()
                           ))
    # pad if no data
    if(nrow(dat) == 0){
      dat <- dplyr::add_row(dat)
    }

    output$hot <- renderRHandsontable({
      rhandsontable(dat,
                    useTypes = TRUE,
                    stretchH = "all") %>%
        hot_context_menu(allowColEdit = FALSE)
    })

    ## Save
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      # remove padding if none edited
      finalDF[!apply(is.na(finalDF) | finalDF == "", 1, all),] %>%
        readr::write_csv(path = filepath)
    })


    ## Message
    output$message <- renderUI({
      if(input$save==0){
        helpText("This table will be saved as file: ", code(file),
                 "in directory:", code(metadata_dir),
                 " once you press the ",
                 strong("Save Changes"),
                 "button.")
      }else{
        list(helpText("File saved at path:", code(filepath)),
             helpText("Use", code(paste0("readr::read_csv('",filepath,"')")) ,
                      "to read it."))
      }
    })

  })

  ## run app
  runApp(list(ui=ui, server=server))
  return(invisible())
}
