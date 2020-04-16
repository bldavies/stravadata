all: data package

data: activities best-efforts streams

activities:
	Rscript data-raw/activities.R

best-efforts:
	Rscript data-raw/best-efforts.R

streams:
	Rscript data-raw/streams.R

package:
	Rscript -e 'devtools::install()'
