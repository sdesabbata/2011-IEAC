# This script downloads all the shapefiles for the Italian enumeration areas
# from the ISTAT website and creates a geojson file for the whole of Italy
# 
# It downloads data from ISTAT distributed under CC BY 3.0 IT
# Source: https://www.istat.it/it/archivio/104317
# Legal notice: https://www.istat.it/it/note-legali
# Licence: https://creativecommons.org/licenses/by/3.0/it/deed.en
#
# Author: Stefano De Sabbata
# Date: 11 April 2022



# Libraries ---------------------------------------------------------------

library(tidyverse)
library(sf)


# Data download -----------------------------------------------------------

# Downlaod the data from ISTAT and unzip the files

for (region_id in 1:20) {
  # Set region file name
  region_file <- 
    paste0(
      "R",
      str_pad(region_id, 2, pad = "0"),
      "_11_WGS84.zip"
    )  
  cat("Retrieving", region_file, "\n")
  
  if (!file.exists(file.path(paste0("storage/", region_file)))) {
  
    # Download file
    download.file(
      url = paste0(
        "https://www.istat.it/storage/cartografia/basi_territoriali/WGS_84_UTM/2011/",
        region_file
      ),
      destfile = paste0(
        "storage/",
        region_file
      )
    )
    
  }
  
  if (!dir.exists(file.path(paste0("storage/", str_sub(region_file, end = -5))))) {
    
    # Unzip
    unzip(
      paste0(
        "storage/",
        region_file
      ),
      exdir = "storage"
    )
    
  }
}


# Combine -----------------------------------------------------------------

# Combine all the geometries for all the regions to a single dataset

enum_areas <- NA

for (region_id in 1:20) {
  # Set region file name
  region_shp <- 
    paste0(
      "storage/R",
      str_pad(region_id, 2, pad = "0"),
      "_11_WGS84/R",
      str_pad(region_id, 2, pad = "0"),
      "_11_WGS84.shp"
    )  
  cat("Loading", region_shp, "\n")
  # If this is the first region
  # simply load it
  if (region_id == 1){
    enum_areas <- read_sf(region_shp)
  # otherwise
  # load it and bind it to previous regions
  } else {
    enum_areas <-
      enum_areas %>% 
      rbind(
        read_sf(region_shp)
      )
  }
}


# Save --------------------------------------------------------------------

# Save the dataset as geojson

enum_areas %>%
  write_sf("storage/italian-enumeration-areas-2011.geojson")

rm(list = ls())