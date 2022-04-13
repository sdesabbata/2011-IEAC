# This script calculates the size of enumeration areas in square kilometers
# 
# It uses data from ISTAT distributed under CC BY 3.0 IT
# Source: https://www.istat.it/it/archivio/104317
# Legal notice: https://www.istat.it/it/note-legali
# Licence: https://creativecommons.org/licenses/by/3.0/it/deed.en
#
# Author: Stefano De Sabbata
# Date: 11 April 2022



# Libraries ---------------------------------------------------------------

library(tidyverse)
library(sf)


# Load data ---------------------------------------------------------------

enum_areas <- read_sf("storage/italian-enumeration-areas-2011.geojson")


# Calculate area size -----------------------------------------------------

enum_areas_size <-
  enum_areas %>% 
  select(SEZ2011) %>% 
  st_transform(crs = 23032) %>% 
  mutate(
    sez_area_km2 = 
      st_area(.) %>% 
      as.numeric() %>% 
      `/`(1000000)
  )
  

# Save --------------------------------------------------------------------

enum_areas_size %>% 
  st_drop_geometry() %>% 
  write_csv("storage/italian-enumeration-areas-2011-size-km2.csv")

rm(list = ls())
