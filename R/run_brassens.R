run_brassens <- function(my_cs) {
  inv <- my_cs$cws_inv_file |>
    unique() |>
    read.csv()
  inv <- inv[which(!is.na(inv$lat) & !is.na(inv$lon)), ] |>
    sf::st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE)
  inv$ts_utc <- as.POSIXct(inv$ts_utc, tz = "UTC")
  inv$te_utc <- as.POSIXct(inv$te_utc, tz = "UTC")
  inv
}