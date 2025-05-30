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


controller_30 <- crew::crew_controller_local(
  name = "controller_30",
  workers = 50
)

controller_geo <- crew.cluster::crew_controller_slurm(
  name = "controller_geo",
  workers = 100
)


if (Sys.getenv("CONTAINER") == "samba") {
  spec_packages <- c(
    "amadeus",
    "brassens",
    "mercury",
    "samba"
  )
} else {
  spec_packages <- c("terra", "tidyterra")
}

targets::tar_option_set(
  packages = c(
    spec_packages,
    c(
      "crew.cluster",
      "data.table",
      "lubridate",
      "sf",
      "targets"
    )
  ),
  repository = "local",
  error = "continue",
  memory = "transient",
  format = "qs",
  storage = "worker",
  deployment = "worker",
  garbage_collection = TRUE,
  seed = 202401L,
  controller = crew::crew_controller_group(
    controller_geo, controller_30
  ),
  resources = targets::tar_resources(
    crew = targets::tar_resources_crew(controller = "controller_30")
  ),
  retrieval = "worker"
)

# Run the R scripts in the R/ folder with your custom functions:
targets::tar_source()
targets::tar_source("inst/targets/target_data_creation.R")
targets::tar_source("inst/targets/target_rasters_storage.R")

if (Sys.getenv("CONTAINER") == "samba") {
  target_rasters_storage <- list()
}

list(
  target_data_creation,
  target_rasters_storage
)