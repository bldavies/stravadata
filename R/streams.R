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
#' \item{distance}{Cumulative distance (metres)}
#' \item{time}{Cumulative time (seconds)}
#' \item{moving}{Whether moving}
#' \item{lat}{Latitude coordinate}
#' \item{lon}{Longitude coordinate}
#' \item{altitude}{Altitude (metres)}
#' \item{hr}{Heart rate (beats per minute)}
#' }
#' 
#' @source \href{https://developers.strava.com}{Strava API}
"streams"
