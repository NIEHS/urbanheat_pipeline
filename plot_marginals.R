samb_a <- tar_read(cs_samba_6ef2cd1a32e82338)
samb_b <- tar_read(cs_samba_fc41c525a35777df)
samb_c <- tar_read(cs_samba_9c7c22545ab666ed)
samb_d <- tar_read(cs_samba_82276619145a3fe5)
samb_e <- tar_read(cs_samba_37917116ead31949)
samb_f <- tar_read(cs_samba_c88df05a208a7668)
samb_i <- tar_read(cs_samba_016d4e8c7aa90d49)
samb_j <- tar_read(cs_samba_d43fc715f9ff5a14)
samb_k <- tar_read(cs_samba_f67f3a912704024c)
samb_l <- tar_read(cs_samba_1d4b8710f48c334d)
samb_m <- tar_read(cs_samba_9fe33e48a1eebffd)

info_a <- samb_a$info
info_b <- samb_b$info
info_a$city <- samb_a$city
info_a$state <- samb_a$state
info_a$yyyymm <- paste0(
  lubridate::year(samb_a$pred$time[1]),
  sprintf("%02d", lubridate::month(samb_a$pred$time[1]))
)
info_b$city <- samb_b$city
info_b$state <- samb_b$state
info_b$yyyymm <- paste0(
  lubridate::year(samb_b$pred$time[1]),
  sprintf("%02d", lubridate::month(samb_b$pred$time[1]))
)

tar_load(my_cs)

info <- rbind(
  info_a,
  info_b,
  samb_c$info,
  samb_d$info,
  samb_e$info,
  samb_f$info,
  samb_i$info,
  samb_j$info,
  samb_k$info,
  samb_l$info,
  samb_m$info
)

tvar_coeffs <- info |>
  dplyr::select(starts_with("local_hour"), "city", "state", "yyyymm") |>
  tidyr::pivot_longer(
    cols = starts_with("local_hour"),
    names_to = "var",
    values_to = "value"
  )
tvar_coeffs$local_hour <- as.numeric(
  stringr::str_extract(tvar_coeffs$var, "(?<=local_hour)\\d+")
)
tvar_coeffs$tvar <- stringr::str_extract(tvar_coeffs$var, "(?<=:).*?(?=_)")
tvar_coeffs$stat <- sub(".*?_.*?_(.*)", "\\1", tvar_coeffs$var)
tvar_coeffs$var <- NULL
tvar_coeffs <- tvar_coeffs |>
  tidyr::pivot_wider(
    names_from = stat,               # Column to use for new column names
    values_from = value              # Column to use for values
  )


var <- c("elev", "fch", "imp")
prior_mean <- c(-0.006, 0, 0)
prior_sd <- c(sqrt(1 / 10000), sqrt(1 / 100), sqrt(1 / 200))
yn <- c(-0.015, -0.1, -0.035)
yx <- - yn
p <- list()
for (i in seq_along(var)) {
  x_values <- data.frame(x = seq(yn[[i]], -yn[[i]], length.out = 100))
  p[[i]] <- ggplot(x_values, aes(x =  x)) +
    stat_function(
      fun = dnorm,
      args = list(mean = prior_mean[[i]], sd = prior_sd[[i]]),
      color = "black",
      size = 1
    ) +
    geom_vline(xintercept = 0, color = "black", linetype = "dashed") +
    labs(
      x = "",
      y = ""
    ) +
    coord_flip() +
    scale_y_reverse() +
    theme(
      axis.title = element_text(size = 18),
      axis.text.y = element_text(size = 18),
      axis.text.x = element_blank(),
      plot.caption = element_text(size = 18),
      panel.background = element_rect(fill = "white"),
      panel.grid.major = element_line(colour = "grey")
    )
}
p_priors <- ggpubr::ggarrange(p[[1]], p[[2]], p[[3]], nrow = 3)
p_priors


blank_df <- data.frame(cbind(var, yn, yx))
names(blank_df) <- c("tvar", "yn", "yx")
blank_df <- blank_df |>
  tidyr::pivot_longer(
    cols = c(yn, yx),
    names_to = "type",
    values_to = "y"
  )
