#' Shiny App for editing the metadata access table

#' @param filepath the filepath to the dataspice access.csv file. Defaults to current
#'   <project_root>/data/metadata/access.csv.
#'
#' @import shiny
#' @import rhandsontable
#' @import ggplot2
#' @export
#'
#' @examples
#' \dontrun{
#' edit_access()
#'
#'}

edit_access <- function(filepath = here::here("data", "metadata", "access.csv")){
  ui <- shinyUI(fluidPage(

    titlePanel("Populate the Access Metadata Table"),
    helpText("Shiny app to read in the", code("dataspice"), "metadata templates and populate with user supplied metadata"),
    sidebarLayout(
      sidebarPanel(
        # fileName	name	contentUrl	fileFormat

        h6('fileName = the filename of the input data file(s). Do Not Change.'),
        h6("variableName = the human readable name of the measured variable."),
        h6('contentUrl = a url from where that data came, if applicable'),
        h6("fileFormat = the file format. Do Not. Change"),

        br(),

        wellPanel(
          h3("Save table"),
          div(class='row',
              div(class="col-sm-6",
                  actionButton("save", "Save Changes"))
          )
        )

      ),

      mainPanel(
        wellPanel(
          uiOutput("message", inline=TRUE)
        ),
        helpText("Right-click on the table to delete/insert rows.",
                 "Double-click on a cell to edit"),
        rHandsontableOutput("hot"),
        br()

      )
    )
  ))

  server <- shinyServer(function(input, output) {

    values <- reactiveValues()

    dat <- readr::read_csv(file = filepath,
                           col_types = "cccc")
    # pad if no data
    if(nrow(dat) == 0){
      dat <- dplyr::add_row(dat)
    }

    output$hot <- renderRHandsontable({

      rhandsontable(dat,
                    useTypes = FALSE,
                    stretchH = "all")
    })

    ## Save
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      readr::write_csv(
        # remove padding if none edited
        dplyr::filter_all(finalDF, dplyr::any_vars(!is.na(.))),
        path = filepath)
    })


    ## Message
    output$message <- renderUI({
      outfile <- basename(filepath)
      outdir <- gsub(outfile, "", filepath)
      if(input$save==0){
        helpText("This table will be saved as file: ", code(outfile),
                 "in directory:", code(outdir),
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
