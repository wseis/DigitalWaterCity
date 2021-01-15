library(readxl)
library(tidyverse)
# define patho to excel file
xl_data <- "Database 18-09-2020/Rain/pluvio VDM/pluvios_2016-2019_moy5_tabuchi(VDM).xlsx"

# get names of excel sheets
tab_names <- excel_sheets(path = xl_data)

# read data
list_all <- lapply(tab_names, function(x) read_excel(path = xl_data, sheet = x))

# name list elements
names(list_all) <- as.character(2016:2019)

for(i in names(list_all))
  {
    list_all[[i]] <- as.data.frame(apply(list_all[[i]], 2, as.character))
  }

l <- bind_rows(list_all)

l[,2:ncol(l)] <- apply(l[,2:ncol(l)], 2, as.numeric)
l.tidy <- l %>% gather(gauge, value, -Date)

write.table(x = l.tidy, file = "data_processed/rain_siaap.csv")
