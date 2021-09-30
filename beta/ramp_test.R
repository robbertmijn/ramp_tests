library(data.table)
library(fitdc)
d <- fread("Ramp_Test.csv", fill = T)
a <- read_fit("Ramp_Test (1).fit")

recs <- d[Message == "record" & Type == "Data", .()]
laps <- d[Message == "lap" & Type == "Data"]
