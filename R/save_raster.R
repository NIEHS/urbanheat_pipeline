save_raster <- function(my_cs, r) {
  my_cs$ts <- as.POSIXct(my_cs$ts, tz = "UTC")
  my_cs$te <- as.POSIXct(my_cs$te, tz = "UTC")
  save_folder <- paste0(
    "./output/",
    gsub("[.]", "", gsub("[ ]", "_", tolower(my_cs$ST))),
    "_",
    gsub("[.]", "", gsub("[ ]", "_", tolower(my_cs$NAME))),
    "_",
    format(my_cs$ts, "%Y%m%d%H"),
    "_",
    format(my_cs$te, "%Y%m%d%H"),
    "/"
  )
  if (!dir.exists(save_folder)) {
    dir.create(save_folder, recursive = TRUE)
  }
  terra::writeRaster(
    x = r,
    file = paste0(
      save_folder,
      "inference_predmean_",
      gsub("[.]", "", gsub("[ ]", "_", tolower(my_cs$ST))),
      "_",
      gsub("[.]", "", gsub("[ ]", "_", tolower(my_cs$NAME))),
      "_",
      format(my_cs$ts, "%Y%m%d%H"),
      "_",
      format(my_cs$te, "%Y%m%d%H"),
      ".tif"
    ),
    overwrite = TRUE
  )
}