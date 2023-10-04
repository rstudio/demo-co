# Load the packages and functions used by the app
library(shiny)
library(bslib)
library(shinyalert)
library(gitlink)
library(tidyverse)
library(leaflet)

source("helpers.R")

# Define the user interface (UI)
ui <- page_sidebar(

  # Add github link
  ribbon_css("https://github.com/rstudio/demo-co/tree/main/traveling-salesperson-app"),

  # Set CSS theme
  theme = bs_theme(bootswatch = "spacelab",
                   success ="#86C7ED",
                   base_font = "Open Sans",
                   heading_font = "Open Sans"),

  # Add title
  title = "Traveling Salesperson Planner",

  # Add sidebar elements
  sidebar = sidebar(
    width = "300",
    selectizeInput("city", "Select a starting location", choices = USCA312_GPS$name,  selected = "Nashville, TN"),
    markdown("---"),
    fileInput("file", "Upload a CSV file of destinations:"), # File input widget
    markdown("Consider one of these files:

             - [US National Parks](national_parks.csv)
             - [US State Capitals](state_capitals.csv)
             - [Buc-ee's Locations](bucees.csv)"),
    markdown("---"),
    selectizeInput("method", "Choose an algorithm", choices = algorithms),
    uiOutput("downloadButtonUI"),
    tags$img(src = "logo.png",
             width = "75%",
             height = "auto",
             style = "display: block; margin-left: auto; margin-right: auto;")
   ),

  # Map in main panel
  card(
    card_header("Destinations"),
    leafletOutput("map")
  )
)


# Define the server logic
server <- function(input, output, session) {

  # Lookup latitude and longitude of starting city
  start <- reactive({
    USCA312_GPS |>
      filter(name == input$city)
  })

  # Store the uploaded file when it's selected
  uploaded_data <- reactive({
    req(input$file)
    read_csv(input$file$datapath)
  })

  map_data <- reactive({
    clean_for_map(uploaded_data())
  })

  # Reset algorithm when new data set is uploaded
  observeEvent(input$file, {
    updateSelectizeInput(inputId = "method", selected = "")
  })

  # Create a map
  output$map <- renderLeaflet({
      leaflet() |>
      setView(lng = -98.35, lat = 39.5, zoom = 3) |>
      addTiles() |>
      # addProviderTiles("Stadia.AlidadeSmoothDark") |>
      add_start(isolate(start()$lat), isolate(start()$long))
  })

  # Update starting marker
  observeEvent(start(), {
    leafletProxy("map", session) |>
      removeMarker(layerId = "start") |>
      add_start(start()$lat, start()$long)
  })

  # Add/update destination markers
  observeEvent(map_data(), {
    leafletProxy("map", session, data = map_data()) |>
      clearGroup("destinations") |>
      addMarkers(lng = map_data()$longitude,
                 lat = map_data()$latitude,
                 group = "destinations") |>
      flyToBounds(lng1 = min(map_data()$longitude),
                  lng2 = max(map_data()$longitude),
                  lat1 = min(map_data()$latitude),
                  lat2 = max(map_data()$latitude))
  })

  # create an itinerary
  itinerary <- reactive({
    location <- start()
    build_itinerary(data = map_data(),
                    start_lat = location$lat,
                    start_long = location$long,
                    method = input$method)
  })

  # Add/update paths
  observeEvent(itinerary(), {
    leafletProxy("map", session, data = itinerary()) |>
      clearGroup("paths")

    if (input$method != "") {
      leafletProxy("map", session, data = itinerary()) |>
        addPolylines(lng = itinerary()$longitude,
                     lat = itinerary()$latitude,
                     group = "paths",
                     color = "#040449")
    }
  })

  # Render the download button in the UI if uploaded_data() exists
  output$downloadButtonUI <- renderUI({
    req(uploaded_data())
    downloadButton("downloadData", "Download Itinerary")
  })

  # Create a download handler for the uploaded data
  output$downloadData <- downloadHandler(
    filename = function() {
      stub <- str_remove(input$file$name, "\\.csv$")
      paste0(stub, "_itinerary.csv")
    },
    content = function(file) {
      data <- clean_for_download(itinerary())
      write_csv(data, file)
    }
  )

}

# Run the Shiny app
shinyApp(ui = ui, server = server)
