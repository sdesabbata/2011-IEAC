# Cluster sensitivity analysis
# 
# It uses data from ISTAT distributed under CC BY 3.0 IT
# Source: https://www.istat.it/it/archivio/104317
# Legal notice: https://www.istat.it/it/note-legali
# Licence: https://creativecommons.org/licenses/by/3.0/it/deed.en
#
# Author: Stefano De Sabbata
# Date: 26 April 2022

library(tidyverse)
library(magrittr)
library(knitr)
library(sf)
library(patchwork)
library(ggrepel)

# Data

census_data_trans_selected <-
  read_csv(
    "storage/dati-cpa_2011_all-trans-selected-v0_0_4.csv",
    col_types = paste(c(rep("c", 12), rep("d", 116)), collapse="")
  )

# Sensitivity analysis
#
# Assess WCSS and BCSS as each variable is iteratively removed. 
# Where the removal of a variable leads lower WCSS and higher 
# BCSS than average, that indicates that removing that variable 
# from the clustering process would lead to more homogeneous 
# and distinct clusters.

census_var_names <-
  census_data_trans_selected %>%
  dplyr::select(P1_norm_log10_std:E30_E31_norm_std) %>% 
  colnames()

sensitivity_analysis_first_var <- TRUE
ieac_k08_v0_0_4_sensitivity_analysis <- NA

for (i_var in 1:length(census_var_names)) {
  
  i_var_name <- census_var_names[i_var]
  cat(i_var_name, "... ")
  
  wcss_testing <- c()
  bcss_testing <- c()
  
  for (j in 1:100){
    
    cat(j, " ")
    
    data_for_sensitivity_analysis <-
      census_data_trans_selected %>%
      slice_sample(prop = 0.01) %>% 
      select(P1_norm_log10_std:E30_E31_norm_std) %>%
      select(-{{ i_var_name }})
    
    j_kmeans <-
      data_for_sensitivity_analysis %>% 
      kmeans(
        centers = 8, iter.max = 5000,
        algorithm = "Lloyd"
      )
    
    wcss_testing <- 
      c(
        wcss_testing,
        j_kmeans %$%
          tot.withinss
      )
    bcss_testing <- 
      c(
        bcss_testing,
        j_kmeans %$%
          betweenss
      )
  
  }
  
  cat("\n")
  
  if (sensitivity_analysis_first_var) {
    sensitivity_analysis_first_var <- FALSE
    ieac_k08_v0_0_4_sensitivity_analysis <-
      tibble(
        census_variable = i_var_name,
        wcss = mean(wcss_testing),
        bcss = mean(bcss_testing)
      )
  } else {
    ieac_k08_v0_0_4_sensitivity_analysis <-
      ieac_k08_v0_0_4_sensitivity_analysis %>% 
      add_row(
        census_variable = i_var_name,
        wcss = mean(wcss_testing),
        bcss = mean(bcss_testing)
      )
  }
}

# Save results

ieac_k08_v0_0_4_sensitivity_analysis %>% 
  saveRDS("storage/ieac_k08_v0_0_4_sensitivity_analysis.rds")
