#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --partition=highmem
#SBATCH --output=slurm_messages/slurm-%j.out
#SBATCH --error=slurm_messages/slurm-%j.err


export CONTAINER=samba

# Load the absolute path from an external file
source inst/config/path_config.sh

apptainer exec \
  --bind $WU_IBM_PATH \
  container/container_samba.sif Rscript inst/targets/target_run.R