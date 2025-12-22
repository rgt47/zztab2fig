#' Caching Layer for t2f
#'
#' @description Functions for caching compiled PDF tables to avoid redundant
#'   LaTeX compilation when inputs haven't changed.
#'
#' @name caching
NULL

#' Get the cache directory
#'
#' @description Returns the path to the t2f cache directory. Creates it if
#'   it doesn't exist.
#'
#' @param create Logical. Create the directory if it doesn't exist.
#'
#' @return Path to the cache directory.
#'
#' @export
t2f_cache_dir <- function(create = TRUE) {
  cache_dir <- getOption(
    "zztab2fig.cache_dir",
    file.path(tempdir(), "zztab2fig_cache")
  )

  if (create && !dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  }

  cache_dir
}

#' Set the cache directory
#'
#' @param path Path to use for caching. Set to NULL to use the default
#'   (temp directory).
#'
#' @return Invisibly returns the previous cache directory.
#'
#' @export
t2f_cache_set_dir <- function(path) {

  old <- getOption("zztab2fig.cache_dir")

  if (is.null(path)) {
    options(zztab2fig.cache_dir = NULL)
  } else {
    if (!is.character(path) || length(path) != 1) {
      stop("`path` must be a single character string or NULL.", call. = FALSE)
    }
    options(zztab2fig.cache_dir = path)
  }

  invisible(old)
}

#' Compute hash for cache key
#'
#' @description Compute a hash of the inputs to t2f for use as a cache key.
#'
#' @param df The data frame being processed.
#' @param scolor Row shading color.
#' @param extra_packages Extra LaTeX packages.
#' @param document_class Document class.
#' @param caption Table caption.
#' @param label Table label.
#' @param align Column alignment.
#' @param longtable Longtable setting.
#' @param theme Theme object or name.
#'
#' @return A character string hash.
#' @keywords internal
compute_cache_hash <- function(df, scolor = NULL, extra_packages = NULL,
                               document_class = NULL, caption = NULL,
                               label = NULL, align = NULL, longtable = FALSE,
                               theme = NULL) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The 'digest' package is required for caching.", call. = FALSE)
  }

  # Normalize theme to name for consistent hashing
  theme_name <- if (inherits(theme, "t2f_theme")) theme$name else theme

  hash_input <- list(
    df = df,
    scolor = scolor,
    extra_packages = extra_packages,
    document_class = document_class,
    caption = caption,
    label = label,
    align = align,
    longtable = longtable,
    theme = theme_name
  )

  digest::digest(hash_input, algo = "xxhash64")
}

#' Check cache for existing output
#'
#' @description Check if a cached version of the output exists.
#'
#' @param hash Cache key hash.
#' @param output_format Target output format.
#'
#' @return Path to cached file if it exists, NULL otherwise.
#' @keywords internal
check_cache <- function(hash, output_format = "pdf") {
  cache_dir <- t2f_cache_dir(create = FALSE)

  if (!dir.exists(cache_dir)) {
    return(NULL)
  }

  ext <- switch(output_format,
    "pdf" = ".pdf",
    "png" = ".png",
    "svg" = ".svg",
    "tex" = ".tex",
    ".pdf"
  )

  cache_path <- file.path(cache_dir, paste0(hash, ext))

  if (file.exists(cache_path)) {
    cache_path
  } else {
    NULL
  }
}

#' Store output in cache
#'
#' @description Copy the generated output to the cache directory.
#'
#' @param source_path Path to the generated file.
#' @param hash Cache key hash.
#'
#' @return Path to the cached file.
#' @keywords internal
store_in_cache <- function(source_path, hash) {
  if (!file.exists(source_path)) {
    warning("Cannot cache: source file does not exist.")
    return(NULL)
  }

  cache_dir <- t2f_cache_dir(create = TRUE)
  ext <- tools::file_ext(source_path)
  cache_path <- file.path(cache_dir, paste0(hash, ".", ext))

  file.copy(source_path, cache_path, overwrite = TRUE)

  cache_path
}

#' Retrieve from cache
#'
#' @description Copy a cached file to the target location.
#'
#' @param cache_path Path to the cached file.
#' @param target_path Target path for the output.
#'
#' @return Logical indicating success.
#' @keywords internal
retrieve_from_cache <- function(cache_path, target_path) {
  if (!file.exists(cache_path)) {
    return(FALSE)
  }

  # Ensure target directory exists
  target_dir <- dirname(target_path)
  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
  }

  file.copy(cache_path, target_path, overwrite = TRUE)
}

#' Clear the t2f cache
#'
#' @description Remove all cached files.
#'
#' @param older_than Numeric. Only remove files older than this many days.
#'   If NULL (default), removes all cached files.
#'
#' @return Invisibly returns the number of files removed.
#'
#' @examples
#' \dontrun{
#' t2f_cache_clear()
#' t2f_cache_clear(older_than = 7)
#' }
#'
#' @export
t2f_cache_clear <- function(older_than = NULL) {
  cache_dir <- t2f_cache_dir(create = FALSE)

  if (!dir.exists(cache_dir)) {
    message("Cache directory does not exist.")
    return(invisible(0))
  }

  files <- list.files(cache_dir, full.names = TRUE)

  if (length(files) == 0) {
    message("Cache is empty.")
    return(invisible(0))
  }

  if (!is.null(older_than)) {
    cutoff <- Sys.time() - (older_than * 24 * 60 * 60)
    file_times <- file.mtime(files)
    files <- files[file_times < cutoff]
  }

  if (length(files) == 0) {
    message("No files to remove.")
    return(invisible(0))
  }

  removed <- unlink(files)
  message("Removed ", length(files), " cached file(s).")

  invisible(length(files))
}

#' Get cache statistics
#'
#' @description Report on the current state of the t2f cache.
#'
#' @return A list with cache statistics.
#'
#' @examples
#' \dontrun{
#' t2f_cache_info()
#' }
#'
#' @export
t2f_cache_info <- function() {
  cache_dir <- t2f_cache_dir(create = FALSE)

  if (!dir.exists(cache_dir)) {
    return(list(
      exists = FALSE,
      path = cache_dir,
      files = 0,
      size_mb = 0
    ))
  }

  files <- list.files(cache_dir, full.names = TRUE)
  sizes <- file.size(files)

  list(
    exists = TRUE,
    path = cache_dir,
    files = length(files),
    size_mb = round(sum(sizes, na.rm = TRUE) / 1024 / 1024, 2),
    oldest = if (length(files) > 0) min(file.mtime(files)) else NA,
    newest = if (length(files) > 0) max(file.mtime(files)) else NA
  )
}
