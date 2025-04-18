# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(crew)
library(crew.cluster)
library(geotargets)


controller_10 <- crew::crew_controller_local(
  name = "controller_10",
  workers = 10
)

controller_geo <- crew.cluster::crew_controller_slurm(
  name = "controller_geo",
  workers = 4
)

targets::tar_option_set(
  packages = c(
    "amadeus",
    "brassens",
    "crew.cluster",
    "data.table",
    "lubridate",
    "mercury",
    "samba",
    "targets"
  ),
  #imports = c( # keep track of these packages updates in the target pipeline
  #  "brassens",
  #  "mercury",
  #  "samba"
  #),
  repository = "local",
  error = "continue",
  memory = "transient",
  format = "qs",
  storage = "worker",
  deployment = "worker",
  garbage_collection = TRUE,
  seed = 202401L,
  controller = crew::crew_controller_group(
    controller_geo, controller_10
  ),
  resources = targets::tar_resources(
    crew = targets::tar_resources_crew(controller = "controller_10")
  ),
  retrieval = "worker"
)


# Run the R scripts in the R/ folder with your custom functions:
tar_source()

list(
  tar_target(
    name = test,
    command = as.character(list.dirs("/", recursive = FALSE)),
    format = "rds"
  ),
  tar_target(
    name = test2,
    command = as.character(
      list.dirs("/WU_IBM/", recursive = FALSE)
    ),
    format = "rds"
  ),
  tar_target(
    name = input,
    command = "./input/case_studies_list.csv",
    format = "file"
  ),
  tar_target(
    name = load_cs,
    command = read.csv(input)
  ),
  tar_target(
    name = my_cs,
    command = load_cs |>
      dplyr::group_by(NAME, ts, te) |>
      tar_group(),
    iteration = "group"
  ),
  tar_terra_vect(
    name = cs_inv,
    command = terra::vect(unique(my_cs$cws_inv_file)),
    pattern = map(my_cs)
  )
)