#' run shiny app : making lines by click on the map
#'
#' @return shiny::shinyApp
#' @export
#'
#' @examples
#' # Only run this example in interactive R sessions
#' # draw_lines()
draw_lines <- function(){

  head <- dashboardHeader(disable=TRUE)
  sidebar <- dashboardSidebar(disable=TRUE)

  body <- dashboardBody(
    fluidRow(
      box(width=8, leafletOutput('map', height=800)),
      box(width=4,
          textInput('save_file_name', label=h3('Save File Name'), value='lines.rds'),
          actionButton('cut', 'Cut'),
          actionButton('clear', 'Clear'),
          actionButton('save', 'Save')
      )
    )
  )

  ui <- dashboardPage(head, sidebar, body)

  server <- function(input, output){
    rv <- reactiveValues(
      clicks = data.frame(lng = numeric(), lat = numeric()),
      objects = list()
    )

    # make view
    output$map <- {
      renderLeaflet({
        leaflet() %>%
          addTiles() %>%
          setView(lat=37.56579, lng=126.9386, zoom=5)
      })
    }

    # map click
    observeEvent(input$map_click, {
      lastest.click <-
        data.frame(
          lng = input$map_click$lng,
          lat = input$map_click$lat
        )

      rv$clicks <-
        rbind(rv$clicks, lastest.click) # add new point

      leafletProxy('map') %>%
        addCircles(data=rv$clicks, lng=~lng, lat=~lat, radius=2, color='black', opacity=1, layerId='circles') %>%
        addPolylines(data=rv$clicks, lng=~lng, lat=~lat, weight=2, dashArray=3, color='black', opacity=1, layerId='lines')
    })

    # cut button click
    observeEvent(input$cut, {
      if(nrow(rv$clicks) > 0){ # at least 1 point
        new.line <- rv$clicks %>% as.matrix %>% st_linestring # make linestring
        rv$objects[[length(rv$objects) + 1]] <- new.line # append to line list
        rv$clicks <- data.frame(lng = numeric(), lat = numeric()) # reset clicks

        leafletProxy('map') %>%
          removeShape('circles') %>%
          removeShape('lines') %>%
          addPolylines(data=new.line %>% st_sfc, weight=1, color='black', fillColor='black', fillOpacity=.5)
      }
    })

    # clear button click
    observeEvent(input$clear, {
      rv$clicks <- data.frame(lng = numeric(), lat = numeric())
      rv$objects <- list()
      leafletProxy('map') %>% clearShapes()
    })

    # save button click
    observeEvent(input$save, {
      rv$objects %>%
        st_sfc %>%
        saveRDS(file=input$save_file_name)

      save.file.message <-
        paste('lines are saved at: ', getwd(), '/', input$save_file_name, sep='')

      print(save.file.message)
    })
  }

  shinyApp(ui, server)
}
