library(tidyverse)
library(readr)
Metadata <- read_csv("Database 18-09-2020/Metadata.csv", 
                     col_types = cols(SiteID = col_integer(), 
                                      X1 = col_skip(), X25 = col_skip(), 
                                      X26 = col_skip(), X27 = col_skip()))

folder <- "Database 18-09-2020/Flows/"

path <- paste0(getwd(),"/", folder)
               
directories <-   dir(path = path)
flows <- list()
flows2 <- list()

for(i in directories[2:length(directories)]){
  names  <- dir(paste0(path, i))
  
  for(name in names){
    if(!str_detect(name, "xlsx")){
      flows[[name]] <- fread(file = paste0(folder,i,"/",name), skip =1) %>% mutate(site = i)
      flows2[[i]][[name]] <- fread(file = paste0(folder,i,"/",name), skip =1) %>% mutate(site = i)
      
    }
  }
  
}

select <-  str_detect(names(flows), "CD94")

flowsCD94 <- flows[select]

for(i in names(flowsCD94)){
  colnames(flowsCD94[[i]]) <- c("date", "value", "site")
  flowsCD94[[i]]$value <- as.character(flowsCD94[[i]]$value)
}

df_CD94 <- bind_rows(flowsCD94)

#write.table(x = df_CD94, file = "flowsCD94.csv")

selectVDP <- str_detect(names(flows), "VDP")
flowsVDP <- flows[selectVDP]

for(i in names(flowsVDP)){
  
  if(colnames(flowsVDP[[i]])[1]=="V1"){
    flowsVDP[[i]] <- flowsVDP[[i]][2:nrow(flowsVDP[[i]])]  
  }
  colnames(flowsVDP[[i]]) <- c("date", "value", "site")
  flowsVDP[[i]]$value <- str_replace_all(flowsVDP[[i]]$value, ",", ".")

}

df_VDP <- bind_rows(flowsVDP)

flows_new <- flows[!select]

select2 <- str_detect(names(flows_new), "VDP")
flows_new <- flows_new[!select2]

select_SSD <- str_detect(names(flows_new), "SSD")
flowsSSD <- flows_new[select_SSD]

# removing first large dataset: Is it only all data combined?
flowsSSD <- flowsSSD[2:6]

for(i in names(flowsSSD)){
  colnames(flowsSSD[[i]]) <- c("date", "value", "site")
  flowsSSD[[i]]$value <- str_replace_all(flowsSSD[[i]]$value, ",", ".")
}


df_SSD <- bind_rows(flowsSSD)

flowsSIAAP <- flows[str_detect(names(flows), "SIAAP")] %>% as.data.frame()
colnames(flowsSIAAP) <- c("date", "value", "site")

df_SIAAP <- flowsSIAAP


flows <- bind_rows(df_SIAAP, df_CD94, df_VDP, df_SSD)
write.table(x = flows, file = "flows.csv")
