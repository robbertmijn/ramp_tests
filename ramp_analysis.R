# if(!requireNamespace("remotes")) {
#   install.packages("remotes")
# }
# remotes::install_github("grimbough/FITfileR")
library(FITfileR) # to read fitfiles, download through github
library(data.table)
library(ggplot2); theme_set(theme_classic())
library(lubridate) # to parse timestamps
library(zoo) # to smooth signal

# locate fitfiles in wd
files <- Sys.glob("*.fit")

# populate data.table
alldat <- NULL
for(i in 1:length(files)){
  cat("processing", files[i], "\n")
  temp <- readFitFile(files[i])
  
  # get lap info saved by zwift
  tlaps <- data.table(laps(temp))
  
  # Find the start_time of the first lap that lasted 60 seconds (start of the ramp test)
  start_time <- tlaps[total_timer_time == 60, head(start_time, 1)]
  
  # get records
  trecs <- data.table(records(temp))
  
  # make time relative to start of the ramp test
  trecs[, t := timestamp - start_time]
  
  # keep only variables of interest and bind to table
  alldat <- rbind(alldat, trecs[, .(t, 
                                    power, 
                                    heart_rate, 
                                    cadence, 
                                    timestamp, 
                                    date = as.factor(date(timestamp)))])
}

# Smooth hr and power with rolling mean of 10 seconds
alldat[, hr := rollmean(heart_rate, 10, fill = T), by = date]
alldat[, power.s := rollmean(power, 10, fill = T), by = date]

alldat[, v.power.s := power.s - shift(power.s)]
alldat <- merge(alldat, alldat[power.s - shift(power.s) < -20, .(duration = min(t)), by = date], by = "date")
alldat[, power.s := ifelse(t > duration, NA, power.s)]

# transform so heartrate and power have similar scale
hr_power_scale <- 3
hr_power_intercept <- 300
alldat[, hr.t := (hr * hr_power_scale) - hr_power_intercept]

# plot
interval <- c(-10, 1000)
ggplot(alldat[t %between% interval], aes(x = t, color = date)) +
  scale_x_continuous(name = "Time (s)") +
  geom_line(aes(y = power.s), alpha = .8) +
  geom_line(aes(y = hr.t), alpha = .8) +
  scale_color_brewer(palette = "Dark2") +
  scale_y_continuous(name = "Power", sec.axis = sec_axis(trans=~(.+hr_power_intercept)/hr_power_scale, name="Heart Rate")) +
  geom_vline(xintercept = seq(0, 1000, by = 60), alpha = .1)
