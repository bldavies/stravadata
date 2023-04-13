# ACTIVITIES.R
#
# This script creates a table of aggregate activity features.
#
# Ben Davies
# April 2023


# Initialization ----

library(dplyr)
library(lubridate)
library(jsonlite)
library(readr)


# Data import ----

cache_files = list.files('data-raw/downloads', 'details[.]json', full.names = T, recursive = T)

cache_list = lapply(cache_files, read_json)


# Data export ----

null2na = function(x) ifelse(!is.null(x), x, NA)

activities = cache_list %>%
  lapply(
    function(x) {
      tibble(
        id           = x$id,
        name         = x$name,
        type         = x$type,
        workout_type = null2na(x$workout_type),
        indoor       = x$trainer,
        commute      = x$commute,
        private      = x$private,
        start_time   = as_datetime(x$start_date_local),
        timezone     = x$timezone,
        distance     = x$distance,
        time_moving  = x$moving_time,
        time_total   = x$elapsed_time,
        elev_gain    = x$total_elevation_gain,
        mean_hr      = null2na(x$average_heartrate),
        mean_cadence = null2na(x$average_cadence),
        mean_temp    = null2na(x$average_temp),
        exertion     = null2na(x$perceived_exertion),
        suffer_score = null2na(x$suffer_score)
      )
    }
  ) %>%
  bind_rows() %>%
  mutate(workout_type = replace(workout_type, workout_type %in% c(0, 10), NA)) %>%
  arrange(id)

write_csv(activities, 'data-raw/activities.csv')

if (!dir.exists('data')) dir.create('data/')
save(activities, file = 'data/activities.rda', version = 2, compress = 'bzip2')


# Session info ----

if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/activities.log')
}
