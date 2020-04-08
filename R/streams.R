#' Strava activity streams
#' 
#' Data frame containing Strava activity streams.
#' 
#' @name streams
#' 
#' @docType data
#' 
#' @usage data(streams)
#' 
#' @format Data frame with columns
#' \describe{
#' \item{id}{Activity ID}
#' \item{index}{Index}
#' \item{distance}{Cumulative distance (metres)}
#' \item{time}{Cumulative time (seconds)}
#' \item{moving}{Whether moving}
#' \item{speed}{Smoothed speed (metres per second)}
#' \item{lat}{Latitude coordinate}
#' \item{lon}{Longitude coordinate}
#' \item{altitude}{Altitude (metres)}
#' \item{grade}{Smoothed gradient (percent)}
#' \item{hr}{Heart rate (beats per minute)}
#' \item{cadence}{Cadence (rotations per minute)}
#' }
#' 
#' @source \href{https://developers.strava.com}{Strava API}
"streams"
