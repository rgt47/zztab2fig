#' Advanced Table Features for zztab2fig
#'
#' @description Functions for creating sophisticated LaTeX tables with footnotes,
#'   spanning headers, multi-row cells, and decimal alignment.
#'
#' @name advanced-features
NULL

# Footnote Functions ----

#' Create table footnotes
#'
#' @description Create footnote specifications for use with t2f(). Supports
#'   multiple notation styles following academic conventions.
#'
#' @param general Character vector. General footnotes (unlabeled).
#' @param number Character vector. Footnotes with numeric labels (1, 2, 3).
#' @param alphabet Character vector. Footnotes with alphabetic labels (a, b, c).
#' @param symbol Character vector. Footnotes with symbol labels (*, †, ‡).
#' @param title_general Character. Header for general footnotes section.
#' @param title_number Character. Header for numbered footnotes section.
#' @param title_alphabet Character. Header for alphabetic footnotes section.
#' @param title_symbol Character. Header for symbol footnotes section.
#' @param footnote_as_chunk Logical. If TRUE, print footnotes as a text chunk
#'   rather than a list.
#' @param threeparttable Logical. If TRUE (default), wrap table in
#'   threeparttable environment for proper footnote placement.
#'
#' @return A t2f_footnote object (list with class "t2f_footnote").
#'
#' @details
#' Table footnotes in LaTeX require special handling. This function creates a
#' specification that t2f() uses to apply kableExtra's footnote() function.
#'
#' The threeparttable option (default TRUE) ensures footnotes appear directly
#' below the table rather than at the page bottom.
#'
#' @examples
#' \dontrun{
#' # Simple general footnote
#' fn <- t2f_footnote(general = "Data from 2024 survey.")
#'
#' # Multiple notation styles (APA format)
#' fn <- t2f_footnote(
#'   general = "CI = confidence interval.",
#'   symbol = c("p < 0.05", "p < 0.01", "p < 0.001")
#' )
#'
#' # Use with t2f()
#' t2f(df, footnote = fn)
#' }
#'
#' @export
t2f_footnote <- function(general = NULL,
                         number = NULL,
                         alphabet = NULL,
                         symbol = NULL,
                         title_general = NULL,
                         title_number = NULL,
                         title_alphabet = NULL,
                         title_symbol = NULL,
                         footnote_as_chunk = FALSE,
                         threeparttable = TRUE) {
  structure(
    list(
      general = general,
      number = number,
      alphabet = alphabet,
      symbol = symbol,
      general_title = title_general,
      number_title = title_number,
      alphabet_title = title_alphabet,
      symbol_title = title_symbol,
      footnote_as_chunk = footnote_as_chunk,
      threeparttable = threeparttable
    ),
    class = "t2f_footnote"
  )
}

#' Create footnote marker for table cells
#'
#' @description Insert a footnote marker into a cell value. Use this to mark
#'   cells that correspond to footnotes.
#'
#' @param text The cell text to add a marker to.
#' @param mark The footnote marker (number, letter, or symbol index).
#' @param type Marker type: "number", "alphabet", or "symbol".
#'
#' @return Character string with LaTeX footnote marker.
#'
#' @examples
#' \dontrun{
#' df$value[1] <- t2f_mark("23.5", 1, "symbol")
#' # Produces: "23.5*" (with proper LaTeX superscript)
#' }
#'
#' @export
t2f_mark <- function(text, mark, type = c("symbol", "number", "alphabet")) {

  type <- match.arg(type)

  symbols <- c("*", "\\\\dag", "\\\\ddag", "\\\\S", "\\\\P")

  marker <- switch(type,
    symbol = if (mark <= length(symbols)) symbols[mark] else as.character(mark),
    number = as.character(mark),
    alphabet = letters[mark]
  )

  paste0(text, "$^{\\textrm{", marker, "}}$")
}

