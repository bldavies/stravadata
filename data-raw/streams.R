# STREAMS.R
#
# This script creates a table of disaggregate activity streams.
#
# Ben Davies
# April 2023


if (!file.exists('data/activities.rda')) {
  stop('data/activities.rda must exist.')
}

if (file_test('-ot', 'data/activities.rda', 'data/streams.rda')) {
  stop('Data already up to date.')
}


# Initialization ----

library(dplyr)
library(purrr)
library(readr)
library(tidyr)
library(vroom)

load('data/activities.rda')

focal_types = c('Run', 'Ride')


# Data collation and export ----

cache_files = list.files('data-raw/downloads', 'streams[.]csv', full.names = T, recursive = T)

if (file.exists('data/streams.rda')) {
  load('data/streams.rda')
} else {
  streams = tibble()
}

missing_ids = activities %>%
  filter(type %in% focal_types, !indoor, !private) %>%
  anti_join(streams, by = 'id') %>%
  pull(id)

streams_new_ids = base::intersect(
  missing_ids,
  as.numeric(sub('.*/(.*)/streams[.]csv$', '\\1', cache_files))
)

streams_new = tibble(path = cache_files) %>%
  mutate(id = as.numeric(sub('.*/(.*)/streams[.]csv$', '\\1', path))) %>%
  filter(id %in% streams_new_ids) %>%
  mutate(res = map(path, vroom, show_col_types = F)) %>%
  unnest('res') %>%
  rename_with(recode, heartrate = 'hr')

streams = streams %>%
  filter(!id %in% streams_new_ids) %>%
  bind_rows(streams_new) %>%
  select(id, distance, time, moving, lat, lon, altitude, hr) %>%
  arrange(id, time)

save(streams, file = 'data/streams.rda', version = 2, compress = 'bzip2')


# Session info ----

if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/streams.log')
}
