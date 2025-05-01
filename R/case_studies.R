# The objective of this script is to create a .csv with a list of case studies
# Note: for ERA5 download - us extent: -126, -66, 24, 50
source("./R/cs_helene_hurricane.R")
load_case_studies <- function() {
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

cs_list <- load_case_studies()[1:40, ]
cs_list <- cs_list[(which(cs_list$NAME != "Washington")), ] # not enough data
cs_list <- append_helene(cs_list)
write.csv(cs_list, "./input/case_studies_list.csv")