#' Print method for t2f_footnote objects
#'
#' @param x A t2f_footnote object.
#' @param ... Additional arguments (ignored).
#' @return Invisibly returns x.
#' @export
print.t2f_footnote <- function(x, ...) {
  cat("t2f footnote specification:\n")
  if (!is.null(x$general)) {
    cat("  General:", length(x$general), "note(s)\n")
  }
  if (!is.null(x$number)) {
    cat("  Numbered:", length(x$number), "note(s)\n")
  }
  if (!is.null(x$alphabet)) {
    cat("  Alphabetic:", length(x$alphabet), "note(s)\n")
  }
  if (!is.null(x$symbol)) {
    cat("  Symbol:", length(x$symbol), "note(s)\n")
  }
  cat("  Threeparttable:", x$threeparttable, "\n")
  invisible(x)
}

# Spanning Header Functions ----
#' Create spanning header specification
#'
#' @description Create a spanning header row for grouped columns. Headers span
#'   multiple columns with appropriate rules (cmidrule).
#'
#' @param ... Named arguments where names are header labels and values are the
#'   number of columns to span. Use " " (space) for columns without a spanning
#'   header.
#' @param bold Logical. Bold header text.
#' @param italic Logical. Italic header text.
#' @param align Alignment for header cells ("c", "l", or "r").
#' @param line Logical. Add horizontal line below spanning header.
#' @param line_sep Numeric. Space between line and header text (pts).
#'
#' @return A t2f_header object (list with class "t2f_header").
#'
#' @details
#' The sum of column spans must equal the number of columns in the table
#' (including row names if present).
#'
#' @examples
#' \dontrun{
#' # Table with 5 columns: one label column, two "Treatment", two "Control"
#' hdr <- t2f_header_above(
#'   " " = 1,
#'   "Treatment" = 2,
#'   "Control" = 2
#' )
#'
#' t2f(df, header_above = hdr)
#'
#' # Multiple header rows
#' t2f(df, header_above = list(
#'   t2f_header_above(" " = 1, "Group A" = 2, "Group B" = 2),
#'   t2f_header_above(" " = 1, "T1" = 1, "T2" = 1, "C1" = 1, "C2" = 1)
#' ))
#' }
#'
#' @export
t2f_header_above <- function(..., bold = TRUE, italic = FALSE,
                              align = "c", line = TRUE, line_sep = 3) {
  header <- c(...)


  if (!is.numeric(header) || is.null(names(header))) {
    stop("Arguments must be named with numeric spans, e.g., 'Group' = 2",
      call. = FALSE)
  }

  structure(
    list(
      header = header,
      bold = bold,
      italic = italic,
      align = align,
      line = line,
      line_sep = line_sep
    ),
    class = "t2f_header"
  )
}

#' Print method for t2f_header objects
#'
#' @param x A t2f_header object.
#' @param ... Additional arguments (ignored).
#' @return Invisibly returns x.
#' @export
print.t2f_header <- function(x, ...) {
  cat("t2f spanning header:\n")
  for (i in seq_along(x$header)) {
    cat(sprintf("  %s: %d column(s)\n", names(x$header)[i], x$header[i]))
  }
  cat("  Style: bold =", x$bold, ", italic =", x$italic, "\n")
  invisible(x)
}

# Multi-row (Collapse Rows) Functions ----

#' Create collapse rows specification
#'
#' @description Specify columns to collapse into multi-row cells. Consecutive
#'   identical values are merged using LaTeX multirow.
#'
#' @param columns Integer vector or column names. Columns to collapse.
#' @param valign Vertical alignment: "top", "middle", or "bottom".
#' @param latex_hline Horizontal line style: "full", "major", "none", or
#'   "custom".
#' @param row_group_label_position Position of group labels: "stack" or
#'   "identity".
#' @param custom_latex_hline Integer vector. Row indices for custom hlines
#'   (when latex_hline = "custom").
#' @param row_group_label_fonts List of font specifications for group labels.
#'
#' @return A t2f_collapse object (list with class "t2f_collapse").
#'
#' @examples
#' \dontrun{
#' # Collapse first column
#' t2f(df, collapse_rows = t2f_collapse_rows(1))
#'
#' # Collapse by column name with top alignment
#' t2f(df, collapse_rows = t2f_collapse_rows("group", valign = "top"))
#' }
#'
#' @export
t2f_collapse_rows <- function(columns = NULL,
                               valign = c("middle", "top", "bottom"),
                               latex_hline = c("full", "major", "none", "custom"),
                               row_group_label_position = c("stack", "identity"),
                               custom_latex_hline = NULL,
                               row_group_label_fonts = NULL) {
  valign <- match.arg(valign)
  latex_hline <- match.arg(latex_hline)
  row_group_label_position <- match.arg(row_group_label_position)

  structure(
    list(
      columns = columns,
      valign = valign,
      latex_hline = latex_hline,
      row_group_label_position = row_group_label_position,
      custom_latex_hline = custom_latex_hline,
      row_group_label_fonts = row_group_label_fonts
    ),
    class = "t2f_collapse"
  )
}

