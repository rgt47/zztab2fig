#' Batch Processing for the Typst Backend
#'
#' @description Parallel to \code{t2f_batch()} / \code{t2f_batch_advanced()}
#'   / \code{t2f_batch_spec()}: render many tables in one call,
#'   routing through \code{zzt2f()} rather than \code{t2f()}.
#'
#' @name zzt2f-batch
NULL

#' Batch-render tables with the Typst backend
#'
#' @param data_list A (named) list of data frames.
#' @param sub_dir Output directory.
#' @param theme Theme name or object.
#' @param parallel Logical. Use \code{future.apply} if available.
#' @param verbose Logical.
#' @param ... Passed to \code{zzt2f()}.
#' @return Named list of output file paths (invisible).
#' @examples
#' \dontrun{
#' zzt2f_batch(list(a = mtcars[1:5, 1:3], b = iris[1:5, 1:3]))
#' }
#' @export
zzt2f_batch <- function(data_list,
                        sub_dir = get_default_figures_dir(),
                        theme = NULL,
                        parallel = FALSE,
                        verbose = FALSE,
                        ...) {
  if (!is.list(data_list)) {
    stop("`data_list` must be a list.", call. = FALSE)
  }
  if (length(data_list) == 0L) {
    stop("`data_list` must not be empty.", call. = FALSE)
  }
  if (is.null(names(data_list))) {
    names(data_list) <- paste0("table_", seq_along(data_list))
  }
  is_df <- vapply(data_list, is.data.frame, logical(1L))
  if (!all(is_df)) {
    stop(
      "All elements must be data frames. Non-data frames: ",
      paste(names(data_list)[!is_df], collapse = ", "),
      call. = FALSE
    )
  }

  extra_args <- list(...)
  process_one <- function(name) {
    if (verbose) message("Processing: ", name)
    args <- c(
      list(
        x = data_list[[name]],
        filename = name,
        sub_dir = sub_dir,
        theme = theme,
        verbose = FALSE
      ),
      extra_args
    )
    tryCatch(
      do.call(zzt2f, args),
      error = function(e) {
        warning("Failed to process '", name, "': ", e$message)
        NA_character_
      }
    )
  }

  results <- if (isTRUE(parallel) &&
                 requireNamespace("future.apply", quietly = TRUE)) {
    if (verbose) {
      message("Processing ", length(data_list),
              " tables in parallel...")
    }
    future.apply::future_lapply(names(data_list), process_one)
  } else {
    if (isTRUE(parallel)) {
      message(
        "Parallel requested but 'future.apply' not installed; ",
        "running sequentially."
      )
    }
    lapply(names(data_list), process_one)
  }
  names(results) <- names(data_list)
  invisible(results)
}

#' Spec constructor for zzt2f advanced batch processing
#'
#' @param df A data frame.
#' @param filename Base filename (no extension).
#' @param ... Per-table overrides passed to \code{zzt2f()}.
#' @return A \code{zzt2f_batch_spec} object.
#' @examples
#' \dontrun{
#' specs <- list(
#'   zzt2f_batch_spec(mtcars, "mt", caption = "MT"),
#'   zzt2f_batch_spec(iris,   "ir", theme = "nejm")
#' )
#' zzt2f_batch_advanced(specs)
#' }
#' @export
zzt2f_batch_spec <- function(df, filename, ...) {
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame.", call. = FALSE)
  }
  if (!is.character(filename) || length(filename) != 1L) {
    stop(
      "`filename` must be a single character string.",
      call. = FALSE
    )
  }
  structure(
    list(df = df, filename = filename, args = list(...)),
    class = "zzt2f_batch_spec"
  )
}

#' Advanced batch rendering with per-table overrides
#'
#' @param specs A list of \code{zzt2f_batch_spec} objects.
#' @param sub_dir Default output directory.
#' @param theme Default theme.
#' @param parallel Logical.
#' @param verbose Logical.
#' @param ... Default arguments passed to each \code{zzt2f()} call.
#' @return Named list of output file paths.
#' @export
zzt2f_batch_advanced <- function(specs,
                                 sub_dir = get_default_figures_dir(),
                                 theme = NULL,
                                 parallel = FALSE,
                                 verbose = FALSE,
                                 ...) {
  if (!is.list(specs)) {
    stop("`specs` must be a list.", call. = FALSE)
  }
  is_spec <- vapply(specs, inherits, logical(1L), "zzt2f_batch_spec")
  if (!all(is_spec)) {
    stop(
      "All elements must be zzt2f_batch_spec objects.",
      call. = FALSE
    )
  }

  default_args <- c(
    list(sub_dir = sub_dir, theme = theme),
    list(...)
  )

  process_one <- function(spec) {
    if (verbose) message("Processing: ", spec$filename)
    args <- default_args
    args$x <- spec$df
    args$filename <- spec$filename
    args$verbose <- FALSE
    for (nm in names(spec$args)) args[[nm]] <- spec$args[[nm]]
    tryCatch(
      do.call(zzt2f, args),
      error = function(e) {
        warning(
          "Failed to process '", spec$filename, "': ", e$message
        )
        NA_character_
      }
    )
  }

  results <- if (isTRUE(parallel) &&
                 requireNamespace("future.apply", quietly = TRUE)) {
    future.apply::future_lapply(specs, process_one)
  } else {
    lapply(specs, process_one)
  }
  names(results) <- vapply(specs, `[[`, character(1L), "filename")
  invisible(results)
}

#' Print method for zzt2f_batch_spec
#' @param x A \code{zzt2f_batch_spec} object.
#' @param ... Ignored.
#' @return Invisibly \code{x}.
#' @export
print.zzt2f_batch_spec <- function(x, ...) {
  cat("zzt2f batch spec:\n")
  cat("  filename: ", x$filename, "\n", sep = "")
  cat("  df dims:  ",
      paste(dim(x$df), collapse = " x "), "\n", sep = "")
  if (length(x$args) > 0L) {
    cat("  overrides: ",
        paste(names(x$args), collapse = ", "), "\n", sep = "")
  }
  invisible(x)
}
