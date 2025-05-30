target_data_creation <- list(
  tar_target(
    name = input,
    command = "./input/case_studies_list.csv",
    format = "file"
  ),
  tar_target(
    name = my_cs,
    command = read.csv(input) |>
      dplyr::group_by(NAME, ST, ts, te) |>
      tar_group(),
    iteration = "group",
    format = "rds"
  ),
  tar_target(
    name = cs_brassens_city,
    command = paste(my_cs$NAME, my_cs$ST, my_cs$ts),
    pattern = map(my_cs),
    iteration = "list",
    format = "rds",
  ),
  tar_target(
    name = cs_brassens,
    command = run_brassens(my_cs),
    pattern = map(my_cs),
    iteration = "list",
    format = "rds",
  ),
  tar_target(
    name = cs_bhm_mat_city,
    command = paste(my_cs$NAME, my_cs$ST, my_cs$ts),
    pattern = map(my_cs, cs_brassens),
    iteration = "list",
    format = "rds",
  ),
  tar_target(
    name = cs_bhm_materials,
    command = bhm_materials(my_cs, cs_brassens),
    pattern = map(my_cs, cs_brassens),
    iteration = "list",
    format = "rds",
  ),
  tar_target(
    name = cs_samba_city,
    command = paste(my_cs$NAME, my_cs$ST, my_cs$ts),
    pattern = map(my_cs, cs_bhm_materials),
    iteration = "list",
    format = "rds",
  ),
  tar_target(
    name = cs_samba,
    command = run_samba(my_cs, cs_bhm_materials),
    pattern = map(my_cs, cs_bhm_materials),
    iteration = "list",
    format = "rds"
  )
)