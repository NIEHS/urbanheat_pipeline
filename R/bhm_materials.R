bhm_materials <- function(my_cs, cs_brassens) {
  my_cs$ts <- as.POSIXct(my_cs$ts, tz = "UTC")
  my_cs$te <- as.POSIXct(my_cs$te, tz = "UTC")
  save_folder <- paste0(
    "./output/",
    gsub("[.]", "", gsub("[ ]", "_", tolower(my_cs$NAME))),
    "_",
    format(my_cs$ts, "%Y%m"),
    "/"
  )
  if (!dir.exists(save_folder)) {
    dir.create(save_folder, recursive = TRUE)
  }
  input <- list()
  input$cws_raw <- cs_brassens$wu_brassens$obs |>
    terra::vect(geom = c("lon", "lat"), crs = "epsg:4326", keepgeom = TRUE)
  input$fch <- terra::rast(my_cs$fch_file)
  input$elev <- terra::rast(my_cs$elev_file)
  input$imp <- terra::rast(my_cs$imp_file)
  input$era5_instant <- terra::rast(my_cs$era5_instant_file)
  input$era5_accum <- terra::rast(my_cs$era5_accum_file)
  input$area_shp <- open_area(my_cs$NAME, my_cs$ST)$area_rect
  input$ts <- as.POSIXct(my_cs$ts, tz = "UTC", format = "%Y-%m-%d %H:%M:%S")
  input$te <- as.POSIXct(my_cs$te, tz = "UTC", format = "%Y-%m-%d %H:%M:%S")
  samba::check_input(input)
  bhm_materials <- samba::prepare_bhm_materials(
    input,
    my_cs$era5_accum_file,
    my_cs$era5_instant_file
  )
  bhm_materials
}