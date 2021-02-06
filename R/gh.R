# gh.R
# Vectorised wrapper functions for the GitHub API

#' Query the GitHub API and return a table
#'
#' @description
#' Vectorised wrapper for [gh::gh()] that:
#'
#' * Converts the response to a data frame
#' * Empty responses are returned as an `NA` row.
#' * Silently skips queries where any value of `...` is `NA`, returning an `NA`
#'   row.
#' * Catches API error statuses (e.g. 404), returning an `NA` row and a printed
#'   message instead of an error.
#'
#' @param endpoint GitHub API endpoint.
#' @param ... Other arguments to [gh::gh()], including name-value pairs of any
#'  API parameters in `endpoint`.
#'
#' @return
#' A data frame with one row per query, and one column per response vector.
#'
#' @export
#'
#' @examples
#' ght("GET /repos/{owner}/{repo}/languages",
#'     owner = c("joeroe", "joeroe"), repo = c("era", "c14"))
ght <- function(endpoint, ...) {
  df <- pmap_dfr(data.frame(...), function(endpoint, ...) {
    if (any(is.na(list(...)))) data.frame(`NA` = NA)
    else {
      res <- tryCatch(
        gh(endpoint, ...),
        http_error_404 = function(c) {
          print(c)
          data.frame(`NA` = NA)
        }
      )
      if (length(res) > 0) res
      else data.frame(`NA` = NA)
    }
  }, endpoint = endpoint)

  if ("NA" %in% names(df)) return(select(df, -`NA`))
  else return(df)
}
