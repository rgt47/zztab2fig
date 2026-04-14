#' Cell-Level Formatting Specifications for zzt2f
#'
#' @description Spec-object constructors for cell, row, and column
#'   formatting in the Typst backend. Parallel in intent to the
#'   \code{t2f_format} family but consumed by \code{zzt2f()} via the
#'   \code{formats} parameter and applied through
#'   \code{tinytable::style_tt()}.
#'
#' @name zzt2f-formatting
NULL

#' Create a Typst formatting specification
#'
#' @description Define formatting rules for specific cells, rows, or
#'   columns. Consumed by \code{zzt2f()} via its \code{formats}
#'   parameter.
#'
#' @param rows Integer vector or NULL. Row indices (1-based, data rows
#'   only; header is row 0 in tinytable conventions but is not
#'   targeted here).
#' @param cols Integer or character vector or NULL. Column indices or
#'   names.
#' @param bold Logical.
#' @param italic Logical.
#' @param color Character or NULL. LaTeX color name or hex string;
#'   translated via \code{translate_latex_color()}.
#' @param background Character or NULL. LaTeX color name or hex
#'   string for cell background.
#' @param condition Function or NULL. Applied to cell values (coerced
#'   to character); formatting applies only where it returns TRUE.
#'
#' @return An S3 object of class \code{"zzt2f_format"}.
#' @examples
#' \dontrun{
#' zzt2f_format(rows = 1:3, cols = 1, bold = TRUE)
#' zzt2f_format(cols = "p_value",
#'              condition = function(x) as.numeric(x) < 0.05,
#'              bold = TRUE, color = "red")
#' }
#' @export
zzt2f_format <- function(rows = NULL,
                         cols = NULL,
                         bold = FALSE,
                         italic = FALSE,
                         color = NULL,
                         background = NULL,
                         condition = NULL) {
  if (!is.null(rows) && !is.numeric(rows)) {
    stop("`rows` must be NULL or a numeric vector.", call. = FALSE)
  }
  if (!is.null(cols) && !is.numeric(cols) && !is.character(cols)) {
    stop(
      "`cols` must be NULL, numeric, or character vector.",
      call. = FALSE
    )
  }
  if (!is.logical(bold) || length(bold) != 1L) {
    stop("`bold` must be a single logical value.", call. = FALSE)
  }
  if (!is.logical(italic) || length(italic) != 1L) {
    stop("`italic` must be a single logical value.", call. = FALSE)
  }
  if (!is.null(color) && (!is.character(color) || length(color) != 1L)) {
    stop(
      "`color` must be NULL or a single character string.",
      call. = FALSE
    )
  }
  if (!is.null(background) &&
      (!is.character(background) || length(background) != 1L)) {
    stop(
      "`background` must be NULL or a single character string.",
      call. = FALSE
    )
  }
  if (!is.null(condition) && !is.function(condition)) {
    stop("`condition` must be NULL or a function.", call. = FALSE)
  }

  structure(
    list(
      rows = rows,
      cols = cols,
      bold = bold,
      italic = italic,
      color = color,
      background = background,
      condition = condition
    ),
    class = "zzt2f_format"
  )
}

#' Bold specific columns (Typst backend)
#'
#' @param cols Integer or character vector.
#' @return A \code{zzt2f_format} spec.
#' @examples
#' \dontrun{
#' zzt2f_bold_col(c("estimate", "p_value"))
#' }
#' @export
zzt2f_bold_col <- function(cols) {
  if (is.null(cols) || length(cols) == 0L) {
    stop("`cols` must be a non-empty vector.", call. = FALSE)
  }
  zzt2f_format(cols = cols, bold = TRUE)
}

#' Italicize specific columns (Typst backend)
#'
#' @param cols Integer or character vector.
#' @return A \code{zzt2f_format} spec.
#' @examples
#' \dontrun{
#' zzt2f_italic_col("variable")
#' }
#' @export
zzt2f_italic_col <- function(cols) {
  if (is.null(cols) || length(cols) == 0L) {
    stop("`cols` must be a non-empty vector.", call. = FALSE)
  }
  zzt2f_format(cols = cols, italic = TRUE)
}

