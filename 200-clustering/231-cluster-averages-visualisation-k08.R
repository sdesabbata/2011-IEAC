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
  read_csv("storage/ieac_k08-with-vars-v0_0_4_6.csv") %>% 
  filter(!is.na(ieac_k08)) %>% 
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
  )

vars_cluster_averages_long <-
  vars_with_preliminary_clusters %>% 
  select(ieac_k08, P1_norm_log10_std:E30_E31_norm_std) %>% 
  group_by(ieac_k08) %>% 
  summarise(
    across(
      P1_norm_log10_std:E30_E31_norm_std,
      mean
    )
  ) %>% 
  ungroup() %>% 
  pivot_longer(
    cols = -ieac_k08,
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
      x = ieac_k08,
      y = variable
    )
  ) +
  ggplot2::geom_tile(aes(fill = average_class)) +
  ggplot2::xlab("Cluster (ieac_k08, v0.0.4-6)") + 
  ggplot2::ylab("Variable") +
  ggplot2::scale_fill_brewer(palette = "RdBu") +
  ggplot2::theme_bw()

ggsave(
  "storage/ieac_k08_v0_0_4_6_cluster_averages.png", 
  plot = vars_cluster_averages_heatmap, 
  width = 210, height = 596, 
  units = "mm", dpi = 300
  )

# Dendogram ---------------------------------------------------------------

# This section uses the approach described by Jeff Oliver
# to create "Clusters and Heatmaps"
# https://jcoliver.github.io/learn-r/008-ggplot-dendrograms-and-heatmaps.html

# library(ggdendro)
# library(grid)

# vars_cluster_averages <-
#   vars_with_preliminary_clusters %>% 
#   select(ieac_k08, P1_norm_log10_std:E30_E31_norm_std) %>% 
#   group_by(ieac_k08) %>% 
#   summarise(
#     across(
#       P1_norm_log10_std:E30_E31_norm_std,
#       mean
#     )
#   ) %>% 
#   pivot_longer(
#     cols = -ieac_k08,
#     names_to = "variable",
#     values_to = "average"
#   ) %>% 
#   pivot_wider(
#     id_cols = variable,
#     names_from = ieac_k08,
#     values_from = average
#   )
# 
# # Force re-numbering of the rows
# rownames(vars_cluster_averages) <- NULL
# 
# # Run variable clustering
# vars_cluster_averages_matrix <- 
#   vars_cluster_averages %>% 
#   select(A:G) %>% 
#   as.matrix()
# 
# rownames(vars_cluster_averages_matrix) <-
#   vars_cluster_averages %>% 
#   pull(variable)
# 
# vars_dendro <-
#   vars_cluster_averages_matrix %>% 
#   dist() %>% 
#   hclust() %>% 
#   as.dendrogram()
# 
# # Create dendrogram plot
# dendro_plot <- 
#   vars_dendro %>% 
#   ggdendrogram(rotate = TRUE) + 
#   theme(axis.text.y = element_text(size = 6))
# 
# # Heatmap
# 
# # Data wrangling
# vars_cluster_averages_long <- 
#   vars_cluster_averages %>% 
#   mutate(
#     variable = 
#       fct_reorder( 
#         variable,
#         vars_dendro %>% 
#         order.dendrogram()
#       )
#   ) %>% 
#   pivot_longer(
#      cols = -variable,
#      names_to = "measurement",
#      values_to = "value"
#   )
# 
# 
# # Create heatmap plot
# heatmap_plot <-
#   vars_cluster_averages_long %>% 
#   ggplot(aes(x = measurement, y = variable)) +
#   geom_tile(aes(fill = value)) +
#   scale_fill_gradient2() +
#   theme(axis.text.y = element_blank(),
#         axis.title.y = element_blank(),
#         axis.ticks.y = element_blank(),
#         legend.position = "top")
# 
# # All together
# grid.newpage()
# print(heatmap_plot, 
#       vp = viewport(x = 0.4, y = 0.5, width = 0.8, height = 1.0))
# print(dendro_plot, 
#       vp = viewport(x = 0.90, y = 0.43, width = 0.2, height = 0.92))