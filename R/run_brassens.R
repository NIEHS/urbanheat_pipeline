run_brassens <- function(my_cs) {
  inv <- my_cs$cws_inv_file |>
    unique() |>
    read.csv()
  # add path to WU_IBM directory
  inv$fname <- paste0("/WU_IBM/", inv$fname)
  inv <- inv[which(!is.na(inv$lat) & !is.na(inv$lon)), ] |>
    sf::st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE)
  inv$ts_utc <- as.POSIXct(inv$ts_utc, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  inv$te_utc <- as.POSIXct(inv$te_utc, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  my_cs$ts <- as.POSIXct(my_cs$ts, formt = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  my_cs$te <- as.POSIXct(my_cs$te, formt = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  area <- open_area(my_cs$NAME, my_cs$ST)
  ghcnh <- brassens::download_ghcnh(my_cs$ts, my_cs$te, area$area_rect)
  wu <- brassens::load_wu(my_cs$ts, my_cs$te, area$area_rect, inv)
  wu_f <- brassens::format_wu(wu)
  wu_c <- brassens::clean_cws_large(wu_f,
    area$area_rect,
    m2_t_distribution = TRUE,
    m3_cutOff = .001,
    m5_radius = my_cs$qc_radius,
    m5_n_buddies = 5,
    m5_keep_isolated = TRUE
  )
  if (nrow(ghcnh) == 0) {
    wu_c$geometry <- NULL
    wu_c$bias_med <- NA
    wu_c$bias_mean <- NA
    wu_c$utc <- lubridate::hour(wu_c$time)
    wu_c$sd <- NA
    wu_c$temp_bef_cal <- wu_c$temp
    wu_cc_ghcnh <- list(
      "obs" = wu_c,
      "bias" = NULL,
      "ref_stats" = ghcnh,
      "cws_in_buf" = NULL
    )
  } else {
    wu_cc_ghcnh <- brassens::calib_cws(wu_c, ref = ghcnh, max_dist = 5000)
  }
  if (nrow(wu_cc_ghcnh$obs) == 0) {
    # if it is still null, let's keep wu_c observations
    wu_cc_ghcnh$obs <- wu_c
    # add missing columns
    wu_cc_ghcnh$obs$utc <- lubridate::hour(wu_cc_ghcnh$obs$time)
    wu_cc_ghcnh$obs$geometry <- NULL
    wu_cc_ghcnh$obs$bias_med <- NA
    wu_cc_ghcnh$obs$bias_mean <- NA
    wu_cc_ghcnh$obs$sd <- NA
    wu_cc_ghcnh$obs$temp_bef_cal <- wu_cc_ghcnh$obs$temp
  }
  list("ghcnh" = ghcnh, "wu_brassens" = wu_cc_ghcnh)
}