#' LaTeX Figure Inclusion Helpers
#'
#' @description Functions to generate LaTeX code for including t2f-generated
#'   tables as figures in LaTeX documents. Useful in R Markdown with
#'   `results='asis'`.
#'
#' @name latex-include
NULL

#' Include a t2f table as a LaTeX figure
#'
#' @description Generate LaTeX code to include a cropped PDF table in a figure
#'   environment with caption, label, and positioning control.
#'
#' @param path Path to the PDF file (with or without _cropped suffix and .pdf
#'   extension).
#' @param caption Figure caption text.
#' @param label LaTeX label for cross-referencing (e.g., "fig:results").
#' @param position Float position specifier: "htbp", "H", "t", "b", "p", or
#'   combinations.
#' @param width Width specification for includegraphics. Default "\\textwidth".
#' @param center Logical. Center the figure. Default TRUE.
#' @param short_caption Short caption for List of Figures.
#' @param cat Logical. If TRUE (default), prints the LaTeX code via cat().
#'   If FALSE, returns the code as a character string.
#'
#' @return If cat=TRUE, invisibly returns the LaTeX code after printing.
#'   If cat=FALSE, returns the LaTeX code as a character string.
#'
#' @details
#' Use this function in R Markdown code chunks with `results='asis'` to
#' include t2f-generated tables as properly formatted LaTeX figures.
#'
#' The function automatically handles path resolution:
#' - Adds "_cropped.pdf" suffix if not present
#' - Works with or without file extension
#'
#' @examples
#' \dontrun{
#' # In R Markdown chunk with results='asis':
#' t2f(mtcars[1:5,], filename = "cars", sub_dir = "tables")
#' t2f_include("tables/cars",
#'             caption = "Motor Trend Car Data",
#'             label = "fig:cars")
#'
#' # With positioning control
#' t2f_include("tables/cars",
#'             caption = "Motor Trend Car Data",
#'             label = "fig:cars",
#'             position = "H",
#'             width = "0.8\\textwidth")
#' }
#'
#' @export
t2f_include <- function(path,
                        caption = NULL,
                        label = NULL,
                        position = "htbp",
                        width = "\\textwidth",
                        center = TRUE,
                        short_caption = NULL,
                        cat = TRUE) {

  # Resolve path - add _cropped.pdf if needed
  pdf_path <- resolve_pdf_path(path)

  # Build includegraphics command
  include_cmd <- sprintf("\\includegraphics[width=%s]{%s}", width, pdf_path)

  # Build figure environment
  lines <- character(0)

  # Opening
  lines <- c(lines, sprintf("\\begin{figure}[%s]", position))

  # Centering

  if (center) {
    lines <- c(lines, "  \\centering")
  }

  # The graphic
  lines <- c(lines, sprintf("  %s", include_cmd))

  # Caption
  if (!is.null(caption)) {
    if (!is.null(short_caption)) {
      lines <- c(lines, sprintf("  \\caption[%s]{%s}", short_caption, caption))
    } else {
      lines <- c(lines, sprintf("  \\caption{%s}", caption))
    }
  }

  # Label
  if (!is.null(label)) {
    lines <- c(lines, sprintf("  \\label{%s}", label))
  }

  # Closing
  lines <- c(lines, "\\end{figure}")

  result <- paste(lines, collapse = "\n")

  if (cat) {
    cat(result, "\n")
    invisible(result)
  } else {
    result
  }
}

