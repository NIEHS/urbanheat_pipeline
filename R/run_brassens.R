run_brassens <- function(my_cs) {
  inv <- my_cs$cws_inv_file |>
    unique() |>
    read.csv()
  # add path to WU_IBM directory
  inv$fname <- paste0("/WU_IBM/", inv$fname)
  inv <- inv[which(!is.na(inv$lat) & !is.na(inv$lon)), ] |>
    sf::st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE)
  inv$ts_utc <- as.POSIXct(inv$ts_utc, tz = "UTC")
  inv$te_utc <- as.POSIXct(inv$te_utc, tz = "UTC")
  my_cs$ts <- as.POSIXct(my_cs$ts, tz = "UTC")
  my_cs$te <- as.POSIXct(my_cs$te, tz = "UTC")
  area <- open_area(my_cs$NAME)
  ghcnh <- brassens::download_ghcnh(my_cs$ts, my_cs$te, area$area_rect)
  wu <- brassens::load_wu(my_cs$ts, my_cs$te, area$area_rect, inv)
  wu_f <- brassens::format_wu(wu)
  wu_c <- brassens::clean_cws_large(wu_f,
    area$area_rect,
    m2_t_distribution = TRUE,
    m3_cutOff = .001,
    m5_radius = 3000,
    m5_n_buddies = 5,
    m5_keep_isolated = TRUE
  )
  wu_cc_ghcnh <- brassens::calib_cws(wu_c, ref = ghcnh, max_dist = 5000)
  list(ghcnh, wu, wu_f, wu_c, wu_cc_ghcnh)
}