#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=geo
#SBATCH --output=slurm_messages/slurm-%j.out
#SBATCH --error=slurm_messages/slurm-%j.err

#apptainer shell container/container_samba.sif
#apptainer exec container/container_samba.sif
apptainer exec container/container_samba.sif Rscript run.R
#Rscript run.R