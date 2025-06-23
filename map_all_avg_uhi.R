source("R/map_outputs.R")
dir_path <- "./output/"
all_files <- list.files(
  path = dir_path,
  pattern = "^inference_predmean.*\\.tif$",
  recursive = TRUE,
  full.names = TRUE
)

files_202407 <- all_files[grep("202407", all_files)]
files <- files_202407

output_filename <- list()
for (f in seq_along(files)) {
  output_filename[[f]] <- strsplit(
    files[[f]],
    "(?<=output//)|(?=/inference)",
    perl = TRUE
  )[[1]][2]
}

my_outputs <- cbind(files, output_filename) |>
  as.data.frame()


for (f in seq_along(files)) {
  temp <- terra::rast(files[[f]])
  # convert time of raster to LST (Local Standard Time)
  shape <- terra::vect(
    paste0("./input/shapes/",
      "NTAD_North_American_Roads_-6941702301048783378/",
      "North_American_Roads.shp"
    )
  )
  shape <- terra::crop(shape, terra::ext(temp))
  uhi <- temp - terra::global(temp, "mean", na.rm = TRUE)$mean
  uhi_avg <- terra::mean(uhi, na.rm = TRUE)
  p <- map_uhi_avg(uhi_avg) +
    tidyterra::geom_spatvector(
      data = shape,
      fill = NA,
      size = 1,
      alpha = 1,
      linewidth = .1
    )
  ggplot2::ggsave(
    p,
    file = paste0("my_uhis/uhi_avg_", output_filename[[f]], ".png")
  )
  cat(output_filename[[f]], "done\n")
}
