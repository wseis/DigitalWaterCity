

@@ -1,57 +0,0 @@ 
  Stage chunk	

Discard chunk	

1

library(tidyverse)
library(data.table)

# create path variables

folder <- "Database 18-09-2020/FIB/"

path <- paste0(getwd(),"/", folder)

directories <-   dir(path = path) 


# create empty list for loading data files

FIB <- list()


# load data files

for(i in directories[1:length(directories)])

{

  names  <- dir(paste0(path, i))

  for(name in names)

  {
    FIB[[name]] <- fread(file = paste0(folder,i,"/",name)) %>% 

    mutate( 

      `Result analysis` = as.character(`Result analysis`),

      `Code method analysis SANDRE` = as.character(`Code method analysis SANDRE`),

      `Analytical incetitude` = as.character(`Analytical incetitude`),site=i) 

  }

}  

# combine list entries

FIB <- FIB %>% bind_rows()

# Cleaning column names to lower case without whitespace

FIB <- FIB %>% dplyr::select(-18) %>% rename_with( ~ tolower(gsub(" ", "_", .x, fixed = TRUE)))

FIB <- FIB %>% mutate(result_analysis = as.numeric(str_replace(result_analysis, ",", ".")))

FIB$parameter_name <- str_replace_all(FIB$parameter_name, "E. coli", "E.coli")

FIB$parameter_name <- str_replace_all(FIB$parameter_name, " ", "_")

# deleting empty rows of unknown origin

FIB <- FIB %>% filter(FIB$parameter_name != "") 


FIB_summary <- FIB %>% group_by(station_name, parameter_name) %>% 


summarise(Mean=mean(log10(result_analysis), na.rm=T),
          
          SD=sd(log10(result_analysis), na.rm=T),
          
          p90=Mean + 1.282*SD,
          
          p95=Mean + 1.96*SD,
          
          lt_900=mean(result_analysis<900, na.rm=T),
          
          lt_1000=mean(result_analysis<1000, na.rm=T),

          N=n())

FIB %>% ggplot(aes(x = log10(result_analysis), fill = parameter_name)) + geom_histogram() +

facet_wrap(station_name~.) + theme(legend.position ="bottom") +

ggtitle("Histograms of E.coli measurements at various locations in Paris") +

xlab("E.coli in lg (MPN/100mL)")
write.table(x = FIB, file = "data_processed/FIB.csv")