#' Include a t2f table inline (no float)
#'
#' @description Generate LaTeX code to include a cropped PDF table without
#'   a float environment. Useful when exact placement is required.
#'
#' @param path Path to the PDF file.
#' @param width Width specification. Default "\\textwidth".
#' @param center Logical. Center the graphic. Default TRUE.
#' @param vspace Vertical space before/after (e.g., "1em"). Default NULL.
#' @param cat Logical. If TRUE (default), prints via cat().
#'
#' @return LaTeX code (invisibly if cat=TRUE).
#'
#' @examples
#' \dontrun{
#' t2f_include_inline("tables/cars", width = "0.9\\textwidth")
#' }
#'
#' @export
t2f_include_inline <- function(path,
                                width = "\\textwidth",
                                center = TRUE,
                                vspace = NULL,
                                cat = TRUE) {

  pdf_path <- resolve_pdf_path(path)

  lines <- character(0)

  if (!is.null(vspace)) {
    lines <- c(lines, sprintf("\\vspace{%s}", vspace))
  }

  if (center) {
    lines <- c(lines, "\\begin{center}")
  }

  lines <- c(lines, sprintf("\\includegraphics[width=%s]{%s}", width, pdf_path))

  if (center) {
    lines <- c(lines, "\\end{center}")
  }

  if (!is.null(vspace)) {
    lines <- c(lines, sprintf("\\vspace{%s}", vspace))
  }

  result <- paste(lines, collapse = "\n")

  if (cat) {
    cat(result, "\n")
    invisible(result)
  } else {
    result
  }
}

#' Include a t2f table in a wraptable environment
#'
#' @description Generate LaTeX code to include a table with text wrapping
#'   around it. Requires the wrapfig package.
#'
#' @param path Path to the PDF file.
#' @param placement Placement: "r", "R", "l", "L", "i", "I", "o", "O".
#'   Lowercase allows float, uppercase forces position.
#' @param wrap_width Width of the wrapped area (e.g., "0.5\\textwidth").
#' @param width Width of the graphic within wrap area.
#' @param caption Optional caption.
#' @param label Optional label.
#' @param cat Logical. If TRUE (default), prints via cat().
#'
#' @return LaTeX code (invisibly if cat=TRUE).
#'
#' @details
#' Placement options:
#' - r/R: right side of text
#' - l/L: left side of text
#' - i/I: inside margin (near binding)
#' - o/O: outside margin
#'
#' Requires `\\usepackage{wrapfig}` in LaTeX preamble.
#'
#' @examples
#' \dontrun{
#' t2f_include_wrap("tables/cars",
#'                  placement = "r",
#'                  wrap_width = "0.5\\textwidth",
#'                  caption = "Car data")
#' }
#'
#' @export
t2f_include_wrap <- function(path,
                              placement = "r",
                              wrap_width = "0.5\\textwidth",
                              width = NULL,
                              caption = NULL,
                              label = NULL,
                              cat = TRUE) {

  pdf_path <- resolve_pdf_path(path)

  if (is.null(width)) {
    width <- wrap_width
  }

  lines <- character(0)
  lines <- c(lines, sprintf("\\begin{wrapfigure}{%s}{%s}", placement, wrap_width))
  lines <- c(lines, "  \\centering")
  lines <- c(lines, sprintf("  \\includegraphics[width=%s]{%s}", width, pdf_path))

  if (!is.null(caption)) {
    lines <- c(lines, sprintf("  \\caption{%s}", caption))
  }

  if (!is.null(label)) {
    lines <- c(lines, sprintf("  \\label{%s}", label))
  }

  lines <- c(lines, "\\end{wrapfigure}")

  result <- paste(lines, collapse = "\n")

  if (cat) {
    cat(result, "\n")
    invisible(result)
  } else {
    result
  }
}

