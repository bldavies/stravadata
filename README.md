# stravadata

stravadata is an R package providing convenient access to my [Strava](https://www.strava.com/) activity data.

## Usage

The public version of this package does not include any activity data.
Users need to add their own.
The steps for doing so are as follows.

1. Clone or fork the repo.
2. Log in to Strava and create an API application on the [API settings](https://www.strava.com/settings/api) page.
  (I put "localhost" in the "Authorization Callback Domain" field.)
3. Create `credentials.yaml` in the repo's top-level directory, and include the API application's client ID and secret as follows:
  ```yaml
  client_id: xxxxx
  secret: xxxxx
  ```
4. Run `source("data-raw/activities.R")` in a fresh `stravadata.Rproj` instance.
  (This may take some time for users with many Strava activities or a slow internet connection.)
5. Install the package locally via `devtools::install()`.

Steps 4 and 5 can be replaced by running `make` in a Terminal window at the repo's top-level directory.

After completing these steps, the package and its data can be loaded via
```r
library(stravadata)
data(activities)
```

## License

MIT
