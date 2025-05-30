target_rasters_storage <- list(
  geotargets::tar_terra_rast(
    cs_raster_mean,
    rasterize_mean(cs_samba),
    pattern = map(cs_samba)
  ),
  geotargets::tar_terra_rast(
    cs_raster_sd,
    rasterize_sd(cs_samba),
    pattern = map(cs_samba)
  ) #,
  # tar_target(
  #   name = output_mean,
  #   command = save_raster(cs_samba, cs_raster_mean),
  #   pattern = map(cs_samba, cs_raster_mean),
  #   iteration = "list",
  #   format = "file"
  # ),
  # tar_target(
  #   name = output_sd,
  #   command = save_raster(my_cs, cs_raster_sd),
  #   pattern = map(my_cs, cs_raster_sd),
  #   iteration = "list",
  #   format = "file"
  # )
)