#' Apply background color to rows (Typst backend)
#'
#' @param rows Integer vector.
#' @param background Character. LaTeX color spec or hex string.
#' @return A \code{zzt2f_format} spec.
#' @examples
#' \dontrun{
#' zzt2f_color_row(c(1, 3, 5), "blue!10")
#' }
#' @export
zzt2f_color_row <- function(rows, background) {
  if (!is.numeric(rows) || length(rows) == 0L) {
    stop("`rows` must be a non-empty numeric vector.", call. = FALSE)
  }
  if (!is.character(background) || length(background) != 1L) {
    stop(
      "`background` must be a single character string.",
      call. = FALSE
    )
  }
  zzt2f_format(rows = rows, background = background)
}

#' Highlight cells by condition (Typst backend)
#'
#' @param condition Function returning TRUE/FALSE for cell values.
#' @param background Character. Default LaTeX-style "yellow!30".
#' @param bold Logical.
#' @param color Character or NULL.
#' @return A \code{zzt2f_format} spec.
#' @examples
#' \dontrun{
#' zzt2f_highlight(function(x) as.numeric(x) < 0.05, bold = TRUE)
#' }
#' @export
zzt2f_highlight <- function(condition,
                            background = "yellow!30",
                            bold = FALSE,
                            color = NULL) {
  if (!is.function(condition)) {
    stop("`condition` must be a function.", call. = FALSE)
  }
  zzt2f_format(
    condition = condition,
    background = background,
    bold = bold,
    color = color
  )
}

#' Decimal-place formatting for numeric columns (Typst backend)
#'
#' @description Produces a \code{zzt2f_format} spec that rounds and
#'   formats numeric columns to a fixed number of decimals. Typst has
#'   no direct \code{siunitx} equivalent; alignment is achieved via
#'   \code{tinytable::format_tt()} padding.
#'
#' @param cols Integer or character vector. Columns to format.
#' @param digits Integer. Decimal places (default 3).
#' @return A \code{zzt2f_format} spec with \code{digits} slot attached.
#' @examples
#' \dontrun{
#' zzt2f_decimal(c("estimate", "std.error"), digits = 2)
#' }
#' @export
zzt2f_decimal <- function(cols, digits = 3L) {
  if (is.null(cols) || length(cols) == 0L) {
    stop("`cols` must be a non-empty vector.", call. = FALSE)
  }
  if (!is.numeric(digits) || length(digits) != 1L || digits < 0) {
    stop(
      "`digits` must be a single non-negative integer.",
      call. = FALSE
    )
  }
  spec <- zzt2f_format(cols = cols)
  spec$digits <- as.integer(digits)
  class(spec) <- c("zzt2f_decimal", "zzt2f_format")
  spec
}

#' Print method for zzt2f_format
#' @param x A \code{zzt2f_format} object.
#' @param ... Ignored.
#' @return Invisibly \code{x}.
#' @export
print.zzt2f_format <- function(x, ...) {
  cat("zzt2f format specification:\n")
  if (!is.null(x$rows)) {
    cat("  rows:", paste(utils::head(x$rows, 6), collapse = ", "),
        if (length(x$rows) > 6) "..." else "", "\n")
  }
  if (!is.null(x$cols)) {
    cat("  cols:", paste(utils::head(x$cols, 6), collapse = ", "),
        if (length(x$cols) > 6) "..." else "", "\n")
  }
  if (isTRUE(x$bold)) cat("  bold: TRUE\n")
  if (isTRUE(x$italic)) cat("  italic: TRUE\n")
  if (!is.null(x$color)) cat("  color:", x$color, "\n")
  if (!is.null(x$background)) cat("  background:", x$background, "\n")
  if (!is.null(x$condition)) cat("  condition: <function>\n")
  if (inherits(x, "zzt2f_decimal")) cat("  digits:", x$digits, "\n")
  invisible(x)
}

