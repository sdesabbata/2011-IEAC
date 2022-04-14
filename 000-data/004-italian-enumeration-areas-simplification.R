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


# Simplify ----------------------------------------------------------------

read_sf("storage/italian-enumeration-areas-2011.geojson") %>% 
  st_transform(crs = 23032) %>% 
  st_simplify(dTolerance = 100) %>% 
  st_transform(crs = 4326) %>% 
  write_sf("storage/italian-enumeration-areas-2011-simplfd100m.geojson")

read_sf("storage/italian-enumeration-areas-2011.geojson") %>% 
  st_transform(crs = 23032) %>% 
  st_simplify(dTolerance = 250) %>% 
  st_transform(crs = 4326) %>% 
  write_sf("storage/italian-enumeration-areas-2011-simplfd250m.geojson")