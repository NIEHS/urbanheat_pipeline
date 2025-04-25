rasterize_mean <- function(my_cs, cs_samba) {
  my_cs$ts <- as.POSIXct(my_cs$ts, tz = "UTC")
  my_cs$te <- as.POSIXct(my_cs$te, tz = "UTC")
  pred_mean <- samba::rasterize_pred(cs_samba$pred, varname = "pred_mean")
  save_folder <- paste0(
    "./output/",
    gsub(" ", "_", tolower(my_cs$NAME)),
    "_",
    format(my_cs$ts, "%Y%m%d%H"),
    "_",
    format(my_cs$ts, "%Y%m%d%H"),
    "/"
  )
  if (!dir.exists(save_folder)) {
    dir.create(save_folder, recursive = TRUE)
  }
  terra::writeRaster(
    x = pred_mean,
    file = paste0(
      save_folder,
      "inference_predmean_",
      gsub(" ", "_", tolower(my_cs$NAME)),
      "_",
      format(my_cs$ts, "%Y%m%d%H"),
      "_",
      format(my_cs$te, "%Y%m%d%H"),
      ".tif"
    ),
    overwrite = TRUE
  )
  pred_mean
}

rasterize_sd <- function(my_cs, cs_samba) {
  my_cs$ts <- as.POSIXct(my_cs$ts, tz = "UTC")
  my_cs$te <- as.POSIXct(my_cs$te, tz = "UTC")
  pred_sd <- samba::rasterize_pred(cs_samba$pred, varname = "pred_sd")
  save_folder <- paste0(
    "./output/",
    gsub(" ", "_", tolower(my_cs$NAME)),
    "_",
    format(my_cs$ts, "%Y%m%d%H"),
    "_",
    format(my_cs$ts, "%Y%m%d%H"),
    "/"
  )
  if (!dir.exists(save_folder)) {
    dir.create(save_folder, recursive = TRUE)
  }
  terra::writeRaster(
    x = pred_sd,
    file = paste0(
      save_folder,
      "inference_sd_",
      gsub(" ", "_", tolower(my_cs$NAME)),
      "_",
      format(my_cs$ts, "%Y%m%d%H"),
      "_",
      format(my_cs$te, "%Y%m%d%H"),
      ".tif"
    ),
    overwrite = TRUE
  )
  pred_sd
}