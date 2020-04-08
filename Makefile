all: activities streams package

activities:
	Rscript data-raw/activities.R

streams:
	Rscript data-raw/streams.R

package:
	Rscript -e 'devtools::install()'
