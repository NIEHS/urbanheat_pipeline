source("R/map_outputs.R")
args <- commandArgs(trailingOnly = TRUE)
cat("1", args[1], "\n")
cat("2", args[2], "\n")
cat("3", args[3], "\n")
cat("4", args[4], "\n")
cat("5", args[5], "\n")
cat("6", args[6], "\n")
if (!dir.exists(args[4])) {
  dir.create(args[4], recursive = TRUE)
}
if (!dir.exists("my_uhis")) {
  dir.create("my_uhis", recursive = TRUE)
}

temp <- terra::rast(args[1])
cat("temp loaded \n")
# convert time of raster to LST (Local Standard Time)
if (args[2] == "") {
  shape <- args[2]
} else {
  shape <- terra::vect(args[2])
  shape <- terra::crop(shape, terra::ext(temp))
}
cat("shape loaded\n")

save_maps_uhi(
  temp,
  shp = shape,
  tz = args[3],
  storage_path = args[4],
  uhi_range = as.numeric(args[5])
)
cat("images created \n")

uhi <- temp - terra::global(temp, "mean", na.rm = TRUE)$mean
uhi_avg <- terra::mean(uhi, na.rm = TRUE)
if (is(shape, "SpatVector")) {
  p <- map_uhi_avg(uhi_avg) +
    tidyterra::geom_spatvector(
      data = shape,
      fill = NA,
      size = 1,
      alpha = 1,
      linewidth = .1
    )
} else {
  p <- map_uhi_avg(uhi_avg)
}
ggplot2::ggsave(p, file = paste0("my_uhis/uhi_avg_", args[6], ".png"))
