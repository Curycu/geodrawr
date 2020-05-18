#' run shiny app : making points by click on the map
#'
#' @return
#' @export
#'
#' @examples
#' draw_points()
draw_points <- function(){

  head <- dashboardHeader(disable=TRUE)
  sidebar <- dashboardSidebar(disable=TRUE)

  body <- dashboardBody(
    fluidRow(
      box(width=8, leafletOutput('map', height=800)),
      box(width=4,
          textInput('save_file_name', label=h3('Save File Name'), value='points.rds'),
          actionButton('clear', 'Clear'),
          actionButton('save', 'Save')
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
      rv$clicks %>%
        as.matrix %>%
        st_multipoint %>%
        st_sfc %>%
        st_cast('POINT') %>%
        saveRDS(file=input$save_file_name)

      save.file.message <-
        paste('points are saved at: ', getwd(), '/', input$save_file_name, sep='')

      print(save.file.message)
    })
  }

  shinyApp(ui, server)
}
