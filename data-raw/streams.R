# STREAMS.R
#
# This script downloads activity stream data via the Strava API.
#
# Ben Davies
# November 2021


if (!file.exists('data/activities.rda')) {
  stop('data/activities.rda must exist.')
}

if (file_test('-ot', 'data/activities.rda', 'data/streams.rda')) {
  stop('Data already up to date.')
}


# Initialisation ----

library(dplyr)
library(httr)
library(jsonlite)
library(purrr)
library(readr)
library(vroom)

load('data/activities.rda')

cache_dir <- 'data-raw/streams/'
if (!dir.exists(cache_dir)) dir.create(cache_dir)

req_delay <- ceiling(60 * 60 * 24 / 3e4)  # API rate limit is 30k requests per day

keys <- c(
  'altitude',
  'cadence',
  'distance',
  'grade_smooth',
  'heartrate',
  'latlng',
  'moving',
  'temp',
  'time',
  'velocity_smooth'
) %>%
  paste(collapse = ',')


# API requests and cache updates ----

source('data-raw/oauth-token.R')

types <- c('Run', 'Ride')
missing_ids <- setdiff(
  filter(activities, type %in% types)$id,
  as.numeric(sub('[.]csv$', '', list.files(cache_dir)))
)

for (id in missing_ids) {
  req <- GET(
    url = paste0('https://www.strava.com/api/v3/activities/', id, '/streams/', keys),
    config = token
  )
  stop_for_status(req)
  req_content <- content(req)
  res <- list()
  for (i in seq_along(req_content)) {
    if (req_content[[i]]$type == 'latlng') {
      res[['lat']] <- sprintf('%.6f', sapply(req_content[[i]]$data, function(x) x[[1]]))
      res[['lon']] <- sprintf('%.6f', sapply(req_content[[i]]$data, function(x) x[[2]]))
    } else {
      res[[req_content[[i]]$type]] <- unlist(req_content[[i]]$data)
    }
  }
  res %>%
    as_tibble() %>%
    write_csv(paste0(cache_dir, id, '.csv'))
  Sys.sleep(req_delay)
}


# Data collation and export ----

cache_files <- list.files(cache_dir, full.names = T)

streams <- map_df(cache_files, vroom, id = 'path', show_col_types = F) %>%
  mutate(id = as.numeric(sub('.*/([0-9]+)[.]csv$', '\\1', path))) %>%
  select(id, distance, time, moving, speed = velocity_smooth, lat, lon,
         altitude, grade = grade_smooth, hr = heartrate, cadence) %>%
  arrange(id, time)

save(streams, file = 'data/streams.rda', version = 2, compress = 'bzip2')


# Session info ----

if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/streams.log')
}
