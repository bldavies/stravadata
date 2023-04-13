# BEST-EFFORTS.R
#
# This script creates a table of activity best efforts.
#
# Ben Davies
# April 2023


if (length(dir('data-raw/downloads')) == 0) {
  stop('data-raw/downloads/ must not be empty.')
}

if (file_test('-ot', 'data/activities.rda', 'data/best-efforts.rda')) {
  stop('Data already up to date.')
}


# Initialization ----

library(dplyr)
library(jsonlite)
library(readr)


# Data extraction and export ----

cache_files = list.files('data-raw/downloads', 'details[.]json', full.names = T, recursive = T)

cache_list = lapply(cache_files, read_json)

best_efforts = cache_list %>%
  lapply(function(x) x$best_efforts) %>%
  unlist(recursive = F) %>%
  lapply(
    function(x) {
      tibble(
        id = x$activity$id,
        effort = x$name,
        start_index = x$start_index,
        end_index = x$end_index
      )
    }
  ) %>%
  bind_rows() %>%
  mutate_at(c('start_index', 'end_index'), function(x) as.integer(x + 1)) %>%
  arrange(id, effort)

write_csv(best_efforts, 'data-raw/best-efforts.csv')

save(best_efforts, file = 'data/best-efforts.rda', version = 2, compress = 'bzip2')


# Session info ----

if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/best-efforts.log')
}
