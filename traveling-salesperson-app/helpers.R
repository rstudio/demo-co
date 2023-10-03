# helpers.R
library(TSP)

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
       "Concorde" = "concorde",
       "Lin-Kernighan" = "linkern",
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
    add_rownames(var = "visit_order")
}