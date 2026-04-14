#' Structural Specifications for zzt2f Tables
#'
#' @description Spec constructors for spanning headers and collapsed
#'   (merged) rows. Consumed by \code{zzt2f()} via the
#'   \code{header_above} and \code{collapse_rows} parameters.
#'
#' @name zzt2f-structure
NULL

#' Spanning column headers (Typst backend)
#'
#' @description Thin constructor that delegates to
#'   \code{t2f_header_above()}. The underlying \code{t2f_header} spec
#'   is backend-agnostic; \code{zzt2f()} already consumes it via
#'   \code{tinytable::group_tt()}. This constructor exists so the
#'   Typst pipeline has a naming-consistent entry point.
#'
#' @param ... Named numeric spans, e.g., \code{"Group" = 2}.
#' @param bold Logical.
#' @param italic Logical.
#' @param align Character.
#' @param line Logical. Retained for API symmetry with
#'   \code{t2f_header_above}; Typst draws spanning-header rules
#'   automatically via \code{group_tt()}.
#' @param line_sep Numeric. Retained for API symmetry; no effect on
#'   Typst output.
#' @return A \code{t2f_header} object.
#' @examples
#' \dontrun{
#' hdr <- zzt2f_header_above(" " = 1, "Treatment" = 2, "Control" = 2)
#' zzt2f(df, header_above = hdr)
#' }
#' @export
zzt2f_header_above <- function(..., bold = TRUE, italic = FALSE,
                               align = "c", line = TRUE,
                               line_sep = 3) {
  t2f_header_above(
    ..., bold = bold, italic = italic, align = align,
    line = line, line_sep = line_sep
  )
}

#' Collapse repeated values in columns (Typst backend)
#'
#' @description Create a specification that visually merges
#'   consecutive cells with identical values in the specified
#'   columns. Achieved by replacing repeated values with empty
#'   strings before the tinytable is built; optionally inserts
#'   horizontal rules between groups.
#'
#' @param columns Integer or character vector. Columns in which to
#'   collapse consecutive repeated values. NULL applies to all
#'   columns, matching \code{t2f_collapse_rows()} behavior.
#' @param hline Character. One of \code{"major"} (rule only between
#'   group boundaries in the first specified column), \code{"full"}
#'   (rule between every group boundary in any specified column),
#'   or \code{"none"}.
#' @return A \code{zzt2f_collapse} object.
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   Group = rep(c("A", "B"), each = 3),
#'   Subgroup = rep(c("x", "y", "z"), 2),
#'   Value = 1:6
#' )
#' zzt2f(df, collapse_rows = zzt2f_collapse_rows("Group"))
#' }
#' @export
zzt2f_collapse_rows <- function(columns = NULL,
                                hline = c("major", "full", "none")) {
  hline <- match.arg(hline)
  if (!is.null(columns) &&
      !is.numeric(columns) && !is.character(columns)) {
    stop(
      "`columns` must be NULL, numeric, or character vector.",
      call. = FALSE
    )
  }
  structure(
    list(columns = columns, hline = hline),
    class = "zzt2f_collapse"
  )
}

#' Print method for zzt2f_collapse
#' @param x A \code{zzt2f_collapse} object.
#' @param ... Ignored.
#' @return Invisibly \code{x}.
#' @export
print.zzt2f_collapse <- function(x, ...) {
  cat("zzt2f collapse specification:\n")
  cat("  columns: ",
      if (is.null(x$columns)) "<all>"
      else paste(x$columns, collapse = ", "),
      "\n", sep = "")
  cat("  hline: ", x$hline, "\n", sep = "")
  invisible(x)
}

#' Apply a collapse spec to a data frame
#'
#' @description Returns a list with the modified data frame and a
#'   vector of row indices where group boundaries occur (1-based,
#'   data rows). Empty-ing repeated cells must happen before the
#'   tinytable is constructed so that the Typst output reflects the
#'   merged presentation.
#'
#' @param data Data frame.
#' @param spec A \code{zzt2f_collapse} object or NULL.
#' @return A list with elements \code{data} and \code{boundaries}.
#' @keywords internal
apply_zzt2f_collapse <- function(data, spec) {
  if (is.null(spec)) return(list(data = data, boundaries = integer(0)))
  if (!inherits(spec, "zzt2f_collapse")) {
    stop(
      "`collapse_rows` must be a zzt2f_collapse spec or NULL.",
      call. = FALSE
    )
  }

  j_idx <- if (is.null(spec$columns)) {
    seq_len(ncol(data))
  } else {
    resolve_cols(spec$columns, data)
  }

  boundaries <- integer(0)
  for (jj in j_idx) {
    col <- as.character(data[[jj]])
    n <- length(col)
    if (n < 2L) next
    dup <- c(FALSE, col[-1L] == col[-n] & !is.na(col[-1L]) &
               !is.na(col[-n]))
    data[[jj]][dup] <- ""
    if (jj == j_idx[1L]) {
      boundaries <- c(boundaries, which(!dup)[-1L])
    } else if (identical(spec$hline, "full")) {
      boundaries <- c(boundaries, which(!dup)[-1L])
    }
  }

  boundaries <- sort(unique(boundaries))
  list(data = data, boundaries = boundaries)
}
