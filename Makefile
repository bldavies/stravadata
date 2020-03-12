all: activities package

activities:
	Rscript data-raw/activities.R

package:
	Rscript -e 'devtools::install()'
