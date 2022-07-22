# Simple cluster characteristics visualisation
# 
# It uses data from ISTAT distributed under CC BY 3.0 IT
# Source: https://www.istat.it/it/archivio/104317
# Legal notice: https://www.istat.it/it/note-legali
# Licence: https://creativecommons.org/licenses/by/3.0/it/deed.en
#
# Author: Stefano De Sabbata
# Date: 23 April 2022

library(tidyverse)
library(ggplot2)


# Data --------------------------------------------------------------------

vars_with_preliminary_clusters <-
  read_csv("storage/ieac_k20-with-vars-v0_0_4_20.csv") %>% 
  filter(!is.na(ieac_k20h))

vars_cluster_averages_long <-
  vars_with_preliminary_clusters %>% 
  select(ieac_k20h, P1_norm_log10_std:E30_E31_norm_std) %>% 
  group_by(ieac_k20h) %>% 
  summarise(
    across(
      P1_norm_log10_std:E30_E31_norm_std,
      mean
    )
  ) %>% 
  ungroup() %>% 
  pivot_longer(
    cols = -ieac_k20h,
    names_to = "variable",
    values_to = "average"
  )

vars_cluster_averages_heatmap <-
  vars_cluster_averages_long %>% 
  mutate(
    variable =
      factor(
        variable,
        levels = 
          vars_with_preliminary_clusters %>% 
            select(P1_norm_log10_std:E30_E31_norm_std) %>% 
            colnames() %>% 
            rev(),
        ordered = TRUE
      )
  ) %>%
  mutate(
    average_class = 
      factor(
        case_when(
          average <= -1  ~ "(-Inf, -1]",
          average <= -0.5  ~ "(-1, -0.5]",
          average <= -0.1  ~ "(-0.5, -0.1]",
          average <= 0  ~ "(-0.1, 0]",
          average <= 0.1  ~ "(0, 0.1]",
          average <= 0.5  ~ "(0.1, 0.5]",
          average <= 1  ~ "(0.5, 1]",
          TRUE  ~ "(1, +Inf)"
        ),
        levels = c(
          "(-Inf, -1]",
          "(-1, -0.5]",
          "(-0.5, -0.1]",
          "(-0.1, 0]",
          "(0, 0.1]",
          "(0.1, 0.5]",
          "(0.5, 1]",
          "(1, +Inf)"
        ),
        order = TRUE
      )
  ) %>% 
  ggplot2::ggplot(
    aes(
      x = ieac_k20h,
      y = variable
    )
  ) +
  ggplot2::geom_tile(aes(fill = average_class)) +
  ggplot2::xlab("Cluster (ieac_k20, v0.0.4-20)") + 
  ggplot2::ylab("Variable") +
  ggplot2::scale_fill_brewer(palette = "RdBu") +
  ggplot2::theme_bw()

ggsave(
  "storage/ieac_k20_v0_0_4_20_cluster_averages.png", 
  plot = vars_cluster_averages_heatmap, 
  width = 210, height = 596, 
  units = "mm", dpi = 300
  )