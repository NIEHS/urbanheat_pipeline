# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(crew)
library(crew.cluster)


controller_10 <- crew::crew_controller_local(
  name = "controller_10",
  workers = 10
)

controller_geo <- crew.cluster::crew_controller_slurm(
  name = "controller_geo",
  workers = 10,
  options_cluster = crew.cluster::crew_options_slurm(
    verbose = TRUE,
    script_lines = "apptainer shell container/container_samba.sif"
  )
)


scriptlines_apptainer <- "apptainer"
scriptlines_basedir <- "$PWD"
scriptlines_targetdir <- "/ddn/gs1/home/marquesel/pipeline"
scriptlines_inputdir <- "/ddn/gs1/home/marquesel/input"
scriptlines_container <- "container/container_samba.sif"
scriptlines_geo <- glue::glue(
  "#SBATCH --job-name=samba \
  #SBATCH --partition=geo \
  #SBATCH --error=slurm_messages/slurm_%j.out \
  {scriptlines_apptainer} exec --nv --env ",
  "CUDA_VISIBLE_DEVICES=${{GPU_DEVICE_ORDINAL}} ",
  "--bind {scriptlines_basedir}:/mnt ",
  "--bind {scriptlines_basedir}/inst:/inst ",
  "--bind {scriptlines_inputdir}:/input ",
  "--bind {scriptlines_targetdir}/targets:/opt/_targets ",
  "{scriptlines_container} \\"
)
controller_geo <- crew.cluster::crew_controller_slurm(
  name = "controller_geo",
  workers = 4,
  options_cluster = crew.cluster::crew_options_slurm(
    verbose = TRUE,
    script_lines = scriptlines_geo
  )
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
    name = cs,
    command = data.frame(
      NAME = seq_len(6),
      ts = rep(letters[seq_len(3)], each = 2),
      POP2010 = seq_len(6)
    ) |>
      dplyr::group_by(NAME) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(
    name = pop_calc,
    command = sum(cs$POP2010),
    pattern = map(cs),
    iteration = "vector"
  )
)