#' Resolve column spec to integer indices
#'
#' @param cols Integer or character vector, or NULL.
#' @param data Data frame.
#' @return Integer vector of column indices, or NULL when \code{cols}
#'   is NULL.
#' @keywords internal
resolve_cols <- function(cols, data) {
  if (is.null(cols)) return(NULL)
  if (is.character(cols)) {
    idx <- match(cols, names(data))
    if (anyNA(idx)) {
      stop(
        "Unknown column(s): ",
        paste(cols[is.na(idx)], collapse = ", "),
        call. = FALSE
      )
    }
    return(idx)
  }
  idx <- as.integer(cols)
  if (any(idx < 1L | idx > ncol(data))) {
    stop(
      "Column index out of range (ncol = ", ncol(data), ").",
      call. = FALSE
    )
  }
  idx
}

#' Apply a single zzt2f_format spec to a tinytable object
#'
#' @param tbl A \code{tinytable} object.
#' @param spec A \code{zzt2f_format} spec.
#' @param data The data frame backing \code{tbl}.
#' @return Modified \code{tinytable} object.
#' @keywords internal
apply_zzt2f_format <- function(tbl, spec, data) {
  j_idx <- resolve_cols(spec$cols, data)
  i_idx <- spec$rows

  if (inherits(spec, "zzt2f_decimal")) {
    if (!is.null(j_idx)) {
      tbl <- tinytable::format_tt(
        tbl, j = j_idx, digits = spec$digits, num_fmt = "decimal"
      )
    }
    return(tbl)
  }

  if (!is.null(spec$condition)) {
    sub_cols <- if (is.null(j_idx)) seq_len(ncol(data)) else j_idx
    sub_rows <- if (is.null(i_idx)) seq_len(nrow(data)) else i_idx
    matches <- data.frame()
    hits_i <- integer(0)
    hits_j <- integer(0)
    for (jj in sub_cols) {
      vals <- as.character(data[sub_rows, jj])
      ok <- tryCatch(
        suppressWarnings(vapply(
          vals, function(v) isTRUE(spec$condition(v)),
          logical(1L)
        )),
        error = function(e) rep(FALSE, length(vals))
      )
      if (any(ok)) {
        hits_i <- c(hits_i, sub_rows[ok])
        hits_j <- c(hits_j, rep(jj, sum(ok)))
      }
    }
    if (length(hits_i) == 0L) return(tbl)
    for (k in seq_along(hits_i)) {
      tbl <- style_tt_spec(
        tbl, i = hits_i[k], j = hits_j[k], spec = spec
      )
    }
    return(tbl)
  }

  style_tt_spec(tbl, i = i_idx, j = j_idx, spec = spec)
}

#' Dispatch a single \code{style_tt} call for a format spec
#' @keywords internal
style_tt_spec <- function(tbl, i, j, spec) {
  args <- list(tbl)
  if (!is.null(i)) args$i <- i
  if (!is.null(j)) args$j <- j
  if (isTRUE(spec$bold)) args$bold <- TRUE
  if (isTRUE(spec$italic)) args$italic <- TRUE
  if (!is.null(spec$color)) {
    args$color <- translate_latex_color(spec$color)
  }
  if (!is.null(spec$background)) {
    args$background <- translate_latex_color(spec$background)
  }
  do.call(tinytable::style_tt, args)
}

#' Apply a list of zzt2f_format specs to a tinytable object
#'
#' @param tbl A \code{tinytable} object.
#' @param formats A single \code{zzt2f_format}, a list of them, or
#'   NULL.
#' @param data The data frame backing \code{tbl}.
#' @return Modified \code{tinytable} object.
#' @keywords internal
apply_zzt2f_formats <- function(tbl, formats, data) {
  if (is.null(formats)) return(tbl)
  if (inherits(formats, "zzt2f_format")) formats <- list(formats)
  if (!is.list(formats)) {
    stop(
      "`formats` must be a zzt2f_format spec, a list of them, ",
      "or NULL.",
      call. = FALSE
    )
  }
  for (spec in formats) {
    if (!inherits(spec, "zzt2f_format")) {
      stop(
        "Every element of `formats` must be a zzt2f_format spec.",
        call. = FALSE
      )
    }
    tbl <- apply_zzt2f_format(tbl, spec, data)
  }
  tbl
}
