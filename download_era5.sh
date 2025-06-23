#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=geo

#python era5_requests.py 2019
#python era5_requests.py 2020
python era5_requests.py 2021
python era5_requests.py 2022
python era5_requests.py 2023
python era5_requests.py 2024