blank_df$x <- 2
blank_df$y <- as.numeric(blank_df$y)

p_tvar_coeffs <- ggplot(tvar_coeffs) +
  geom_line(aes(
    x = local_hour,
    y = mean,
    color = city,
    group = interaction(city, state, yyyymm),
    linetype = yyyymm
  )) +
  geom_ribbon(
    aes(
      x = local_hour,
      ymin = mean - 2 * sd,
      ymax = mean + 2 * sd,
      fill = city,
      group = interaction(city, state, yyyymm)
    ),
    alpha = 0.1
  ) +
  geom_blank(data = blank_df, aes(x = x, y = y)) +
  facet_wrap(vars(tvar), nrow = 3, scales = "free_y") +
  geom_hline(yintercept = 0, color = "black", linetype = "dashed") +
  #scale_color_manual("", values = color_cs) +
  #scale_fill_manual("", values = color_cs) +
  xlab("Local time (h)") +
  ylab(latex2exp::TeX("coef $\\mu\\pm 2\\sigma$")) +
  scale_x_continuous(
    breaks = seq(0, 23, 1)
  ) +
  guides(
    color = guide_legend(keywidth = unit(2, "cm")),
    fill = guide_legend(keywidth = unit(2, "cm"))
  ) +
  theme(
    legend.position = "right",
    legend.direction = "vertical",
    legend.box = "vertical",
    axis.title = element_text(size = 18),
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(
      size = 12,
      hjust = .5
    ),
    strip.text.x = element_text(size = 18),
    plot.caption = element_text(size = 18),
    legend.text = element_text(size = 18),
    legend.title = element_text(size = 18),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey")
  )
p_tvar_coeffs
ggsave(
  plot = p_tvar_coeffs,
  file = "my_marginals/test.png",
  width = 10,
  heigh = 10
)


era5_info <- info |>
  dplyr::select(starts_with("era5_"), "city", "state", "yyyymm")
era5_info_long <- era5_info |>
  tidyr::pivot_longer(
    cols = starts_with("era5_"),
    names_to = "var",
    values_to = "value"
  )
era5_info_long$stat <- sub(".*_(.*)", "\\1", era5_info_long$var)
era5_info_long$var <- sub("^[^_]*_([^_]*)_.*$", "\\1", era5_info_long$var)
era5_info_wide <- era5_info_long |>
  tidyr::pivot_wider(
    names_from = stat,  # Column to use for new column names
    values_from = value  # Column to use for values
  )

row_to_normal_df <- function(mean, sd, var, cs) {
  sd <- as.numeric(sd)
  mean <- as.numeric(mean)
  x <- seq(mean - 4 * sd, mean + 4 * sd, length.out = 100)
  y <- dnorm(x, mean = mean, sd = sd)
  df <- data.frame(cbind(x, y, rep(var, 100), rep(cs, 100)))
  names(df) <- c("x", "y", "var", "cs")
  return(df)
}
result_list <- apply(
  era5_info_wide,
  1,
  function(x) row_to_normal_df(x[3], x[4], x[2], x[1])
)
result_df <- do.call(rbind, result_list)
result_df$x <- as.numeric(result_df$x)
result_df$y <- as.numeric(result_df$y)

p_era5 <- ggplot(result_df, aes(x = x, y = y)) +
  geom_line(aes(group = cs, color = cs)) +
  facet_wrap(vars(var), scales = "free", ncol = 6) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(values = color_cs) +
  labs(x = "", y = "", color = "") +
  guides(color = guide_legend(keywidth = unit(2, "cm"))) +
  ggplot2::theme(
    axis.text = ggplot2::element_text(size = 12),
    axis.title = ggplot2::element_text(size = 20),
    strip.text.x = element_text(size = 20),
    plot.caption = ggplot2::element_text(size = 10),
    legend.text = ggplot2::element_text(size = 20),
    legend.title = ggplot2::element_text(size = 20),
    legend.position = "top",
    panel.background = ggplot2::element_rect(fill = "white"),
    panel.grid.major = ggplot2::element_line(colour = "grey")
  )
ggsave(
  plot = p_era5,
  "./graphs/era5_coefficients_posterior.pdf",
  width = 13,
  height = 3,
  dpi = 300
)