#' Include side-by-side t2f tables
#'
#' @description Generate LaTeX code for two tables side by side using
#'   minipage environments.
#'
#' @param path1 Path to first PDF.
#' @param path2 Path to second PDF.
#' @param caption1 Caption for first table.
#' @param caption2 Caption for second table.
#' @param label1 Label for first table.
#' @param label2 Label for second table.
#' @param width1 Width of first minipage. Default "0.48\\textwidth".
#' @param width2 Width of second minipage. Default "0.48\\textwidth".
#' @param position Float position specifier.
#' @param main_caption Overall figure caption (optional).
#' @param main_label Overall figure label (optional).
#' @param cat Logical. If TRUE (default), prints via cat().
#'
#' @return LaTeX code (invisibly if cat=TRUE).
#'
#' @examples
#' \dontrun{
#' t2f_include_sidebyside(
#'   "tables/model1", "tables/model2",
#'   caption1 = "(a) Model 1", caption2 = "(b) Model 2",
#'   main_caption = "Comparison of regression models"
#' )
#' }
#'
#' @export
t2f_include_sidebyside <- function(path1, path2,
                                    caption1 = NULL,
                                    caption2 = NULL,
                                    label1 = NULL,
                                    label2 = NULL,
                                    width1 = "0.48\\textwidth",
                                    width2 = "0.48\\textwidth",
                                    position = "htbp",
                                    main_caption = NULL,
                                    main_label = NULL,
                                    cat = TRUE) {

  pdf_path1 <- resolve_pdf_path(path1)
  pdf_path2 <- resolve_pdf_path(path2)

  lines <- character(0)
  lines <- c(lines, sprintf("\\begin{figure}[%s]", position))
  lines <- c(lines, "  \\centering")

  # First minipage
  lines <- c(lines, sprintf("  \\begin{minipage}{%s}", width1))
  lines <- c(lines, "    \\centering")
  lines <- c(lines, sprintf("    \\includegraphics[width=\\textwidth]{%s}",
                            pdf_path1))
  if (!is.null(caption1)) {
    lines <- c(lines, sprintf("    \\caption{%s}", caption1))
  }
  if (!is.null(label1)) {
    lines <- c(lines, sprintf("    \\label{%s}", label1))
  }
  lines <- c(lines, "  \\end{minipage}")

  lines <- c(lines, "  \\hfill")

 # Second minipage
  lines <- c(lines, sprintf("  \\begin{minipage}{%s}", width2))
  lines <- c(lines, "    \\centering")
  lines <- c(lines, sprintf("    \\includegraphics[width=\\textwidth]{%s}",
                            pdf_path2))
  if (!is.null(caption2)) {
    lines <- c(lines, sprintf("    \\caption{%s}", caption2))
  }
  if (!is.null(label2)) {
    lines <- c(lines, sprintf("    \\label{%s}", label2))
  }
  lines <- c(lines, "  \\end{minipage}")

  # Main caption/label
  if (!is.null(main_caption)) {
    lines <- c(lines, sprintf("  \\caption{%s}", main_caption))
  }
  if (!is.null(main_label)) {
    lines <- c(lines, sprintf("  \\label{%s}", main_label))
  }

  lines <- c(lines, "\\end{figure}")

  result <- paste(lines, collapse = "\n")

  if (cat) {
    cat(result, "\n")
    invisible(result)
  } else {
    result
  }
}

#' Generate LaTeX for referencing a table
#'
#' @description Generate cross-reference commands for t2f tables.
#'
#' @param label The label to reference.
#' @param type Reference type: "ref", "autoref", "pageref", "nameref".
#' @param cat Logical. If TRUE (default), prints via cat().
#'
#' @return LaTeX code (invisibly if cat=TRUE).
#'
#' @examples
#' \dontrun{
#' t2f_ref("fig:results")           # \ref{fig:results}
#' t2f_ref("fig:results", "autoref") # \autoref{fig:results}
#' }
#'
#' @export
t2f_ref <- function(label, type = c("ref", "autoref", "pageref", "nameref"),
                    cat = TRUE) {
  type <- match.arg(type)

  result <- sprintf("\\%s{%s}", type, label)

  if (cat) {
    cat(result)
    invisible(result)
  } else {
    result
  }
}

# Helper Functions ----

#' Resolve PDF path for inclusion
#' @param path Input path (may or may not have _cropped.pdf)
#' @return Resolved path with _cropped.pdf
#' @keywords internal
resolve_pdf_path <- function(path) {
  # Remove .pdf extension if present
  path <- sub("\\.pdf$", "", path)

  # Add _cropped if not already there
 if (!grepl("_cropped$", path)) {
    path <- paste0(path, "_cropped")
  }

  # Add .pdf extension
  paste0(path, ".pdf")
}
