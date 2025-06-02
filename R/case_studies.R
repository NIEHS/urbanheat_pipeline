# The objective of this script is to create a .csv with a list of case studies
# Note: for ERA5 download - us extent: -126, -66, 24, 50
source("./R/cs_helene_hurricane.R")
load_cs_cities <- function(ts, te) {
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
  cs$ts <- ts
  cs$te <- te
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

load_cs_states <- function(ts, te) {
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
  cs$ts <- ts
  cs$te <- te
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

# July 2023 is chosen by default as it is the hottest
# month ever recorded in the United States of America
cs_jul23 <- load_cs_cities(
  as.POSIXct("2023-07-01 00:00:00", tz = "UTC"),
  as.POSIXct("2023-07-31 23:00:00", tz = "UTC")
)[1:101, ]
cs_jul23 <- cs_jul23[(which(cs_jul23$NAME != "Washington")), ] # no data
# February 2021 blizzard
cs_feb21 <- load_cs_cities(
  as.POSIXct("2021-02-01 00:00:00", tz = "UTC"),
  as.POSIXct("2021-02-28 23:00:00", tz = "UTC")
)[1:101, ]
cs_feb21 <- cs_feb21[(which(cs_feb21$NAME != "Washington")), ] # no data
# April 2024
cs_apr24 <- load_cs_cities(
  as.POSIXct("2024-04-01 00:00:00", tz = "UTC"),
  as.POSIXct("2024-04-30 23:00:00", tz = "UTC")
)[1:101, ]
cs_apr24 <- cs_apr24[(which(cs_apr24$NAME != "Washington")), ] # no data
cs_list <- rbind(cs_jul23, cs_feb21, cs_apr24)
write.csv(cs_list, "./input/case_studies_list.csv")
# October 2020
cs_oct20 <- load_cs_cities(
  as.POSIXct("2020-10-01 00:00:00", tz = "UTC"),
  as.POSIXct("2020-10-31 23:00:00", tz = "UTC")
)[1:101, ]
cs_oct20 <- cs_oct20[(which(cs_oct20$NAME != "Washington")), ] # no data
# July 2024
cs_jul24 <- load_cs_cities(
  as.POSIXct("2024-07-01 00:00:00", tz = "UTC"),
  as.POSIXct("2024-07-31 23:00:00", tz = "UTC")
)[1:101, ]
cs_jul24 <- cs_jul24[(which(cs_jul24$NAME != "Washington")), ] # no data

cs_list <- rbind(cs_jul23, cs_feb21, cs_apr24, cs_oct20, cs_jul24)
write.csv(cs_list, "./input/case_studies_list.csv")


# for now these case studies are too long to run.
# cs_list <- append_helene(cs_cities)
# cs_states <- load_cs_states(
#   as.POSIXct("2023-07-01 00:00:00", tz = "UTC"),
#   as.POSIXct("2023-07-31 23:00:00", tz = "UTC")
# )
# cs_states <- cs_states[which(cs_states$ST == "CO"), ]
# cs_states <- cs_states[which(cs_states$ST == "NC"), ]
