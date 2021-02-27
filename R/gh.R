# gh.R
# Functions for accessing the GitHub API

#' GitHub repository queries
#'
#' Get the languages, contributors, issues, comments, or commits of a single
#' repository from the GitHub API.
#'
#' @param repo Name of the repository, in the form `"owner/repository"`.
#'
#' @return
#' A `tibble` containing the tabulated API responses, or `NA` if the response
#' was empty or unsuccessful.
#'
#' @details
#' Queries use [ghq()], a thin wrapper for [gh::gh()] that ensures the query
#' always returns a value.
#'
#' @name gh_query
#'
#' @examples
#' gh_lang("joeroe/era")
#' gh_contrib("joeroe/era")
#' gh_issue("joeroe/era")
#' gh_comment("joeroe/era")
#' gh_commit("joeroe/era")
NULL

#' @rdname gh_query
#' @export
gh_lang <- function(repo) {
  data <- tibble::tibble(
    repo = repo,
    response = ghq("GET /repos/{repo}/languages", repo = repo)
  )

  if (not_all_na(data$response)) {
    data <- dplyr::mutate(data, lang = names(response))
    data <- tidyr::unnest(data, response)
    data <- dplyr::select(data, repo, lang, bytes = response)
    data <- dplyr::select(data, where(not_all_na))
    data
  }
  else NA
}

#' @rdname gh_query
#' @export
gh_contrib <- function(repo) {
  data <- tibble::tibble(
    repo = repo,
    response = ghq("GET /repos/{repo}/contributors", repo = repo)
  )

  if (not_all_na(data$response)) {
    data <- tidyr::hoist(data, response,
                         contributor = "login",
                         contributions = "contributions")
    data <- dplyr::select(data, -response)
    data
  }
  else NA
}

#' @rdname gh_query
#' @export
gh_issue <- function(repo) {
  data <- tibble::tibble(
    repo = repo,
    response = ghq("GET /repos/{repo}/issues", repo = repo)
  )

  if (not_all_na(data$response)) {
    data <- tidyr::hoist(data, response,
                         num = "number",
                         "title",
                         author = c("user", "login"),
                         "labels",
                         "state",
                         "comments",
                         "created_at",
                         "updated_at",
                         "closed_at",
                         "body")
    data <- dplyr::select(data, -response)
    data <- dplyr::mutate(data,
      created_at = lubridate::as_datetime(created_at),
      updated_at = lubridate::as_datetime(updated_at),
      closed_at = lubridate::as_datetime(closed_at),
    )
    data
  }
  else NA
}

#' @rdname gh_query
#' @export
gh_comment <- function(repo) {
  data <- tibble::tibble(
    repo = repo,
    response = ghq("GET /repos/{repo}/issues/comments", repo = repo)
  )

  if (not_all_na(data$response)) {
    data <- tidyr::hoist(data, response,
                         issue_num = "issue_url",
                         author = c("user", "login"),
                         "created_at",
                         "updated_at",
                         "body")
    data <- dplyr::select(data, -response)
    data <- dplyr::mutate(data,
                          issue_num = stringr::str_match(data$issue_num,
                                                         "\\/(\\d*)$")[,2],
                          created_at = lubridate::as_datetime(created_at),
                          updated_at = lubridate::as_datetime(updated_at))
    data
  }
  else NA
}

#' @rdname gh_query
#' @export
gh_commit <- function(repo) {
  data <- tibble::tibble(
    repo = repo,
    response = ghq("GET /repos/{repo}/commits", repo = repo)
  )

  if (not_all_na(data$response)) {
    data <- tidyr::hoist(data, response,
                         "sha",
                         author = c("author", "login"),
                         datetime = c("commit", "author", "date"))
    data <- dplyr::select(data, -response)
    data <- dplyr::mutate(data,
                          datetime = lubridate::as_datetime(datetime))
    data
  }
  else NA
}

not_all_na <- function(x) any(!is.na(x))

#' Query the GitHub API
#'
#' Thin wrapper for [gh::gh()] that returns an NA if the response is empty or
#' if returns a 404 error (with a warning).
#'
#' @param endpoint GitHub API endpoint.
#' @param ... Other arguments to [gh::gh()], including name-value pairs of any
#'  API parameters in `endpoint`.
#'
#' @details
#' Queries where any value of `...` is `NA` will also return an `NA` row.
#'
#' @export
#'
#' @examples
#' ghq("GET /repos/{repo}/languages", repo = "joeroe/c14")
#' ghq("GET /repos/{repo}/languages", repo = "nonexistent/repo")
ghq <- function(endpoint, ...) {
  if (any(is.na(list(...)))) NA
  else {
    res <- tryCatch(
      gh(endpoint, ..., .limit = Inf),
      http_error_404 = gh_warn_404
    )
    if (length(res) > 0) res
    else NA
  }
}

gh_warn_404 <- function(c) {
  w <- stringr::str_extract(as.character(c), "URL not found:.*$")
  rlang::warn(paste0("GitHub API ", w), class = "http_error_404")
  return(NA)
}
