remove_lakes_oceans <- function(v) {
  us_lakes <- terra::vect(
    paste0(
      "./input/rivers_and_lakes_shapefile/",
      "NA_Lakes_and_Rivers/data/lakes_p/northamerica_lakes_cec_2023.shp"
    )
  ) |>
    terra::project(y = "EPSG:4326")
  us_borders <- terra::vect(
    paste0(
      "./input/cb_2018_us_nation_5m/",
      "cb_2018_us_nation_5m.shp"
    )
  ) |>
    terra::project(y = "EPSG:4326")
  v <- terra::project(v, "EPSG:4326")
  lakes <- terra::crop(v, us_lakes)
  if (nrow(lakes) == 0) {
    cleaned <- terra::crop(us_borders, v)
  } else {
    cleaned <- terra::crop(us_borders, v - lakes)
  }
  cleaned
}

# work also with a group of cities
open_area <- function(city, state) {
  us_cities <- terra::vect(
    "./input/500Cities_City_11082016/CityBoundaries.shp"
  )
  us_states <- terra::vect(
    "./input/cb_2018_us_state_5m/cb_2018_us_state_5m.shp"
  )
  if (all(city %in% us_cities$NAME)) {
    plot_shp <- us_cities[
      which(us_cities$NAME %in% city & us_cities$ST %in% state),
    ]
    area_rect <- terra::ext(plot_shp) |>
      terra::as.polygons(crs = terra::crs(plot_shp)) |>
      terra::buffer(25000, joinstyle = "mitre")
  } else if (
    all(city %in% us_states$NAME) && all(state %in% us_states$STUSPS)
  ) {
    plot_shp <- us_states[
      which(us_states$NAME %in% city & us_states$ST %in% state),
    ]
    area_rect <- plot_shp
  } else if (city == "helene_hurricane") {
    # specific case studies for eg. helene case study
    latmin <- 28.123
    latmax <- 37.625
    lonmin <- - 87.122
    lonmax <- - 77.234
    area <- matrix(
      c(
        lonmin, latmin,  # Bottom-left
        lonmin, latmax,  # Top-left
        lonmax, latmax,  # Top-right
        lonmax, latmin,  # Bottom-right
        lonmin, latmin   # Close the polygon
      ),
      ncol = 2,
      byrow = TRUE
    ) |>
      terra::vect(type = "polygons", crs = "EPSG:4326")
    plot_shp <- area
    area_rect <- area
  } else {
    stop("City not found")
  }
  area_rect <- remove_lakes_oceans(area_rect)
  list("plot_shp" = plot_shp, "area_rect" = area_rect)
}
