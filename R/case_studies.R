# The objective of this script is to create a .csv with a list of case studies
# Note: for ERA5 download - us extent: -126, -66, 24, 50
source("./R/cs_helene_hurricane.R")
load_cs_cities <- function() {
  us_cities <- terra::vect(
    "./input/500Cities_City_11082016/CityBoundaries.shp"
  )
  # remove non-contiguous states
  non_contig_st <-  c("AS", "AK", "GU", "HI", "MP", "TT", "VI", "PR")
  us_cities <- us_cities[which(!(us_cities$ST %in% non_contig_st)), ]
  us_states <- read.csv("./input/states.csv")
  us_states$state <- tolower(us_states$State) |>
    sub(pattern = " ", replacement = "_")
  us_cities <- merge(us_cities, us_states, by.x = "ST", by.y = "Abbreviation")
  us_cities <- us_cities[order(us_cities$POP2010, decreasing = TRUE), ]
  cs <- us_cities[, c("NAME", "ST", "state", "POP2010")]
  cs$cws_inv_file <- paste0(
    "/WU_IBM/inventories/",
    cs$state,
    ".csv"
  )
  cs$cws_folder <- paste0(
    "/WU_IBM/Output/",
    cs$state,
    "/"
  )
  cs$elev_file <- "./input/gmted_medianstat_7-5arcsec.tif"
  cs$imp_file <- "./input/nlcd_2021_impervious_l48_20230630.img"
  cs$fch_file <- "./input/forest_height_2019_nam.tif"
  # July 2023 is chosen by default as it is the hottest
  # month ever recorded in the United States of America
  cs$ts <- as.POSIXct("2023-07-01 00:00:00", tz = "UTC")
  cs$te <- as.POSIXct("2023-07-31 23:00:00", tz = "UTC")
  # los angeles - study oct. 2023
  cs[2, ]$ts <- as.POSIXct("2023-10-01 00:00:00", tz = "UTC")
  cs[2, ]$te <- as.POSIXct("2023-10-31 23:00:00", tz = "UTC")
  # chicago - study feb. 2021 (really cold)
  cs[3, ]$ts <- as.POSIXct("2021-02-01 00:00:00", tz = "UTC")
  cs[3, ]$te <- as.POSIXct("2021-02-28 23:00:00", tz = "UTC")
  # houston - study june 2023 (power outage + heatwave)
  cs[4, ]$ts <- as.POSIXct("2023-06-01 00:00:00", tz = "UTC")
  cs[4, ]$te <- as.POSIXct("2023-06-30 23:00:00", tz = "UTC")
  cs$era5_instant_file <- paste0(
    "./input/era5_us_",
    lubridate::year(cs$ts),
    "_",
    sprintf("%02d", lubridate::month(cs$ts)),
    "/data_stream-oper_stepType-instant.nc"
  )
  cs$era5_accum_file <- paste0(
    "./input/era5_us_",
    lubridate::year(cs$ts),
    "_",
    sprintf("%02d", lubridate::month(cs$ts)),
    "/data_stream-oper_stepType-accum.nc"
  )
  cs
}

load_cs_states <- function() {
  us_states <- terra::vect(
    "./input/cb_2018_us_state_5m/cb_2018_us_state_5m.shp"
  )
  # remove non-contiguous states
  non_contig_st <-  c("AS", "AK", "GU", "HI", "MP", "TT", "VI", "PR")
  us_states <- us_states[which(!(us_states$STUSPS %in% non_contig_st)), ]
  us_states$state <- tolower(us_states$NAME) |>
    sub(pattern = " ", replacement = "_")
  us_states$ST <- us_states$STUSPS
  us_states$STUSPS <- NULL
  cs <- us_states[, c("NAME", "ST", "state")]
  cs$POP2010 <- NA
  cs$cws_inv_file <- paste0(
    "/WU_IBM/inventories/",
    cs$state,
    ".csv"
  )
  cs$cws_folder <- paste0(
    "/WU_IBM/Output/",
    cs$state,
    "/"
  )
  cs$elev_file <- "./input/gmted_medianstat_7-5arcsec.tif"
  cs$imp_file <- "./input/nlcd_2021_impervious_l48_20230630.img"
  cs$fch_file <- "./input/forest_height_2019_nam.tif"
  # July 2023 is chosen by default as it is the hottest
  # month ever recorded in the United States of America
  cs$ts <- as.POSIXct("2023-07-01 00:00:00", tz = "UTC")
  cs$te <- as.POSIXct("2023-07-31 23:00:00", tz = "UTC")
  cs$era5_instant_file <- paste0(
    "./input/era5_us_",
    lubridate::year(cs$ts),
    "_",
    sprintf("%02d", lubridate::month(cs$ts)),
    "/data_stream-oper_stepType-instant.nc"
  )
  cs$era5_accum_file <- paste0(
    "./input/era5_us_",
    lubridate::year(cs$ts),
    "_",
    sprintf("%02d", lubridate::month(cs$ts)),
    "/data_stream-oper_stepType-accum.nc"
  )
  as.data.frame(cs)
}


cs_cities <- load_cs_cities()[1:100, ]
cs_cities <- cs_cities[(which(cs_cities$NAME != "Washington")), ] # no data
cs_list <- append_helene(cs_cities)
cs_states <- load_cs_states()
cs_states <- cs_states[which(cs_states$ST == "NC"), ]
cs_list <- rbind(cs_list, cs_states)
write.csv(cs_list, "./input/case_studies_list.csv")
