# BEST-EFFORTS.R
#
# This script extracts data on activity best efforts.
#
# Ben Davies
# November 2021


if (length(dir('data-raw/activities')) == 0) {
  stop('data-raw/activities/ must not be empty.')
}

if (file_test('-ot', 'data/activities.rda', 'data/best-efforts.rda')) {
  stop('Data already up to date.')
}


# Initialisation ----

library(dplyr)
library(jsonlite)
library(readr)


# Data extraction and export ----

cache_list <- lapply(dir('data-raw/activities/', full.names = T), read_json)

best_efforts <- cache_list %>%
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
