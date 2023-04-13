all: data package

data: downloads activities best-efforts streams

downloads:
	Rscript data-raw/downloads.R

activities:
	Rscript data-raw/activities.R

best-efforts:
	Rscript data-raw/best-efforts.R

streams:
	Rscript data-raw/streams.R

package:
	Rscript -e 'devtools::install()'
