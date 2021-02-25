# gh.R
# Vectorised wrapper functions for the GitHub API

#' Query the GitHub API (tabulated)
#'
#' [dplyr::mutate()]-friendly wrapper for [gh::gh()] that tabulates the response
#' and always returns a vector that matches the number of queries.
#' Vectorised over the named API parameters in `...`.
#'
#' @param endpoint GitHub API endpoint.
#' @param ... Other arguments to [gh::gh()], including name-value pairs of any
#'  API parameters in `endpoint`.
#'
#' @details
#' Empty responses return an `NA` row, with a warning if the request produced
#' a 404 error. Queries where any value of `...` is `NA` will also return an
#' `NA` row.
#'
#' @return
#' If each response returns a single row, a `tibble` with one row per query
#' (producing a packed column if used in `mutate()`). Otherwise, a list of
#' `tibbles` for each query (producing a nested column if used in `mutate()`).
#'
#' @export
#'
#' @examples
#' ght("GET /repos/{owner}/{repo}/languages", owner = c("joeroe", "joeroe"), repo = c("era", "c14"))
ght <- function(endpoint, ...) {
  responses <- purrr::pmap(data.frame(...), function(endpoint, ...) {
    if (any(is.na(list(...)))) data.frame(`NA` = NA)
    else {
      res <- tryCatch(
        gh(endpoint, ...),
        http_error_404 = gh_warn_404
      )
      if (length(res) > 0) dplyr::bind_rows(res)
      else data.frame(`NA` = NA)
    }
  }, endpoint = endpoint)

  if (all(sapply(responses, nrow) == 1)) {
    responses <- dplyr::bind_rows(responses)
    if ("NA" %in% names(df)) responses <- dplyr::select(responses, -`NA`)
  }

  return(responses)
}

gh_warn_404 <- function(c) {
  w <- stringr::str_extract(as.character(c), "URL not found:.*$")
  rlang::warn(paste0("GitHub API ", w), class = "http_error_404")
  return(list())
}
