all: data package

data: activities streams

activities:
	Rscript data-raw/activities.R

streams:
	Rscript data-raw/streams.R

package:
	Rscript -e 'devtools::install()'
