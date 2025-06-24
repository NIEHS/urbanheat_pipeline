#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=normal
#SBATCH --output=slurm_messages_movies/slurm-%j.out
#SBATCH --error=slurm_messages_movies/slurm-%j.err

RASTER_FILE="./output/ca_los_angeles_202005/inference_predmean_ca_los_angeles_2020050101_2020053123.tif"
SHAPE_FILE="./input/shapes/NTAD_North_American_Roads_-6941702301048783378/North_American_Roads.shp"
TIMEZONE="UTC"
OUTPUT_DIR="my_movies"
OUTPUT_FILENAME="ca_los_angeles_202005"
UHI_RANGE=20

apptainer exec container/container_movies.sif bash -c "
  Rscript create_maps_for_movie.R \"$RASTER_FILE\" \"$SHAPE_FILE\" \"$TIMEZONE\" \"$OUTPUT_DIR\"/temporary_\"$OUTPUT_FILENAME\" \"$UHI_RANGE\" \"$OUTPUT_FILENAME\" &&
  ffmpeg -y -framerate 10 -i "$OUTPUT_DIR"/temporary_"$OUTPUT_FILENAME"/%d.png -c:v libx264 -pix_fmt yuv420p "$OUTPUT_DIR"/"$OUTPUT_FILENAME".mp4
  rm -r "$OUTPUT_DIR"/temporary_"$OUTPUT_FILENAME"
"
