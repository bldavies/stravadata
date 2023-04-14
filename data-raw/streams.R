# STREAMS.R
#
# This script creates a table of disaggregate activity streams.
#
# Ben Davies
# April 2023


if (!file.exists('data/activities.rda')) {
  stop('data/activities.rda does not exist')
}


# Initialization ----

library(dplyr)
library(purrr)
library(readr)
library(tidyr)
library(usethis)
library(vroom)

# Set input directory
base_dir = 'data-raw/downloads'

# Import activities
load('data/activities.rda')

# Define function for extracting activity ID from stream file path
get_id = function(x) as.numeric(sub('.*/(.*)/streams[.]csv', '\\1', x))


# Caching ----

# Determine included activity IDs
included_ids = activities %>%
  filter(type %in% c('Run', 'Ride'), !commute, !private) %>%
  pull(id)

# Initialize cache directory
cache_dir = 'data-raw/streams'
if (!dir.exists(cache_dir)) dir.create(cache_dir)

# Iterate over years
year_dirs = list.dirs(base_dir, recursive = F)
for (year_dir in year_dirs) {
  
  # Iterate over months
  month_dirs = list.dirs(year_dir, recursive = F)
  for (month_dir in month_dirs) {
    
    # Initialize cache file
    cache_file = sub(paste0(base_dir, '/(.*)/(.*)'), paste0(cache_dir, '/\\1-\\2.csv'), month_dir)
    
    # List stream files for included activities
    stream_files = list.files(month_dir, 'streams[.]csv', full.names = T, recursive = T)
    stream_files_included = stream_files[get_id(stream_files) %in% included_ids]
    
    # Create/update cache
    if (!file.exists(cache_file) | file.mtime(cache_file) < max(file.mtime(stream_files_included))) {
      
      tibble(file = stream_files_included) %>%
        mutate(id = get_id(file)) %>%
        mutate(res = map(file, vroom, show_col_types = F)) %>%
        unnest('res') %>%
        select(-file) %>%
        write_csv(cache_file)
      
    }
  }
}


# Collation ----

# Initialize output file
out_file = 'data-raw/streams.txt'

# List files
cache_files = list.files(cache_dir, '[.]csv', full.names = T)

# Create/update table
if (!file.exists(out_file) | file.mtime(out_file) < max(file.mtime(cache_files))) {
  
  # Build table
  streams = cache_files %>%
    lapply(read_csv, show_col_types = F) %>%
    bind_rows() %>%
    select(id, distance, time, moving, lat, lon, altitude, hr = heartrate) %>%
    arrange(id, time)
  
  # Export table
  use_data(streams, overwrite = T)
  
  # Save output file
  write_file(paste('Updated', Sys.time()), out_file)
  
}


# Session info ----

if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/streams.log')
}
