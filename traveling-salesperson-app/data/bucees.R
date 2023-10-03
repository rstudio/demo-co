# bucee's locations
library(SUNGEO)
library(tidyverse)

# Addresses from https://buc-ees.com/locations/, October 2, 2023

bucees <- tribble(
  ~city,             ~state,   ~address,
  "ATHENS",          "AL",     "2328 Lindsay Lane South, Athens, Alabama 35613",
  "AUBURN",          "AL",     "2500 Buc-ee’s Blvd, Auburn, Alabama 36832",
  "LEEDS",           "AL",     "6900 Buc-ee’s Blvd, Leeds, Alabama 35094",
  "LOXLEY",          "AL",     "20403 County Road 68, Robertsdale, Alabama 36567",
  "DAYTONA BEACH",   "FL",     "2330 Gateway North Drive, Daytona Beach, Florida 32117",
  "SAINT AUGUSTINE", "FL",     "200 World Commerce Pkwy, Saint Augustine, Florida 32092",
  "CALHOUN",         "GA",     "601 Union Grove Road SE, Adairsville, Georgia 30103",
  "WARNER ROBINS",   "GA",     "7001 Russell Parkway, Fort Valley, Georgia 31030",
  "RICHMOND",        "KY",     "1013 Buc-ee's Boulevard, Richmond, Kentucky 40475",
  "FLORENCE",        "SC",     "3390 North Williston Road, Florence, South Carolina 29506",
  "CROSSVILLE",      "TN",     "2045 Genesis Road, Crossville, Tennessee 38555",
  "SEVIERVILLE",     "TN",     "170 Buc-ee’s Blvd, Kodak, Tennessee 37764",
  "ALVIN",           "TX",     "780 Hwy 35 North Bypass, Alvin, Texas 77511",
  "ANGLETON",        "TX",     "2299 E Mulberry St, Angleton, Texas 77515",
  "ANGLETON",        "TX",     "931 Loop 274, Angleton, Texas 77515",
  "ANGLETON",        "TX",     "2304 W Mulberry St, Angleton, Texas 77515",
  "BASTROP",         "TX",     "1700 Highway 71 East, Bastrop, Texas 78602",
  "BAYTOWN",         "TX",     "4080 East Freeway, Baytown, Texas 77521",
  "BRAZORIA",        "TX",     "801 N Brooks, Brazoria, Texas 77422",
  "CYPRESS",         "TX",     "27106 US 290, Cypress, Texas 77433",
  "DENTON",          "TX",     "2800 S Interstate 35 E, Denton, Texas 76210",
  "EAGLE LAKE",      "TX",     "505 E Main St, Eagle Lake, Texas 77434",
  "ENNIS",           "TX",     "1402 South IH 45, Ennis, Texas 75119",
  "FORT WORTH",      "TX",     "15901 N Freeway, Fort Worth, Texas 76177",
  "FREEPORT",        "TX",     "4231 E Hwy 332, Freeport, Texas 77541",
  "FREEPORT",        "TX",     "1002 N Brazosport Blvd, Freeport, Texas 77541",
  "GIDDINGS",        "TX",     "2375 E Austin St, Giddings, Texas 78942",
  "KATY",            "TX",     "27700 Katy Freeway, Katy, Texas 77494",
  "LAKE JACKSON",    "TX",     "899 Oyster Creek Drive, Lake Jackson, Texas 77566",
  "LAKE JACKSON",    "TX",     "101 N Hwy 2004, Lake Jackson, Texas 77566",
  "LAKE JACKSON",    "TX",     "598 Hwy 332, Lake Jackson, Texas 77566",
  "LEAGUE CITY",     "TX",     "1702 League City Pkwy, League City, Texas 77573",
  "LULING",          "TX",     "10070 West IH 10, Luling, Texas 78658",
  "MADISONVILLE",    "TX",     "205 IH-45 South, Madisonville, Texas 77864",
  "MELISSA",         "TX",     "1550 Central Texas Expressway, Melissa, Texas 75454",
  "NEW BRAUNFELS",   "TX",     "2760 IH 35 North, New Braunfels, Texas 78130",
  "PEARLAND",        "TX",     "2541 S Main St, Pearland, Texas 77584",
  "PEARLAND",        "TX",     "11151 Shadow Creek Pky, Pearland, Texas 77584",
  "PORT LAVACA",     "TX",     "2318 W Main, Port Lavaca, Texas 77979",
  "RICHMOND",        "TX",     "1243 Crabb River Rd, Richmond, Texas 77469",
  "ROYSE CITY",      "TX",     "5005 E Interstate 30, Royse City, Texas 75189",
  "TEMPLE",          "TX",     "4155 N General Bruce Dr, Temple, Texas 76501",
  "TERRELL",         "TX",     "506 W IH 20, Terrell, Texas 75160",
  "TEXAS CITY",      "TX",     "6201 Gulf Fwy (IH 45), Texas City, Texas 77591",
  "WALLER",          "TX",     "40900 US Hwy 290 Bypass, Waller, Texas 77484",
  "WHARTON",         "TX",     "10484 US 59 Road, Wharton, Texas 77488"
) |>
  mutate(city = str_to_title(city))

bucees_locations <-
  geocode_osm_batch(buccees$address) |>
  select(latitude, longitude, address = query) |>
  as_tibble()

bucees_locations$latitude[2] <- 32.55211
bucees_locations$longitude[2] <- -85.52713
bucees_locations$latitude[6] <- 29.98370
bucees_locations$longitude[6] <- -81.46412
bucees_locations$latitude[7] <- 34.44078
bucees_locations$longitude[7] <- -84.91661
bucees_locations$latitude[9] <- 37.67355
bucees_locations$longitude[9] <- -84.30817
bucees_locations$latitude[12] <- 35.98123
bucees_locations$longitude[12] <- -83.60479
bucees_locations$latitude[13] <- 29.43038
bucees_locations$longitude[13] <- -95.22592
bucees_locations$latitude[17] <- 30.10746
bucees_locations$longitude[17] <- -97.30710
bucees_locations$latitude[21] <- 33.18074
bucees_locations$longitude[21] <- -97.10204
bucees_locations$latitude[23] <- 32.32330
bucees_locations$longitude[23] <- -96.60669
bucees_locations$latitude[25] <- 28.98108
bucees_locations$longitude[25] <- -95.33633
bucees_locations$latitude[30] <- 29.06396
bucees_locations$longitude[30] <- -95.42776
bucees_locations$latitude[31] <- 29.02253
bucees_locations$longitude[31] <- -95.43779
bucees_locations$latitude[33] <- 29.65141
bucees_locations$longitude[33] <- -97.59297
bucees_locations$latitude[34] <- 30.96524
bucees_locations$longitude[34] <- -95.88045
bucees_locations$latitude[35] <- 33.27133
bucees_locations$longitude[35] <- -96.59240
bucees_locations$latitude[43] <- 32.717148
bucees_locations$longitude[43] <- -96.32068
bucees_locations$latitude[44] <- 29.42914
bucees_locations$longitude[44] <- -95.06323
bucees_locations$latitude[45] <- 30.07158
bucees_locations$longitude[45] <- -95.93078
bucees_locations$latitude[46] <- 29.32492
bucees_locations$longitude[46] <- -96.12330

bucees_locations |>
  write_csv("www/bucees.csv")
