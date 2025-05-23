#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --partition=highmem
#SBATCH --output=slurm_messages_movies/slurm-%j.out
#SBATCH --error=slurm_messages_movies/slurm-%j.err

RASTER_FILE="./output/boston_2023070100_2023073123/inference_predmean_boston_2023070100_2023073123.tif"
SHAPE_FILE="./input/shapes/NTAD_North_American_Roads_-6941702301048783378/North_American_Roads.shp"
TIMEZONE="UTC"
START_DATE="2023-07-01 00:00:00"
END_DATE="2023-07-31 23:00:00"
OUTPUT_DIR="my_movies"
OUTPUT_FILENAME="boston_202307"
UHI_RANGE=10

apptainer exec container/container_movies.sif bash -c "
  Rscript R/create_maps_for_movie.R \"$RASTER_FILE\" \"$SHAPE_FILE\" \"$TIMEZONE\" \"$START_DATE\" \"$END_DATE\" \"$OUTPUT_DIR\"/temporary_\"$OUTPUT_FILENAME\" \"$UHI_RANGE\" \"$OUTPUT_FILENAME\" &&
  ffmpeg -y -framerate 10 -i "$OUTPUT_DIR"/temporary_"$OUTPUT_FILENAME"/%d.png -c:v libx264 -pix_fmt yuv420p "$OUTPUT_DIR"/"$OUTPUT_FILENAME".mp4
  rm -r "$OUTPUT_DIR"/temporary_"$OUTPUT_FILENAME"
"