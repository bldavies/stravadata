# ACTIVITIES.R
#
# This script creates a table of aggregate activity features.
#
# Ben Davies
# April 2023


# Initialization ----

# Load packages
library(dplyr)
library(lubridate)
library(jsonlite)
library(readr)
library(usethis)

# Set input directory
base_dir = 'data-raw/downloads'

# Define function for converting NULLs to NAs
null2na = function(x) ifelse(!is.null(x), x, NA)


# Caching ----

# Initialize cache directory
cache_dir = 'data-raw/activities'
if (!dir.exists(cache_dir)) dir.create(cache_dir)

# Iterate over years
year_dirs = list.dirs(base_dir, recursive = F)
for (year_dir in year_dirs) {
  
  # Iterate over months
  month_dirs = list.dirs(year_dir, recursive = F)
  for (month_dir in month_dirs) {
    
    # Initialize cache file
    cache_file = sub(paste0(base_dir, '/(.*)/(.*)'), paste0(cache_dir, '/\\1-\\2.csv'), month_dir)
    
    # List detail files
    detail_files = list.files(month_dir, 'details[.]json', full.names = T, recursive = T)
    
    # Create/update cache
    if (!file.exists(cache_file) | file.mtime(cache_file) < max(file.mtime(detail_files))) {
      
      detail_files %>%
        lapply(read_json) %>%
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
        write_csv(cache_file)
      
    }
  }
}


# Collation ----

# Initialize output file
out_file = 'data-raw/activities.csv'

# List files
cache_files = list.files(cache_dir, '[.]csv', full.names = T)

# Create/update table
if (!file.exists(out_file) | file.mtime(out_file) < max(file.mtime(cache_files))) {
  
  # Build table
  activities = cache_files %>%
    lapply(read_csv, show_col_types = F) %>%
    bind_rows() %>%
    mutate(workout_type = replace(workout_type, workout_type %in% c(0, 10), NA)) %>%
    arrange(id)
  
  # Export table
  write_csv(activities, out_file)
  use_data(activities, overwrite = T)
  
}


# Session info ----

if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/activities.log')
}
