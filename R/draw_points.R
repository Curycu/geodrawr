#' Making Points by Clicks on the Map
#'
#' @return
#' An object that represents the app. Printing the object or passing it to shiny::runApp() will run the app.
#' @export
#'
#' @examples
#' # Only run this example in interactive R sessions
#' # draw_points()
draw_points <- function(){

  head <- dashboardHeader(disable=TRUE)
  sidebar <- dashboardSidebar(disable=TRUE)

  body <- dashboardBody(
    fluidRow(
      box(width=8, leafletOutput('map', height=800)),
      box(width=4,
          textInput('file_name', label='File Name', value='points.rds'),
          actionButton('clear', 'Clear'),
          actionButton('save', 'Save'),
          actionButton('load', 'Load')
      )
    )
  )

  ui <- dashboardPage(head, sidebar, body)

  server <- function(input, output){
    rv <- reactiveValues(
      clicks = data.frame(lng = numeric(), lat = numeric())
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
        addCircles(data=lastest.click, lng=~lng, lat=~lat, radius=2, color='black', opacity=1)
    })

    # clear button click
    observeEvent(input$clear, {
      rv$clicks <- data.frame(lng = numeric(), lat = numeric())
      leafletProxy('map') %>% clearShapes()
    })

    # save button click
    observeEvent(input$save, {
      if(nrow(rv$clicks) > 0){ # at least 1 point
        rv$clicks %>%
          as.matrix %>%
          st_multipoint %>%
          st_sfc %>%
          st_cast('POINT') %>%
          saveRDS(file=input$file_name)

        save.file.message <-
          paste('points are saved at: ', getwd(), '/', input$file_name, sep='')

        print(save.file.message)
      }
    })

    as.clicks <- function(x){
      mat <- sapply(x, function(x) c(x[1], x[2]))
      data.frame(lng=mat[1,], lat=mat[2,])
    }

    # load button click
    observeEvent(input$load, {
      rv$clicks <- as.clicks(readRDS(input$file_name))

      leafletProxy('map') %>%
        clearShapes() %>%
        addCircles(data=rv$clicks, lng=~lng, lat=~lat, radius=2, color='black', opacity=1)
    })
  }

  shinyApp(ui, server)
}
