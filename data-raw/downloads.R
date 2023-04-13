# DOWNLOADS.R
#
# This script downloads Strava activity data from the Strava API.
#
# Ben Davies
# April 2023


# Initialization ----

# Load packages
library(dplyr)
library(httr)
library(jsonlite)
library(lubridate)
library(readr)
library(yaml)

# Initialize output directory
base_dir = 'data-raw/downloads'
if (!dir.exists(base_dir)) dir.create(base_dir)

# Set request delay
req_delay = ceiling(60 * 60 * 24 / 3e4)  # API rate limit is 30k requests per day

# Set stream keys
stream_keys <- c(
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


# Authentication ----

# Import credentials
credentials = read_yaml('credentials.yaml')

# Create OAuth token
token = oauth2.0_token(
  endpoint = oauth_endpoint(
    request = NULL,
    authorize = 'https://www.strava.com/oauth/authorize',
    access = 'https://www.strava.com/oauth/token'
  ),
  app = oauth_app('strava', credentials$client_id, credentials$secret),
  scope = 'activity:read_all',
  as_header = F
)


# API requests ----

# Get activity list
activities_list = list()
i = 1
done = F
while (!done) {
  
  # Send API request
  req = GET(
    url = 'https://www.strava.com/api/v3/athlete/activities',
    config = token,
    query = list(per_page = 200, page = i)
  )
  stop_for_status(req)
  
  # Append data
  activities_list[[i]] = fromJSON(content(req, as = 'text'), flatten = T)
  
  # Check stopping condition
  if (length(content(req)) < 200) {
    done = T
  } else {
    i = i + 1
  }
  
  # Wait
  Sys.sleep(req_delay)
}

# Determine missing IDs
missing_ids = setdiff(
  unlist(lapply(activities_list, \(x) x$id)),
  as.numeric(sub('.*/(.*)/details[.]json', '\\1', list.files(base_dir, 'details[.]json', recursive = T)))
)

# Iterate over missing IDs
for (id in missing_ids) {
  
  # Send API request for activity details
  details_req = GET(
    url = paste0('https://www.strava.com/api/v3/activities/', id),
    config = token,
    query = list(include_all_efforts = "TRUE")
  )
  stop_for_status(details_req)
  
  # Parse details
  details = fromJSON(content(details_req, as = 'text'))
  
  # Initialize output directory
  y = year(details$start_date)
  m = month(details$start_date)
  out_dir = sprintf('%s/%d/%02d/%s', base_dir, y, m, id)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = T)
  
  # Save details
  details_req %>%
    content(as = 'text') %>%
    prettify() %>%
    write_file(paste0(out_dir, '/details.json'))
  
  # Wait
  Sys.sleep(req_delay)
  
  # Send API request for activity streams
  streams_req = GET(
    url = paste0('https://www.strava.com/api/v3/activities/', id, '/streams/', stream_keys),
    config = token
  )
  stop_for_status(req)
  
  # Parse streams
  streams_req_content = content(streams_req)
  streams_list = list()
  for (i in seq_along(streams_req_content)) {
    if (streams_req_content[[i]]$type == 'latlng') {
      streams_list[['lat']] = sprintf('%.6f', sapply(streams_req_content[[i]]$data, \(x) x[[1]]))
      streams_list[['lon']] = sprintf('%.6f', sapply(streams_req_content[[i]]$data, \(x) x[[2]]))
    } else {
      streams_list[[streams_req_content[[i]]$type]] = unlist(streams_req_content[[i]]$data)
    }
  }
  
  # Save streams
  streams_list %>%
    as_tibble() %>%
    write_csv(paste0(out_dir, '/streams.csv'))
  
  # Wait
  Sys.sleep(req_delay)
  
}


# Session info ----

if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/downloads.log')
}
