# 1) set days:
library(lubridate)

data$day <- day(data$datetime)

data$week_day <- weekdays.POSIXt(data$dtetime)

data_by_day <- data %>% group_by(day)

summarize(data_by_day,sum(jd))

data_by_wday <- data %>% group_by(week_day)

summarize(data_by_wday,sum(jd))
# for each machine

summarize(data_by_wday,mean(airt),na.rm=T)

# check https://www.neonscience.org/dc-time-series-subset-dplyr-r