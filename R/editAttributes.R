#' Shiny App for editing the metadata attributes table
#'
#' @param DF the imported attributes.csv dataframe

#' @export
#'
#' @examples
#' \dontrun{
#' editTable(DF = attributes)
#'
#'}

editAttributes <- function(DF, 
                      outdir=getwd(), 
                      outfilename="attributes"){
  ui <- shinyUI(fluidPage(
    
    titlePanel("Populate the Attributes Metadata Table"),
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
        DF$description <- as.character(DF$description)
        DF$unitText <- as.character(DF$unitText)
        rhandsontable(DF, 
                      useTypes = TRUE, 
                      stretchH = "all")
    })
    
    ## Save 
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      write.csv(finalDF, file=file.path(outdir, 
                        sprintf("%s.csv", outfilename)),
                row.names = FALSE)
    })
    
    ## Message
    output$message <- renderUI({
      if(input$save==0){
        helpText(sprintf("This table will be saved in folder \"%s\" once you press the Save button.", outdir))
      }else{
        outfile <- "attributes.csv"
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