#' Print method for t2f_collapse objects
#'
#' @param x A t2f_collapse object.
#' @param ... Additional arguments (ignored).
#' @return Invisibly returns x.
#' @export
print.t2f_collapse <- function(x, ...) {
  cat("t2f collapse rows specification:\n")
  cat("  Columns:", paste(x$columns, collapse = ", "), "\n")
  cat("  Vertical align:", x$valign, "\n")
  cat("  Horizontal lines:", x$latex_hline, "\n")
  invisible(x)
}

# Decimal Alignment Functions ----

#' Create siunitx column specification for decimal alignment
#'
#' @description Generate a siunitx S column specification for decimal-aligned
#'   numeric columns. This provides proper alignment on the decimal point.
#'
#' @param table_format Format string for siunitx table-format option. Specifies
#'   the number of integer and decimal places (e.g., "3.2" for up to 999.99).
#' @param round_mode Rounding mode: "places", "figures", or "none".
#' @param round_precision Number of decimal places or significant figures.
#' @param detect_weight Logical. Detect and preserve bold text.
#' @param group_separator Thousands separator (e.g., "," or " ").
#'
#' @return A t2f_siunitx object containing the column specification and
#'   required LaTeX packages.
#'
#' @details
#' The siunitx package provides sophisticated number formatting including
#' decimal alignment. This function creates a custom column type that can be
#' used in the align parameter.
#'
#' Note: When using siunitx columns, non-numeric content (like header text)
#' must be wrapped in braces \code{\{text\}}.
#'
#' @examples
#' \dontrun{
#' # Create decimal-aligned column spec
#' dec_align <- t2f_siunitx(table_format = "2.3")
#'
#' # Apply to specific columns using align parameter
#' t2f(df, align = c("l", dec_align, dec_align, "r"),
#'     extra_packages = attr(dec_align, "packages"))
#' }
#'
#' @export
t2f_siunitx <- function(table_format = "3.2",
                         round_mode = c("none", "places", "figures"),
                         round_precision = NULL,
                         detect_weight = TRUE,
                         group_separator = NULL) {
  round_mode <- match.arg(round_mode)

  # Build siunitx options
  opts <- c(paste0("table-format=", table_format))

  if (round_mode != "none" && !is.null(round_precision)) {
    opts <- c(opts, paste0("round-mode=", round_mode))
    opts <- c(opts, paste0("round-precision=", round_precision))
  }

  if (detect_weight) {
    opts <- c(opts, "detect-weight=true", "mode=text")
  }

  if (!is.null(group_separator)) {
    opts <- c(opts, paste0("group-separator={", group_separator, "}"))
  }

  # Create column specification
  col_spec <- paste0("S[", paste(opts, collapse = ","), "]")

  # Required LaTeX setup
  packages <- c(
    "\\usepackage{siunitx}",
    "\\sisetup{detect-all}"
  )

  structure(
    col_spec,
    class = "t2f_siunitx",
    packages = packages
  )
}

#' Print method for t2f_siunitx objects
#'
#' @param x A t2f_siunitx object.
#' @param ... Additional arguments (ignored).
#' @return Invisibly returns x.
#' @export
print.t2f_siunitx <- function(x, ...) {
  cat("t2f siunitx column specification:\n")
  cat(" ", as.character(x), "\n")
  cat("  Required packages:\n")
  for (pkg in attr(x, "packages")) {
    cat("   ", pkg, "\n")
  }
  invisible(x)
}

