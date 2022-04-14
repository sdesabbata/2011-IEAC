# This app visualises the results of the 2011 IEAC v0.0.3
# 
# It uses data from ISTAT distributed under CC BY 3.0 IT
# Source: https://www.istat.it/it/archivio/104317
# Legal notice: https://www.istat.it/it/note-legali
# Licence: https://creativecommons.org/licenses/by/3.0/it/deed.en
#
# Author: Stefano De Sabbata
# Date: 14 April 2022
#
# Code derived from the example available here:
# https://rstudio.github.io/leaflet/shiny.html
# https://rstudio.github.io/leaflet/map_widget.html
# https://community.rstudio.com/t/how-to-plot-leaflet-map-in-shiny-mainpanel/107079/3

library(shiny)
library(leaflet)

ui <- fluidPage(
  titlePanel("2011 IEAC v0.0.3"),
  mainPanel(
    div("Still very much a work in progress! :)"),
    leafletOutput("ieac_map", height="90vh", width="90vh")
  )
)

server <- function(input, output, session) {
  
  
  output$ieac_map <- renderLeaflet({
    
    ieac_k08_fvg <- readRDS("ieac_k08-with-vars-v0_0_3-FVG.rds")
    
    ieac_k08_fvg <-
      ieac_k08_fvg %>% 
      mutate(
        ieac_k08 = recode(
          ieac_k08,
            `1` = "D",
            `2` = "H",
            `3` = "B",
            `4` = "C",
            `5` = "E",
            `6` = "F",
            `7` = "A",
            `8` = "G"
          )
      )

    
    palette <- colorFactor("Set1", domain = ieac_k08_fvg$ieac_k08)
    
    leaflet(ieac_k08_fvg) %>%
      addProviderTiles(
        providers$Stamen.Toner
        #,
        #options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addPolygons(
        fillColor = ~palette(ieac_k08), 
        stroke = FALSE,
        fillOpacity = 0.7
      )
  })
}

shinyApp(ui, server)