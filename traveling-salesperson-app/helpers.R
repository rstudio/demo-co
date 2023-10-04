# helpers.R
library(TSP)

data("USCA312_GPS")

# Make start icon for map
start_marker <- makeAwesomeIcon(
  icon = "home",
  iconColor = "white",
  markerColor = "green",
  library = "glyphicon"
)

# Algorithm choices to solve the Travelling Salesperson Problem
algorithms <-
  list("",
       "Nearest Insertion" = "nearest_insertion",
       "Farthest Insertion" = "farthest_insertion",
       "Cheapest Insertion" = "cheapest_insertion",
       "Arbitrary Insertion" = "arbitrary_insertion",
       "Nearest neighbors" = "nn",
       "Repetitive nearest neighbors" = "repetitive_nn",
       "Two Edge Tour Refinement" = "two_opt",
       "Identity" = "identity",
       "Random" = "random")

# Check that data has the required latitude and
# longitude columns with the correct names
clean_for_map <- function(data) {
  valid <- any(str_detect(names(data), "^[l|L]at(itude)?$")) &&
           any(str_detect(names(data), "^[l|L]ong(itude)?$"))

  if (!valid) {
    shinyalert("Cannot create itinerary", "Your csv file should contain a column named latitude and a column named longitude.")
    validate("Please upload a file with columns named latitude and longitude.")
  }

  names(data)[which(str_detect(names(data), "^[l|L]at(itude)?$"))] <- "latitude"
  names(data)[which(str_detect(names(data), "^[l|L]ong(itude)?$"))] <- "longitude"

  data
}




# Adds starting marker
add_start <- function(map, lat, long) {
  addAwesomeMarkers(map, lat = lat, lng = long, layerId = "start", icon = start_marker)
}


# Makes itinerary table
build_itinerary <- function(data, start_lat, start_long, method) {
  if (method == "") return(data)

  starting_location <- tibble(latitude = start_lat, longitude = start_long)

  destinations <-
    data |>
    add_row(starting_location, .before = 1)

  circuit <-
    destinations |>
    select(latitude, longitude) |>
    ETSP() |>
    solve_TSP(method) |>
    as.integer()

  starting_point <- which(circuit == 1)          # where in the circuit the journey begins
  first_leg <- c(starting_point:length(circuit))
  second_leg <- c(1:starting_point)
  itinerary <- circuit[c(first_leg, second_leg)] # order to visit the destinations

  destinations[itinerary, ] |>
    rownames_to_column(var = "visit_order")
}

clean_for_download <- function(data) {
  data |>
    slice(-c(1, nrow(data)))  # remove starting location
}