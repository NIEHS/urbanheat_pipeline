map_uhi <- function(uhi, ts, uhi_range) {
  temp_ipcc <- list(
    c(103, 0, 31),
    c(178, 24, 43),
    c(214, 96, 77),
    c(244, 165, 130),
    c(253, 219, 199),
    c(247, 247, 247),
    c(209, 229, 240),
    c(146, 197, 222),
    c(67, 147, 195),
    c(33, 102, 172),
    c(5, 48, 97)
  ) |>
    lapply(
      function(x) grDevices::rgb(x[1], x[2], x[3], maxColorValue = 255)
    ) |>
    rev()
  uhi_ts <- uhi[[which(terra::time(uhi) == ts)]]
  p <- ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = uhi_ts) +
    ggplot2::labs(
      title = paste0(
        format(ts, "%Y-%m-%d %H"),
        lubridate::tz(ts)
      ),
      fill = latex2exp::TeX("$UHI$(°C)")
    ) +
    ggplot2::scale_fill_gradientn(
      colours = temp_ipcc,
      na.value = NA,
      limits = c(-uhi_range / 2, uhi_range / 2),
      breaks = seq(-uhi_range / 2, uhi_range / 2, by = 1)
    ) +
    ggplot2::guides(
      fill = ggplot2::guide_colourbar(barwidth = 25, barheight = 1.5)
    ) +
    ggspatial::annotation_scale(
      location = "tl", pad_x = ggplot2::unit(1, "cm"),
      pad_y = ggplot2::unit(1, "cm"),
      height = ggplot2::unit(0.30, "cm"),
      text_cex = 1
    ) +
    ggspatial::annotation_north_arrow(
      location = "br",
      which_north = "true",
      pad_x = ggplot2::unit(0.2, "cm"),
      pad_y = ggplot2::unit(0.2, "cm")
    ) +
    ggplot2::theme(
      title = ggplot2::element_text(size = 18),
      axis.text = ggplot2::element_text(size = 12),
      axis.text.y = ggplot2::element_text(size = 12, angle = 90, hjust = .5),
      plot.caption = ggplot2::element_text(size = 10),
      legend.position = "bottom",
      legend.text = ggplot2::element_text(size = 18),
      legend.title = ggplot2::element_text(size = 18),
      panel.background = ggplot2::element_rect(fill = "white"),
      panel.grid.major = ggplot2::element_line(colour = "grey")
    )
  p
}

save_maps_uhi <- function(temp, shp, tz, ts, te, storage_path, uhi_range) {
  terra::time(temp) <- lubridate::with_tz(terra::time(temp), tz = tz)
  temp_avg <- terra::global(temp, "mean", na.rm = TRUE)
  temp_avg$time <- terra::time(temp)
  uhi <- temp - terra::global(temp, "mean", na.rm = TRUE)$mean
  period <- terra::time(temp)
  if (shp == "") {
    for (p in period) {
      cat(p, "\n")
      p_str <- strftime(p, format = "%Y-%m-%d %H:%M:%S", tz = tz) |>
        as.POSIXct(tz = tz)
      plot <- map_uhi(uhi, p_str, uhi_range)
      ggplot2::ggsave(plot,
        filename = paste0(
          storage_path,
          "/",
          which(period == p),
          ".png"
        ),
        width = 7,
        height = 7,
        dpi = 200
      )
    }
  } else {
    for (p in period) {
      cat(p, "\n")
      p_str <- strftime(p, format = "%Y-%m-%d %H:%M:%S", tz = tz) |>
        as.POSIXct(tz = tz)
      plot <- map_uhi(uhi, p_str, uhi_range) +
        tidyterra::geom_spatvector(
          data = shp,
          fill = NA,
          size = 2,
          linewidth = .1
        )
      ggplot2::ggsave(plot,
        filename = paste0(
          storage_path,
          "/",
          which(period == p),
          ".png"
        ),
        width = 7,
        height = 7,
        dpi = 200
      )
    }
  }
}

args <- commandArgs(trailingOnly = TRUE)
# args test in interactive mode
# args <- NULL
# args[1] <- "./rasters/albuquerque_2020100100_2020103123/inference_predmean_albuquerque_2020100100_2020103123.tif"
# args[2] <- ""
# args[3] <- "UTC"
# args[4] <- "2020-10-01 00:00:00"
# args[5] <- "2020-10-31 23:00:00"
# args[6] <- "test"

cat(args, "\n")
# code to find LST (does not work everywhere for some unclear reason)
# lat_avg <- terra::ext(temp)[3] + (terra::ext(temp)[4]
#   - terra::ext(temp)[3]) / 2
# lon_avg <- terra::ext(temp)[1] + (terra::ext(temp)[2] -
#   terra::ext(temp)[1]) / 2
#   # convert time of raster to LST (Local Standard Time)
# tz_lst <- find_lst_zone(lat_avg, lon_avg)

if (!dir.exists(args[6])) {
  dir.create(args[6], recursive = TRUE)
}

temp <- terra::rast(args[1])
cat("temp loaded \n")
ts_all <- as.POSIXct(
  args[4],
  format = "%Y-%m-%d %H:%M:%S",
  tz = "UTC"
)
te_all <- ts_all + lubridate::hours(dim(temp)[3]) - 1
terra::time(temp) <- seq(ts_all, te_all, by = "hour")

save_maps_uhi(
  temp,
  shp = ifelse(
    args[2] == "",
    args[2],
    terra::vect(args[2])
  ),
  tz = args[3],
  ts = ts_all,
  te = te_all,
  storage_path = args[6],
  uhi_range = as.numeric(args[7])
)
cat("images created \n")