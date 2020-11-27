#' Strava activity features
#' 
#' Data frame containing Strava activity features.
#' 
#' @name activities
#' 
#' @docType data
#' 
#' @usage data(activities)
#' 
#' @format Data frame with columns
#' \describe{
#' \item{id}{Activity ID}
#' \item{name}{Activity name}
#' \item{type}{Activity type}
#' \item{workout_type}{Workout type}
#' \item{start_time}{Start time (YYYY-MM-DD HH:MM:SS)}
#' \item{timezone}{Time zone}
#' \item{distance}{Total distance travelled (metres)}
#' \item{time_moving}{Total time spent moving (seconds)}
#' \item{time_total}{Total duration (seconds)}
#' \item{elev_gain}{Total elevation gain (metres)}
#' \item{mean_hr}{Mean heart rate (beats per minute)}
#' \item{max_hr}{Maximum heart rate (beats per minute)}
#' \item{mean_cadence}{Mean cadence (steps per minute)}
#' \item{mean_temp}{Mean temperature (degrees celsius)}
#' \item{n_athletes}{Number of athletes}
#' \item{exertion}{Perceived exertion on 1--10 scale}
#' \item{suffer_score}{Suffer score}
#' }
#' 
#' @source \href{https://developers.strava.com}{Strava API}
"activities"
