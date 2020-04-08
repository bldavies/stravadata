# STREAMS.R
#
# This script downloads activity stream data via the Strava API.
#
# Ben Davies
# April 2020


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
library(readr)

load('data/activities.rda')

cache_dir <- 'data-raw/streams/'
if (!dir.exists(cache_dir)) dir.create(cache_dir)

keys <- c(
  'altitude',
  'cadence',
  'distance',
  'grade_smooth',
  'heartrate',
  'latlng',
  'moving',
  'time',
  'velocity_smooth'
) %>%
  paste(collapse = ',')


# API requests and cache updates ----

source('data-raw/oauth-token.R')

missing_ids <- setdiff(
  activities$id,
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
      res[['lat']] <- sapply(req_content[[i]]$data, function(x) x[[1]])
      res[['lon']] <- sapply(req_content[[i]]$data, function(x) x[[2]])
    } else {
      res[[req_content[[i]]$type]] <- unlist(req_content[[i]]$data)
    }
  }
  res %>%
    as_tibble() %>%
    mutate_at(c('lat', 'lon'), function(x) sprintf('%.6f', x)) %>%
    write_csv(paste0(cache_dir, id, '.csv'))
}


# Data collation and export ----

cache_files <- list.files(cache_dir)
cache_list <- vector('list', length(cache_files))
for (i in seq_along(cache_files)) {
  suppressMessages(cache_list[[i]] <- read_csv(paste0(cache_dir, cache_files[i])))
  cache_list[[i]]$id <- as.numeric(sub('[.]csv$', '', cache_files[i]))
  cache_list[[i]]$index <- seq_len(nrow(cache_list[[i]]))
}

streams <- cache_list %>%
  bind_rows() %>%
  select(id, index, distance, time, moving, speed = velocity_smooth, lat, lon,
         altitude, grade = grade_smooth, hr = heartrate, cadence) %>%
  arrange(id, index)

save(streams, file = 'data/streams.rda', version = 2, compress = 'bzip2')


# Session info ----

bldr::save_session_info('data-raw/streams.log')
