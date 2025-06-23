run_samba <- function(my_cs, cs_bhm_materials) {
  my_cs$ts <- as.POSIXct(my_cs$ts, tz = "UTC")
  my_cs$te <- as.POSIXct(my_cs$te, tz = "UTC")
  inf_out <- samba::inference(
    cs_bhm_materials$cws,
    cs_bhm_materials$pred,
    polygon = open_area(my_cs$NAME, my_cs$ST)$area_rect,
    my_cs$ts,
    my_cs$te,
    verbose = TRUE,
    debug = TRUE
  )
  inf_out$info$city <- my_cs$NAME
  inf_out$info$state <-  my_cs$ST
  inf_out$info$yyyymm <- paste0(
    lubridate::year(inf_out$pred$time[1]),
    sprintf("%02d", lubridate::month(inf_out$pred$time[1]))
  )
  inf_out$city <- my_cs$NAME
  inf_out$state <- my_cs$ST
  inf_out$yyyymm <- paste0(
    lubridate::year(inf_out$pred$time[1]),
    sprintf("%02d", lubridate::month(inf_out$pred$time[1]))
  )
  inf_out
}