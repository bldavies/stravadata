# BEST-EFFORTS.R
#
# This script creates a table of activity best efforts.
#
# Ben Davies
# June 2023


# Initialization ----

# Load packages
library(dplyr)
library(jsonlite)
library(readr)
library(usethis)

# Set input directory
base_dir = 'data-raw/downloads'


# Caching ----

# Initialize cache directory
cache_dir = 'data-raw/best-efforts'
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
        lapply(function(x) x$best_efforts) %>%
        unlist(recursive = F) %>%
        lapply(
          function(x) {
            tibble(
              id = x$activity$id,
              effort = x$name,
              start_index = x$start_index,
              end_index = x$end_index
            ) %>%
              mutate_at(., c('start_index', 'end_index'), function(x) as.integer(x + 1))
          }
        ) %>%
        bind_rows() %>%
        write_csv(cache_file)
      
    }
  }
}


# Collation ----

# Initialize output file
out_file = 'data-raw/best-efforts.csv'

# List files
cache_files = list.files(cache_dir, '[.]csv', full.names = T)

# Create/update table
if (!file.exists(out_file) | file.mtime(out_file) < max(file.mtime(cache_files))) {
  
  # Build table
  best_efforts = cache_files %>%
    lapply(read_csv, show_col_types = F) %>%
    bind_rows() %>%
    arrange(id, effort)
  
  # Export table
  write_csv(best_efforts, out_file)
  use_data(best_efforts, overwrite = T)
  
}


# Session info ----

if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/best-efforts.log')
}
