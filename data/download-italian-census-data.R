# This script downloads the Italian census data
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



# Data download -----------------------------------------------------------

# Downlaod the data from ISTAT and unzip the files

for (census_year in c(1991, 2001, 2011)) {
  # Set region file name
  census_file <- 
    paste0(
      "dati-cpa_",
      census_year,
      ".zip"
    )  
  cat("Retrieving", census_file, "\n")
  
  if (!file.exists(file.path(paste0("storage/", census_file)))) {
    
    # Download file
    download.file(
      url = paste0(
        "https://www.istat.it/storage/cartografia/variabili-censuarie/",
        census_file
      ),
      destfile = paste0(
        "storage/",
        census_file
      )
    )
    
  }
  
  if (!dir.exists(file.path(paste0("storage/", str_sub(census_file, end = -5))))) {
    
    # Unzip
    unzip(
      paste0(
        "storage/",
        census_file
      ),
      exdir = paste0("storage/", str_sub(census_file, end = -5))
    )
  
  }
}


# Combine -----------------------------------------------------------------

# Combine all the data for all the regions for 2011 to a single dataset

census_data <- NA
  
for (region_id in 1:20) {

  # Set region file name
  region_csv <- 
    paste0(
      "storage/dati-cpa_2011/Sezioni di Censimento/R",
      str_pad(region_id, 2, pad = "0"),
      "_indicatori_2011_sezioni.csv"
    )  
  cat("Loading", region_csv, "\n")
  # If this is the first region
  # simply load it
  if (region_id == 1){
    census_data <- 
      read_delim(
        region_csv, 
        delim = ";",
        col_types = paste(c(rep("c", 12), rep("i", 140)), collapse="")
        )
    # otherwise
    # load it and bind it to previous regions
  } else {
    census_data <-
      census_data %>% 
      bind_rows(
        read_delim(
          region_csv, 
          delim = ";",
          col_types = paste(c(rep("c", 12), rep("i", 140)), collapse="")
        )
      )
  }

}


# Save --------------------------------------------------------------------

census_data %>% 
  write_csv("storage/dati-cpa_2011_all.csv")

rm(list = ls())