# OAUTH-TOKEN.R
#
# This script creates an OAuth token for sending requests to the Strava API.
#
# Ben Davies
# February 2020

library(httr)
library(yaml)

credentials <- read_yaml('credentials.yaml')

token <- oauth2.0_token(
  endpoint = oauth_endpoint(
    request = NULL,
    authorize = 'https://www.strava.com/oauth/authorize',
    access = 'https://www.strava.com/oauth/token'
  ),
  app = oauth_app('strava', credentials$client_id, credentials$secret),
  scope = 'activity:read_all',
  as_header = F
)
