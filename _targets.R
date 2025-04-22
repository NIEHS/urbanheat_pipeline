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
  workers = 10
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
    "sf",
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
    name = input,
    command = "./input/case_studies_list.csv",
    format = "file"
  ),
  tar_target(
    name = my_cs,
    command = read.csv(input) |>
      dplyr::group_by(NAME, ts, te) |>
      tar_group(),
    iteration = "group",
    format = "rds"
  ),
  tar_target(
    name = cs_brassens,
    command = run_brassens(my_cs),
    pattern = map(my_cs),
    iteration = "list",
    format = "rds",
  )
)