#' Create decimal-aligned column specification (convenience wrapper)
#'
#' @description Convenience function to create decimal-aligned columns.
#'   Returns alignment string and updates extra_packages.
#'
#' @param integers Maximum integer digits before decimal point.
#' @param decimals Maximum decimal digits after decimal point.
#'
#' @return A t2f_siunitx object.
#'
#' @examples
#' \dontrun{
#' # Align numbers up to 99.999
#' t2f(df, align = c("l", t2f_decimal(2, 3), t2f_decimal(2, 3)))
#' }
#'
#' @export
t2f_decimal <- function(integers = 3, decimals = 2) {
  t2f_siunitx(table_format = paste0(integers, ".", decimals))
}

# Helper Functions for Applying Features ----

#' Apply footnotes to kable object
#' @param kable_obj A kable object.
#' @param footnote_spec A t2f_footnote object.
#' @return Modified kable object with footnotes.
#' @keywords internal
apply_footnotes <- function(kable_obj, footnote_spec) {
  if (is.null(footnote_spec) || !inherits(footnote_spec, "t2f_footnote")) {
    return(kable_obj)
  }

  kableExtra::footnote(
    kable_obj,
    general = footnote_spec$general,
    number = footnote_spec$number,
    alphabet = footnote_spec$alphabet,
    symbol = footnote_spec$symbol,
    general_title = footnote_spec$general_title,
    number_title = footnote_spec$number_title,
    alphabet_title = footnote_spec$alphabet_title,
    symbol_title = footnote_spec$symbol_title,
    footnote_as_chunk = footnote_spec$footnote_as_chunk,
    threeparttable = footnote_spec$threeparttable
  )
}

#' Apply spanning headers to kable object
#' @param kable_obj A kable object.
#' @param header_spec A t2f_header object or list of them.
#' @return Modified kable object with spanning headers.
#' @keywords internal
apply_header_above <- function(kable_obj, header_spec) {
  if (is.null(header_spec)) {
    return(kable_obj)
  }

  # Handle single header or list of headers
  if (inherits(header_spec, "t2f_header")) {
    header_spec <- list(header_spec)
  }

  for (hdr in header_spec) {
    if (!inherits(hdr, "t2f_header")) next

    kable_obj <- kableExtra::add_header_above(
      kable_obj,
      header = hdr$header,
      bold = hdr$bold,
      italic = hdr$italic,
      align = hdr$align,
      line = hdr$line,
      line_sep = hdr$line_sep
    )
  }

  kable_obj
}

#' Apply collapse rows to kable object
#' @param kable_obj A kable object.
#' @param collapse_spec A t2f_collapse object.
#' @return Modified kable object with collapsed rows.
#' @keywords internal
apply_collapse_rows <- function(kable_obj, collapse_spec) {
  if (is.null(collapse_spec) || !inherits(collapse_spec, "t2f_collapse")) {
    return(kable_obj)
  }

  kableExtra::collapse_rows(
    kable_obj,
    columns = collapse_spec$columns,
    valign = collapse_spec$valign,
    latex_hline = collapse_spec$latex_hline,
    row_group_label_position = collapse_spec$row_group_label_position,
    custom_latex_hline = collapse_spec$custom_latex_hline,
    row_group_label_fonts = collapse_spec$row_group_label_fonts
  )
}

#' Process alignment specification for siunitx columns
#'
#' @description Process alignment vector, extracting siunitx column specs
#'   and collecting required packages.
#'
#' @param align Alignment specification (may include t2f_siunitx objects).
#' @return List with processed alignment string and required packages.
#' @keywords internal
process_alignment <- function(align) {
  if (is.null(align)) {
    return(list(align = NULL, packages = NULL))
  }

  packages <- character(0)
  processed_align <- character(length(align))

  for (i in seq_along(align)) {
    if (inherits(align[[i]], "t2f_siunitx")) {
      processed_align[i] <- as.character(align[[i]])
      packages <- c(packages, attr(align[[i]], "packages"))
    } else {
      processed_align[i] <- as.character(align[i])
    }
  }

  list(
    align = paste(processed_align, collapse = ""),
    packages = unique(packages)
  )
}
