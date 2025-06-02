#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=geo
#SBATCH --output=slurm_messages/slurm-%j.out
#SBATCH --error=slurm_messages/slurm-%j.err

echo "Creating samba data"
sbatch --wait inst/scripts/run_data_creation.sh

echo "Manipulating rasters"
sbatch --wait inst/scripts/run_rasters_storage.sh