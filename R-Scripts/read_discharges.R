library(tidyverse)
library(readr)

folder <- "Database 18-09-2020/Rivers flows/"

path <- paste0(getwd(),"/", folder)

directories <-   dir(path = path) 

river_flows <- list()

for(i in directories){
  
  x <- str_split(i,pattern = "_")
  river_flows[[i]] <-  read_delim("Database 18-09-2020/Rivers flows/Alfortville_Seine_1h_2016_2019.csv", 
                                  ";", escape_double = FALSE, 
                                  col_types = cols(Date = col_datetime(format = "%d/%m/%Y %H:%M")), 
                                  trim_ws = TRUE, skip = 9)[,1:2]
  river_flows[[i]]["name"] <- x[[1]][1]
  river_flows[[i]]["river"] <- x[[1]][2]
  
  }

rflows <- bind_rows(river_flows)
write.table(x = rflows, file = "data_processed/river_flows.csv")
