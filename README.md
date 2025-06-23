# A factory to generate air temperature data at hourly resolution on US cities!

This project is an assembly line using [brassens](github.com/NIEHS/brassens/), [samba](github.com/NIEHS/samba) and [mercury](github.com/NIEHS/mercury) libraries to automatically generate 2-meters air temperature rasters on a list of US cities and observed months.  

This pipeline has generate casestudies on the top largest Urban Census areas on different climatic events (heatwave, blizzard, typical weather...) and seasons. This dataset has been designed for environmental epidemiology and public health studies on (extreme) temperature exposure in US cities. It can also be leveraged by urban climatologists to improve our understanding of the spatiotemporal evolution of the urban heat island with regard to the variety of city layout and climatic region in the US. 

To cite the dataset: Marques, E., & Messier, K. (2025). Urban air temperature at high spatiotemporal resolution on major US cities (soon available) [Dataset]. Harvard Dataverse. https://doi.org/10.7910/DVN/HNVCBR756



#### Urban heat island movie generation

If you want to create a movie from the 2m-air temperature raster:
- go on our [urbanheat_pipeline Github repository](github.com/NIEHS/urbanheat_pipeline/).
- download `container/container_movies.def`, `create_movie.sh` and `create_maps_for_movie.R`
- open a terminal and build the container (you need to have apptainer installed). It might take a few minutes. 

```{bash}
apptainer build --fakeroot container_movies.sif container_movies.def
```

- run create_movie.sh after changing the value of the VARIABLES. For the SHAPE_FILE, we use an open source dataset of American Roads available on the open data portal of the US Department of Transportation, but it can be any other shapefile. 

The movie will take a few minutes to be generated, and will be available in the folder defined in OUTPUT_DIR. 

Note: the color stands for $T2M_{avg\_area\_time\_t} - T2M_{point\_time\_t}$. It has not been corrected with elevation thermal gradient, so it is not strictly considered as an urban heat island, but rather a temperature differential to the regional mean. 