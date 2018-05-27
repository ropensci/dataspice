#' Shiny App for editing the metadata biblio table
#'
#' @param DF the imported biblio.csv dataframe
#' @param outdir The directory to save the edited biblio info to
#' @param outfilename The filename to save with. Defaults to biblio.csv.
#'
#' @import shiny
#' @import rhandsontable

#' @export
#'
#' @examples
#' \dontrun{
#' editTable(DF = attributes)
#'
#'}

edit_biblio <- function(DF,
                         outdir=getwd(),
                         outfilename="biblio"){
  ui <- shinyUI(fluidPage(

    titlePanel("Populate the Biblio Metadata Table"),
    sidebarLayout(
      sidebarPanel(
        helpText("Shiny app to read in the dataspice metadata templates and populate with usersupplied data"),

        h6('fileName = the name of the input data file(s). Do Not Change.'),
        h6("variableName = the name of the measured variable. Do Not Change."),
        h6('Description = a written description of what that measured variable is'),
        h6("unitText = the units the variable was measured in"),

        br(),

        wellPanel(
          h3("Save table"),
          div(class='row',
              div(class="col-sm-6",
                  actionButton("save", "Save"))
          )
        )

      ),

      mainPanel(
        wellPanel(
          uiOutput("message", inline=TRUE)
        ),
        rHandsontableOutput("hot"),
        br()

      )
    )
  ))

  server <- shinyServer(function(input, output) {

    values <- reactiveValues()

    output$hot <- renderRHandsontable({
      rows_to_add <- as.data.frame(matrix(nrow=1,
                                          ncol=ncol(DF)))

      colnames(rows_to_add) <- colnames(DF)
      DF <- rows_to_add
      DF[,1] <- as.character(DF[,1])
      DF$description <- as.character(DF$description)
      DF$datePublished <- as.character(DF$datePublished)
      DF$citation <- as.character(DF$citation)
      DF$keywords <- as.character(DF$keywords)
      DF$license <- as.character(DF$license)
      DF$funder <- as.character(DF$funder)
      DF$geographicDescription <- as.character(DF$geographicDescription)
      DF$northBoundCoord <- as.character(DF$northBoundCoord)
      DF$eastBoundCoord <- as.character(DF$eastBoundCoord)
      DF$southBoundCoord <- as.character(DF$southBoundCoord)
      DF$westBoundCoord <- as.character(DF$westBoundCoord)
        DF$wktString <- as.character(DF$wktString)
      DF$startDate <- as.character(DF$startDate)
      DF$endDate <- as.character(DF$endDate)

      rhandsontable(DF,
                    useTypes = TRUE,
                    stretchH = "all")
    })

    ## Save
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      utils::write.csv(finalDF, file=file.path(outdir,
                                        sprintf("%s.csv", outfilename)),
                row.names = FALSE)
    })

    ## Message
    output$message <- renderUI({
      if(input$save==0){
        helpText(sprintf("This table will be saved in folder \"%s\" once you press the Save button.", outdir))
      }else{
        outfile <- "biblio.csv"
        fun <- 'read.csv'
        list(helpText(sprintf("File saved: \"%s\".",
                              file.path(outdir, outfile))),
             helpText(sprintf("Type %s(\"%s\") to get it.",
                              fun, outfile)))
      }
    })

  })

  ## run app
  runApp(list(ui=ui, server=server))
  return(invisible())
}
