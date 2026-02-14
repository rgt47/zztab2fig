#' Cell-Level Formatting Utilities
#'
#' @description Functions for specifying cell-level formatting in t2f tables.
#'   These utilities allow highlighting specific cells, rows, or columns with
#'   bold, italic, colors, or conditional formatting.
#'
#' @name formatting
NULL

#' Create a formatting specification
#'
#' @description Define formatting rules for specific cells in a table.
#'   Formatting can target specific rows, columns, or both, and can include
#'   bold, italic, colors, or conditional highlighting.
#'
#' @param rows Integer vector. Row indices to format (1-based, excluding
#'   header). NULL to apply to all rows.
#' @param cols Integer vector or character vector. Column indices or names to
#'   format. NULL to apply to all columns.
#' @param bold Logical. If TRUE, apply bold formatting.
#' @param italic Logical. If TRUE, apply italic formatting.
#' @param color Character. LaTeX color name for text (e.g., "red", "blue").
#' @param background Character. LaTeX color name for cell background.
#' @param condition A function that takes a cell value and returns TRUE/FALSE.
#'   Formatting is applied only to cells where condition returns TRUE.
#'
#' @return A t2f_format object (list with class "t2f_format").
#'
#' @examples
#' \dontrun{
#' # Bold specific cells
#' t2f_format(rows = 1:3, cols = 1, bold = TRUE)
#'
#' # Highlight a column
#' t2f_format(cols = "p_value", background = "yellow!30")
#'
#' # Conditional formatting
#' t2f_format(cols = "p_value",
#'            condition = function(x) as.numeric(x) < 0.05,
#'            bold = TRUE, color = "red")
#' }
#'
#' @export
t2f_format <- function(rows = NULL,
                       cols = NULL,
                       bold = FALSE,
                       italic = FALSE,
                       color = NULL,
                       background = NULL,
                       condition = NULL) {
  # Validate inputs

  if (!is.null(rows) && !is.numeric(rows)) {
    stop("`rows` must be NULL or a numeric vector.", call. = FALSE)
  }
  if (!is.null(cols) && !is.numeric(cols) && !is.character(cols)) {
    stop("`cols` must be NULL, numeric, or character vector.", call. = FALSE)
  }
  if (!is.logical(bold) || length(bold) != 1) {
    stop("`bold` must be a single logical value.", call. = FALSE)
  }
  if (!is.logical(italic) || length(italic) != 1) {
    stop("`italic` must be a single logical value.", call. = FALSE)
  }
  if (!is.null(color) && (!is.character(color) || length(color) != 1)) {
    stop("`color` must be NULL or a single character string.", call. = FALSE)
  }
  if (!is.null(background) && (!is.character(background) ||
    length(background) != 1)) {
    stop("`background` must be NULL or a single character string.",
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
    class = "t2f_format"
  )
}

#' Highlight cells based on a condition
#'
#' @description Convenience function for conditional cell highlighting.
#'
#' @param condition A function that takes a cell value and returns TRUE/FALSE.
#' @param background LaTeX color for highlighted cells. Defaults to "yellow!30".
#' @param bold Logical. Also apply bold to highlighted cells.
#' @param color LaTeX text color for highlighted cells.
#'
#' @return A t2f_format object with the condition and styling specified.
#'
#' @examples
#' \dontrun{
#' # Highlight significant p-values
#' t2f_highlight(function(x) as.numeric(x) < 0.05)
#'
#' # Highlight large values in red
#' t2f_highlight(function(x) x > 100, background = "red!20", bold = TRUE)
#' }
#'
#' @export
t2f_highlight <- function(condition,
                          background = "yellow!30",
                          bold = FALSE,
                          color = NULL) {
  if (!is.function(condition)) {
    stop("`condition` must be a function.", call. = FALSE)
  }

  t2f_format(
    condition = condition,
    background = background,
    bold = bold,
    color = color
  )
}

#' Bold specific columns
#'
#' @description Convenience function to bold entire columns.
#'
#' @param cols Integer vector or character vector of column indices or names.
#'
#' @return A t2f_format object with bold=TRUE for specified columns.
#'
#' @examples
#' \dontrun{
#' t2f_bold_col(c("estimate", "p_value"))
#' t2f_bold_col(1:2)
#' }
#'
#' @export
t2f_bold_col <- function(cols) {
  if (is.null(cols) || length(cols) == 0) {
    stop("`cols` must be a non-empty vector.", call. = FALSE)
  }
  t2f_format(cols = cols, bold = TRUE)
}

#' Italicize specific columns
#'
#' @description Convenience function to italicize entire columns.
#'
#' @param cols Integer vector or character vector of column indices or names.
#'
#' @return A t2f_format object with italic=TRUE for specified columns.
#'
#' @examples
#' \dontrun{
#' t2f_italic_col("variable")
#' }
#'
#' @export
t2f_italic_col <- function(cols) {
  if (is.null(cols) || length(cols) == 0) {
    stop("`cols` must be a non-empty vector.", call. = FALSE)
  }
  t2f_format(cols = cols, italic = TRUE)
}

#' Color specific rows
#'
#' @description Convenience function to apply background color to rows.
#'
#' @param rows Integer vector of row indices (1-based, excluding header).
#' @param background LaTeX color for row background.
#'
#' @return A t2f_format object with specified background for rows.
#'
#' @examples
#' \dontrun{
#' t2f_color_row(1, "gray!20")
#' t2f_color_row(c(1, 3, 5), "blue!10")
#' }
#'
#' @export
t2f_color_row <- function(rows, background) {
  if (!is.numeric(rows) || length(rows) == 0) {
    stop("`rows` must be a non-empty numeric vector.", call. = FALSE)
  }
  if (!is.character(background) || length(background) != 1) {
    stop("`background` must be a single character string.", call. = FALSE)
  }
  t2f_format(rows = rows, background = background)
}

#' Print method for t2f_format objects
#'
#' @param x A t2f_format object.
#' @param ... Additional arguments (ignored).
#' @return Invisibly returns x.
#' @export
print.t2f_format <- function(x, ...) {
  cat("t2f formatting specification:\n")
  if (!is.null(x$rows)) cat("  Rows:", paste(x$rows, collapse = ", "), "\n")
  if (!is.null(x$cols)) cat("  Cols:", paste(x$cols, collapse = ", "), "\n")
  styles <- c()
  if (x$bold) styles <- c(styles, "bold")
  if (x$italic) styles <- c(styles, "italic")
  if (!is.null(x$color)) styles <- c(styles, paste0("color=", x$color))
  if (!is.null(x$background)) {
    styles <- c(styles, paste0("background=", x$background))
  }
  if (length(styles) > 0) {
    cat("  Styles:", paste(styles, collapse = ", "), "\n")
  }
  if (!is.null(x$condition)) cat("  Conditional: yes\n")
  invisible(x)
}

#' Apply formatting specifications to a kableExtra table
#'
#' @description Internal function that applies a list of t2f_format objects
#'   to a kableExtra LaTeX table.
#'
#' @param kable_obj A kableExtra table object.
#' @param df The original data frame (for resolving column names).
#' @param formatting A list of t2f_format objects.
#'
#' @return The modified kableExtra table object.
#' @keywords internal
apply_formatting <- function(kable_obj, df, formatting) {
  if (is.null(formatting) || length(formatting) == 0) {
    return(kable_obj)
  }

  # Ensure formatting is a list
  if (inherits(formatting, "t2f_format")) {
    formatting <- list(formatting)
  }

  for (fmt in formatting) {
    if (!inherits(fmt, "t2f_format")) {
      warning("Skipping non-t2f_format object in formatting list.")
      next
    }

    kable_obj <- apply_single_format(kable_obj, df, fmt)
  }

  kable_obj
}

#' Apply a single formatting specification
#'
#' @param kable_obj A kableExtra table object.
#' @param df The original data frame.
#' @param fmt A t2f_format object.
#'
#' @return The modified kableExtra table object.
#' @keywords internal
apply_single_format <- function(kable_obj, df, fmt) {
  # Resolve column indices
  col_indices <- resolve_col_indices(fmt$cols, df)

  # Resolve row indices
  row_indices <- fmt$rows
  if (is.null(row_indices)) {
    row_indices <- seq_len(nrow(df))
  }

  # For conditional formatting, we need to filter rows
  if (!is.null(fmt$condition) && length(col_indices) > 0) {
    matching_rows <- integer(0)
    for (row in row_indices) {
      for (col in col_indices) {
        val <- df[row, col]
        if (tryCatch(isTRUE(fmt$condition(val)), error = function(e) FALSE)) {
          matching_rows <- unique(c(matching_rows, row))
        }
      }
    }
    row_indices <- matching_rows
  }

  # Skip if no rows to format
  if (length(row_indices) == 0) {
    return(kable_obj)
  }

  # Apply column-level formatting
  if (length(col_indices) > 0) {
    for (col in col_indices) {
      kable_obj <- kableExtra::column_spec(
        kable_obj,
        column = col,
        bold = fmt$bold,
        italic = fmt$italic,
        color = fmt$color,
        background = fmt$background
      )
    }
  } else {
    # Apply row-level formatting when no columns specified
    for (row in row_indices) {
      kable_obj <- kableExtra::row_spec(
        kable_obj,
        row = row,
        bold = fmt$bold,
        italic = fmt$italic,
        color = fmt$color,
        background = fmt$background
      )
    }
  }

  kable_obj
}

#' Resolve column indices from names or indices
#'
#' @param cols Column specification (NULL, numeric, or character).
#' @param df The data frame.
#' @return Integer vector of column indices.
#' @keywords internal
resolve_col_indices <- function(cols, df) {
  if (is.null(cols)) {
    return(integer(0))
  }

  if (is.numeric(cols)) {
    valid <- cols >= 1 & cols <= ncol(df)
    if (!all(valid)) {
      warning("Some column indices are out of range and will be ignored.")
    }
    return(as.integer(cols[valid]))
  }

  if (is.character(cols)) {
    indices <- match(cols, names(df))
    if (any(is.na(indices))) {
      missing <- cols[is.na(indices)]
      warning("Column names not found: ", paste(missing, collapse = ", "))
    }
    return(indices[!is.na(indices)])
  }

  integer(0)
}
