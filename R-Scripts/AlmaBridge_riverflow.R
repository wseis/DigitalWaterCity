library(readr)

Alfortville_Seine_1h_2016_2019 <- read_delim("Database 18-09-2020/Rivers flows/Alfortville_Seine_1h_2016_2019.csv", 
                                             ";", escape_double = FALSE, 
                                             col_types = cols(Date = col_datetime(format = "%d/%m/%Y %H:%M")), 
                                             trim_ws = TRUE, skip = 9)[,1:2]

Creteil_Marne_1h_2106_2019 <- read_delim("Database 18-09-2020/Rivers flows/Creteil_Marne_1h_2106_2019.csv", 
                                         ";", escape_double = FALSE, 
                                         col_types = cols(Date = col_datetime(format = "%d/%m/%Y %H:%M")), 
                                         trim_ws = TRUE, skip = 9)[,1:2]

flow <- left_join(Alfortville_Seine_1h_2016_2019, Creteil_Marne_1h_2106_2019, by = "Date")
colnames(flow) <- c("date", "Alfortville", "Creteil")

flow$total <- flow$Alfortville + flow$Creteil




ggplot(flow, aes(date, total))+ geom_line()
ggplot(flow, aes(date, Alfortville/Creteil))+ geom_line()
ggplot(flow, aes(Alfortville, Creteil))+
  geom_point(alpha = .3)+
  geom_smooth()

cor(flow$Alfortville, flow$Creteil,
    use = "pairwise.complete.obs")
