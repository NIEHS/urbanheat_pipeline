sf_as_spatraster <- function(x, varname, nx, ny) {
  stopifnot("varname missing or mispelled" = varname %in% colnames(x))
  grid <- stars::st_as_stars(sf::st_bbox(x),
    nx = nx,
    ny = ny,
    values = NA_real_
  )
  newrast <- stars::st_rasterize(x[, varname],
    template = grid
  ) |>
    terra::rast()
  newrast
}

rasterize_pred <- function(
  pred,
  varname = "pred_mean",
  existing_raster = NULL
) {
  stopifnot("varname missing or mispelled" = varname %in% colnames(pred))
  tz <- lubridate::tz(pred$time)
  nx <- length(unique(as.numeric(sprintf("%.3f", pred$lon))))
  ny <- length(unique(as.numeric(sprintf("%.3f", pred$lat))))
  period <- seq(min(pred$time), max(pred$time), by = "1 hour")
  predictions <- list()
  missing <- c()
  for (p in period) {
    p_str <- strftime(p, format = "%Y-%m-%d %H:%M:%S", tz = tz) |>
      as.POSIXct(tz = tz)
    cat(p_str, "\n")
    i <- which(period == p_str)
    sample <- pred[which(pred$time == p_str), ]
    if (nrow(sample) == 0) {
      message("no predictions at time ", p_str)
      missing <- c(missing, p_str)
    } else {
      sample <- sample |>
        sf::st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE) |>
        sf_as_spatraster(varname, nx = nx, ny = ny)
      predictions[[i]] <- sample[[1]]
    }
  }
  predictions <- terra::rast(predictions)
  terra::time(predictions) <- setdiff(period, missing)
  if (is.null(existing_raster)) {
    predictions
  } else {
    terra::add(existing_raster) <- predictions
    existing_raster
  }
}


rasterize_mean <- function(cs_samba) {
  pred_mean <- rasterize_pred(cs_samba$pred, varname = "pred_mean")
  terra::time(pred_mean) <- sort(unique(cs_samba$pred$time))
  ts <- min(cs_samba$pred$time)
  te <- max(cs_samba$pred$time)
  save_folder <- paste0(
    "./output/",
    gsub("[.]", "", gsub("[ ]", "_", tolower(cs_samba$city))),
    "_",
    format(ts, "%Y%m"),
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
      gsub("[.]", "", gsub("[ ]", "_", tolower(cs_samba$city))),
      "_",
      format(ts, "%Y%m%d%H"),
      "_",
      format(te, "%Y%m%d%H"),
      ".tif"
    ),
    overwrite = TRUE
  )
  pred_mean
}

rasterize_sd <- function(cs_samba) {
  pred_sd <- rasterize_pred(cs_samba$pred, varname = "pred_sd")
  terra::time(pred_sd) <- sort(unique(cs_samba$pred$time))
  ts <- min(cs_samba$pred$time)
  te <- max(cs_samba$pred$time)
  save_folder <- paste0(
    "./output/",
    gsub("[.]", "", gsub("[ ]", "_", tolower(cs_samba$city))),
    "_",
    format(ts, "%Y%m"),
    "/"
  )
  if (!dir.exists(save_folder)) {
    dir.create(save_folder, recursive = TRUE)
  }
  terra::writeRaster(
    x = pred_sd,
    file = paste0(
      save_folder,
      "inference_predsd_",
      gsub("[.]", "", gsub("[ ]", "_", tolower(cs_samba$city))),
      "_",
      format(ts, "%Y%m%d%H"),
      "_",
      format(te, "%Y%m%d%H"),
      ".tif"
    ),
    overwrite = TRUE
  )
  pred_sd
}