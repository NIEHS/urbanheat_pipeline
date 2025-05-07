#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --partition=highmem
#SBATCH --output=slurm_messages/slurm-%j.out
#SBATCH --error=slurm_messages/slurm-%j.err

#apptainer shell container/container_samba.sif
apptainer exec \
  --bind /ddn/gs1/group/set/WU_IBM:/WU_IBM \
  container/container_samba.sif Rscript run.R
#Rscript run.R