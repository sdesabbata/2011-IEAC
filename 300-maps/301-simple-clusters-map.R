# Simple cluster map
# 
# It uses data from ISTAT distributed under CC BY 3.0 IT
# Source: https://www.istat.it/it/archivio/104317
# Legal notice: https://www.istat.it/it/note-legali
# Licence: https://creativecommons.org/licenses/by/3.0/it/deed.en
#
# Author: Stefano De Sabbata
# Date: 16 April 2022

library(tidyverse)
library(sf)
library(tmap)

preliminary_clustering_map <-
  read_sf("storage/ieac_k08-with-vars-v0_0_4_6/ieac_k08-with-vars-v0_0_4_6.shp") %>% 
  # mutate(ieac_k08 = as.character(ieac_k08)) %>% 
  mutate(
    ieac_k08 = recode(
      ieac_k08,
        `1` = "C",
        `2` = "D",
        `3` = "F",
        `4` = "A",
        `5` = "B",
        `6` = "G",
        `7` = "E",
        `8` = "H"
      )
  ) %>% 
  tmap::tm_shape() +
  # Define the choropleth aesthetic
  tmap::tm_polygons(
    "ieac_k08",
    title = "Preliminary\nclusters\n(v0.0.4-6)",
    palette = "Set1",
    legend.show = TRUE,
    border.alpha = 0,
    colorNA = NULL,
    showNA = FALSE
  ) +
  # Define the layout
  tmap::tm_layout(
    frame = FALSE,
    legend.title.size=1,
    legend.text.size = 0.5,
    legend.position = c("right","top")
  ) +
  # Don't forget the appropriate attribution
  tmap::tm_credits(
    "by Stefano De Sabbata\nThis is a work in progress, no conclusions should be drawn from this draft.\nhttps://github.com/sdesabbata/2011-IEAC\nSource: data from ISTAT distributed under CC BY 3.0 IT (https://www.istat.it/it/archivio/104317)",
    size = 0.3,
    position = c("left", "bottom")
  )
  
# Save image
tmap_save(
  preliminary_clustering_map, 
  "storage/ieac_k08-with-vars-v0_0_4_6-300dpi.png", 
  width = 210, height = 298, asp=0,
  units = "mm", dpi = 300
  )

# Save image
tmap_save(
  preliminary_clustering_map, 
  "storage/ieac_k08-with-vars-v0_0_4_6-2400dpi.png", 
  width = 210, height = 298, asp=0,
  units = "mm", dpi = 2400
)

# Clear
rm(list = ls())
