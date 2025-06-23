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

find_lst_zone <- function(lat, lon) {
  local_tz <- lutz::tz_lookup_coords(lat, lon)
  x <- lutz::tz_list()
  tz <- x[which(x$tz_name == local_tz & x$is_dst == FALSE), ]$zone
  if (tz == "PST") {
    tz <- "Etc/GMT-8"
  }
  if (tz == "CST") {
    tz <- "Etc/GMT-6"
  }
  if (!(tz %in% OlsonNames())) {
    tz <- "UTC"
  }
  tz
}

save_maps_uhi <- function(temp, shp, tz, storage_path, uhi_range) {
  lubridate::tz(terra::time(temp)) <- "UTC"
  lat_avg <- terra::ext(temp)[3] +
    (terra::ext(temp)[4] - terra::ext(temp)[3]) / 2
  lon_avg <- terra::ext(temp)[1] +
    (terra::ext(temp)[2] - terra::ext(temp)[1]) / 2
  # convert time of raster to LST (Local Standard Time)
  tz_lst <- find_lst_zone(lat_avg, lon_avg)
  t <- try(lubridate::with_tz(terra::time(temp), tz = tz_lst))
  if ("try-error" %in% class(t)) {
    terra::time(temp) <- lubridate::with_tz(terra::time(temp), tz = tz)
  } else {
    tz <- tz_lst
    terra::time(temp) <- lubridate::with_tz(terra::time(temp), tz = tz)
  }
  temp_avg <- terra::global(temp, "mean", na.rm = TRUE)
  temp_avg$time <- terra::time(temp)
  uhi <- temp - terra::global(temp, "mean", na.rm = TRUE)$mean
  period <- terra::time(temp)
  if (is(shp, "SpatVector")) {
    for (p in period) {
      cat(p, "\n")
      p_str <- strftime(p, format = "%Y-%m-%d %H:%M:%S", tz = tz) |>
        as.POSIXct(tz = tz)
      plot <- map_uhi(uhi, p_str, uhi_range) +
        tidyterra::geom_spatvector(
          data = shp,
          fill = NA,
          size = 1,
          alpha = 1,
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
  } else {
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
  }
}

round_to_upper_even <- function(x) {
  if (ceiling(x) %% 2 == 0) {
    return(ceiling(x))
  } else {
    return(ceiling(x) + 1)
  }
}

map_uhi_avg <- function(uhi_avg) {
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
  uhi_range <- round_to_upper_even(
    2 * max(abs(terra::minmax(uhi_avg)[2]), abs(terra::minmax(uhi_avg)[1]))
  )
  p <- ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = uhi_avg) +
    ggplot2::labs(
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