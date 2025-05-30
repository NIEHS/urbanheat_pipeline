#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=50
#SBATCH --partition=highmem
#SBATCH --output=slurm_messages/slurm-%j.out
#SBATCH --error=slurm_messages/slurm-%j.err


export CONTAINER=movies

apptainer exec \
  container/container_movies.sif Rscript inst/targets/target_run.R
