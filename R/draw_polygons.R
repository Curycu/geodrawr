#' Making polygons by clicks on the map
#'
#' This function run a Shiny application with map.
#' You can shape your own geospatial polygon by clicks on the map and complete it with make button.
#' If you click save button then your completed geospatial polygons will be saved as a RDS file.
#'
#' @return
#' An object that represents the app. Printing the object or passing it to shiny::runApp() will run the app.
#' @export
#'
#' @examples
#' # Only run this example in interactive R sessions
#' if (interactive()) draw_polygons()
draw_polygons <- function(){

  head <- dashboardHeader(disable=TRUE)
  sidebar <- dashboardSidebar(disable=TRUE)

  body <- dashboardBody(
    fluidRow(
      box(width=8, leafletOutput('map', height=800)),
      box(width=4,
          textInput('file_name', label='File Name', value='polygons.rds'),
          actionButton('make', 'Make'),
          actionButton('clear', 'Clear'),
          actionButton('save', 'Save'),
          actionButton('load', 'Load')
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

    # make button click
    observeEvent(input$make, {
      if(nrow(rv$clicks) > 0){ # at least 1 point
        rv$clicks <- rbind(rv$clicks, rv$clicks[1,]) # add first point (= to make close polygon)
        new.polygon <- rv$clicks %>% as.matrix %>% list %>% st_polygon # make polygon
        rv$objects[[length(rv$objects) + 1]] <- new.polygon # append to polygon list
        rv$clicks <- data.frame(lng = numeric(), lat = numeric()) # reset clicks

        leafletProxy('map') %>%
          removeShape('circles') %>%
          removeShape('lines') %>%
          addPolygons(data=new.polygon %>% st_sfc, weight=1, color='black', fillColor='black', fillOpacity=.5)
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
      base_crs = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
      rv$objects %>%
        st_sfc(crs=base_crs) %>%
        saveRDS(file=input$file_name)

      save.file.message <-
        paste('polygons are saved at: ', getwd(), '/', input$file_name, sep='')

      print(save.file.message)
    })

    # load button click
    observeEvent(input$load, {
      rv$objects <- readRDS(input$file_name) %>% st_sfc
      rv$clicks <- data.frame(lng = numeric(), lat = numeric())

      leafletProxy('map') %>%
        clearShapes() %>%
        addPolygons(data=rv$objects %>% st_sfc, weight=1, color='black', fillColor='black', fillOpacity=.5)
    })
  }

  shinyApp(ui, server)
}
