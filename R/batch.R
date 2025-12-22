#' Batch Processing API
#'
#' @description Functions for processing multiple tables with consistent
#'   styling and optional parallel execution.
#'
#' @name batch
NULL

#' Process multiple tables in batch
#'
#' @description Generate multiple LaTeX tables with consistent styling in a
#'   single operation. Tables can be processed sequentially or in parallel.
#'
#' @param data_list A named list of data frames to process.
#' @param sub_dir Output directory for all tables. Defaults to "output".
#' @param theme Theme name or t2f_theme object to apply to all tables.
#' @param parallel Logical. Use parallel processing if available.
#' @param verbose Logical. Print progress messages.
#' @param ... Additional arguments passed to all t2f() calls.
#'
#' @return A named list of output file paths.
#'
#' @examples
#' \dontrun{
#' tables <- list(
#'   mtcars_summary = head(mtcars),
#'   iris_summary = head(iris),
#'   airquality_summary = head(airquality)
#' )
#'
#' results <- t2f_batch(tables, theme = "nejm")
#' }
#'
#' @export
t2f_batch <- function(data_list,
                      sub_dir = "output",
                      theme = NULL,
                      parallel = FALSE,
                      verbose = FALSE,
                      ...) {
  # Validate input
  if (!is.list(data_list)) {
    stop("`data_list` must be a list.", call. = FALSE)
  }

  if (length(data_list) == 0) {
    stop("`data_list` must not be empty.", call. = FALSE)
  }

  # Ensure list is named
  if (is.null(names(data_list))) {
    names(data_list) <- paste0("table_", seq_along(data_list))
  }

  # Check that all elements are data frames
  is_df <- sapply(data_list, is.data.frame)
  if (!all(is_df)) {
    bad_names <- names(data_list)[!is_df]
    stop("All elements must be data frames. Non-data frames: ",
      paste(bad_names, collapse = ", "),
      call. = FALSE
    )
  }

  # Capture additional arguments
  extra_args <- list(...)

  # Define processing function
  process_one <- function(name) {
    if (verbose) {
      message("Processing: ", name)
    }

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
      do.call(t2f, args),
      error = function(e) {
        warning("Failed to process '", name, "': ", e$message)
        NA_character_
      }
    )
  }

  # Process tables
  if (parallel && requireNamespace("future.apply", quietly = TRUE)) {
    if (verbose) {
      message("Processing ", length(data_list), " tables in parallel...")
    }
    results <- future.apply::future_lapply(names(data_list), process_one)
  } else {
    if (parallel) {
      message("Parallel processing requested but 'future.apply' not available.",
        " Processing sequentially."
      )
    }
    if (verbose) {
      message("Processing ", length(data_list), " tables sequentially...")
    }
    results <- lapply(names(data_list), process_one)
  }

  names(results) <- names(data_list)

  # Report summary
  successful <- !is.na(unlist(results))
  if (verbose) {
    message(
      "Completed: ", sum(successful), "/", length(results),
      " tables processed successfully."
    )
  }

  invisible(results)
}

#' Create a batch specification
#'
#' @description Create a specification object for batch processing with
#'   per-table overrides.
#'
#' @param df Data frame for this table.
#' @param filename Output filename.
#' @param ... Additional arguments specific to this table (override batch
#'   defaults).
#'
#' @return A t2f_batch_spec object.
#'
#' @examples
#' \dontrun{
#' specs <- list(
#'   t2f_batch_spec(mtcars, "mtcars_table", caption = "Motor Trend Data"),
#'   t2f_batch_spec(iris, "iris_table", caption = "Iris Data", theme = "apa")
#' )
#' t2f_batch_advanced(specs)
#' }
#'
#' @export
t2f_batch_spec <- function(df, filename, ...) {
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame.", call. = FALSE)
  }

  if (!is.character(filename) || length(filename) != 1) {
    stop("`filename` must be a single character string.", call. = FALSE)
  }

  structure(
    list(
      df = df,
      filename = filename,
      args = list(...)
    ),
    class = "t2f_batch_spec"
  )
}

#' Advanced batch processing with per-table options
#'
#' @description Process multiple tables where each table can have different
#'   settings.
#'
#' @param specs A list of t2f_batch_spec objects.
#' @param sub_dir Default output directory.
#' @param theme Default theme (can be overridden per table).
#' @param parallel Use parallel processing.
#' @param verbose Print progress messages.
#' @param ... Default arguments passed to all t2f() calls.
#'
#' @return A named list of output file paths.
#'
#' @export
t2f_batch_advanced <- function(specs,
                               sub_dir = "output",
                               theme = NULL,
                               parallel = FALSE,
                               verbose = FALSE,
                               ...) {
  if (!is.list(specs)) {
    stop("`specs` must be a list.", call. = FALSE)
  }

  # Validate all specs
  is_spec <- sapply(specs, inherits, "t2f_batch_spec")
  if (!all(is_spec)) {
    stop("All elements must be t2f_batch_spec objects.", call. = FALSE)
  }

  # Get default arguments
  default_args <- list(
    sub_dir = sub_dir,
    theme = theme,
    ...
  )

  # Define processing function
  process_one <- function(spec) {
    if (verbose) {
      message("Processing: ", spec$filename)
    }

    # Merge defaults with spec-specific args (spec args take precedence)
    args <- default_args
    args$x <- spec$df
    args$filename <- spec$filename
    args$verbose <- FALSE

    for (name in names(spec$args)) {
      args[[name]] <- spec$args[[name]]
    }

    tryCatch(
      do.call(t2f, args),
      error = function(e) {
        warning("Failed to process '", spec$filename, "': ", e$message)
        NA_character_
      }
    )
  }

  # Process tables
  if (parallel && requireNamespace("future.apply", quietly = TRUE)) {
    if (verbose) {
      message("Processing ", length(specs), " tables in parallel...")
    }
    results <- future.apply::future_lapply(specs, process_one)
  } else {
    if (verbose) {
      message("Processing ", length(specs), " tables sequentially...")
    }
    results <- lapply(specs, process_one)
  }

  names(results) <- sapply(specs, function(s) s$filename)

  # Report summary
  successful <- !is.na(unlist(results))
  if (verbose) {
    message(
      "Completed: ", sum(successful), "/", length(results),
      " tables processed successfully."
    )
  }

  invisible(results)
}
