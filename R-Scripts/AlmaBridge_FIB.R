library(tidyverse)
library(lubridate)
library(readr)

# Import dataset
Pont_de_l_Alma_2019_DWC <- read_delim("Database 18-09-2020/FIB/Pont Alma/Pont de l'Alma_2019 DWC.csv", 
                                      ";", escape_double = FALSE, trim_ws = TRUE)

Pont_Alma_RG_2016_2019 <- read_delim("Database 18-09-2020/FIB/Pont Alma/Pont_Alma_RG_2016_2019.csv", 
                                     ";", escape_double = FALSE, trim_ws = TRUE)


# replacing white space with underscore
colnames(Pont_Alma_RG_2016_2019) <- str_replace_all(colnames(Pont_Alma_RG_2016_2019), pattern = " ", replacement = "_")
colnames(Pont_de_l_Alma_2019_DWC) <- str_replace_all(colnames(Pont_de_l_Alma_2019_DWC), pattern = " ", replacement = "_")

# Selecting relevant columns from data-frame
alma_vdp <- Pont_Alma_RG_2016_2019 %>% 
            dplyr::select(Date_and_time_of_sampling, 
                          Result_analysis, 
                          Parameter_name,
                          Data_provider)

alma_dwc <- Pont_de_l_Alma_2019_DWC %>%dplyr::select(Date_and_time_of_sampling, 
                                                 Result_analysis, 
                                                 Parameter_name,
                                                 Data_provider) 
# Converiting date from string to date object
alma_vdp$Date_and_time_of_sampling <- lubridate::dmy(alma_vdp$Date_and_time_of_sampling)
alma_dwc$Date_and_time_of_sampling <- lubridate::dmy_hm(alma_dwc$Date_and_time_of_sampling)
alma_dwc$Result_analysis <- as.numeric(alma_dwc$Result_analysis)

alma <- bind_rows(alma_vdp, alma_dwc)

#plotting first histogram
alma$month <- lubridate::month(alma$Date_and_time_of_sampling)
alma$year <- lubridate::year(alma$Date_and_time_of_sampling)

alma %>% filter(month >4 & month <12) %>%
ggplot( aes(x = log10(Result_analysis), fill = Data_provider))+ 
  geom_histogram(col = "steelblue") + 
  ggtitle("Overview measurements") + xlab("lg (E.coli) MPN/100mL")

#plotting Timeseries


alma %>% filter(Date_and_time_of_sampling > "2015-01-01") %>%
  ggplot( aes(x = Date_and_time_of_sampling,
                 y = log10(Result_analysis),
                 col = Data_provider))+ 
  geom_point(alpha = 0.5, size = 3) + 
  ggtitle("Overview measurements") + 
  xlab("Time") + ylab("lg (E.coli) [MPN/100mL]")

alma %>% filter(Data_provider =="VDP") %>%
  ggplot( aes(x = month,
              y = log10(Result_analysis)))+
  facet_wrap(.~year)+
  geom_point(alpha = 0.7, size = 3, col = "steelblue") + 
  ggtitle("Overview measurements", subtitle = "Ville de Paris only") + 
  xlab("Month of the year") + ylab("lg (E.coli) [MPN/100mL]")


# Calculation of 90th percentile (all data)
10^(mean(log10(alma_vdp$Result_analysis)) + 
      1.282*sd(log10(alma_vdp$Result_analysis)))

# Calculation of 90th percentile (all data)
10^(mean(log10(alma_vdp$Result_analysis)) +
      1.65*sd(log10(alma_vdp$Result_analysis)))

# ration of datapoint below 1000
mean(alma_vdp$Result_analysis < 1000)


