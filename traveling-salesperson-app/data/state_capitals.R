# state capitals
library(tidyverse)

location_url <- "https://people.sc.fsu.edu/~jburkardt/datasets/states/state_capitals_ll.txt"
city_name_url <- "https://people.sc.fsu.edu/~jburkardt/datasets/states/state_capitals_name.txt"

locations <-
  read_table(location_url, col_names = FALSE) |>
  rename(state = X1, latitude = X2, longitude = X3)

state_capitals <-
  read_table(city_name_url, col_names = FALSE) |>
  rename(state = X1, city = X2) |>
  mutate(city = str_remove_all(city, '\"')) |>
  left_join(locations, by = "state") |>
  filter(!(state %in% c("US", "PR")))

state_capitals |>
  write_csv(file = "www/state_capitals.csv")


