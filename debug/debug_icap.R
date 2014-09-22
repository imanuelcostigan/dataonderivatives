# Debug ICAP headers
require (stringr)
require (lubridate)
require (dplyr)
require (ggplot2)
# Get ICAP data
get_icap_data(ymd(20140731))
# Find ICAP files in temp directory
tempdir <- tempdir()
files <- list.files(file.path(tempdir, c('icus', 'igdl')), full.names = TRUE)
headers <- list()
i <- 1
# Get headers
for (file in files) {
  headers[[i]] <- scan(file, what = 'string', nlines = 1, sep = ',')
  i <- i + 1
}
names(headers) <- str_replace(files, tempdir, '')
# Summarise header field counts
field_counts <- sapply(headers, NROW)
field_counts <- tbl_df(data.frame(
  source = str_extract(names(field_counts), '(icus|igdl)'),
  date = ymd(str_extract(names(field_counts), '[[:digit:]]{8}')),
  count = unname(field_counts)))
# Visualise counts
field_counts %>% qplot(x = date, y = factor(count), data = .,
  colour = source, position=position_jitter(w=0.05, h=0.05)) + theme_minimal()
# Drill down to those with less than 8 fields:
field_counts %>% filter(count < 8)
# Look at the files with 9 fields prior to 2014
field_counts %>% filter(count == 9, year(date) < 2014)
headers[str_detect(names(headers), '(icus)*(20131029)+')]
headers[str_detect(names(headers), '(icus)*(20131216)+')]
# And then during 2014
headers[str_detect(names(headers), '(icus)*(20140731)+')]
