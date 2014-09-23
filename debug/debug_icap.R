# Debug ICAP headers
require (stringr)
require (lubridate)
require (dplyr)
require (ggplot2)
require (stringr)
# Get ICAP data
get_icap_data(ymd(20140731))
# Find ICAP files in temp directory
tempdir <- tempdir()
files <- list.files(file.path(tempdir, c('icus', 'igdl')), full.names = TRUE)
sef_labels <- unlist(str_extract(files, '((igdl)|(icus))'))
date_labels <- unlist(str_extract(files, '[[:digit:]]{8}'))
file_labels <- paste0(sef, date)
headers <- list()
i <- 1
# Get headers
for (file in files) {
  headers[[i]] <- scan(file, what = 'string', nlines = 1, sep = ',')
  i <- i + 1
}
names(headers) <- file_labels
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


regexps <- c('date|Date|DATE', # date
  'asset|Asset|ASSET', # assetclass
  'inst|Inst|INST', # security
  '((t|T)(rade|RADE))+(\\s)*(V(ol|OL)(ume|UME)*)\\s*(?!\\(*USD\\)*)', # totalvolume
  '((t|T)(rade|RADE))+(\\s)*(V(ol|OL)(ume|UME)*)\\s*\\(*USD\\)*', #totalvolumeusd
  'OPEN|Open|open', #priceopen
  'CLOSE|Close|close', #priceclose
  'LOW|Low|low', #pricelow
  'HIGH|High|high' #pricehigh
  )
for (regexp in regexps)
{
  i <- 0
  for (header in headers)
  {
    flag <- any(str_detect(header, perl(regexp)))
#     if (!flag) print(header)
    i <- i + flag
  }
  print(paste0(regexp, ': ', i, ' of ', NROW(headers)))
}

