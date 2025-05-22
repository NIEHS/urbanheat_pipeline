find_lst_zone <- function(lat, lon) {
  local_tz <- lutz::tz_lookup_coords(lat, lon)
  x <- lutz::tz_list()
  tz <- x[which(x$tz_name == local_tz & x$is_dst == FALSE), ]$zone
  return(tz)
}
