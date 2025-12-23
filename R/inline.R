#' Inline Table for R Markdown Documents
#'
#' @description Generate a table and include it inline in an R Markdown
#'   document. Automatically handles PDF vs HTML output and provides
#'   control over size and alignment.
#'
#' @param x An object to convert to a table (data.frame, lm, glm, etc.).
#' @param width Figure width. Use LaTeX units for PDF ("2in", "5cm",
#'   "0.5\\textwidth") or CSS/pixels for HTML.
#' @param height Optional figure height. If NULL, aspect ratio is preserved.
#' @param align Alignment: "left", "center", or "right".
#' @param filename Optional filename. If NULL, a temp file is used.
#' @param format Output format: "auto" (detect from knitr), "pdf", or "png".
#' @param dpi Resolution for PNG output. Default 150.
#' @param sub_dir Directory for output files. If NULL (default), uses tempdir().
#' @param caption Table caption. Defaults to NULL (no caption).
#' @param caption_short Short caption for List of Tables. Defaults to NULL.
#' @param label LaTeX label for cross-referencing (e.g., "tab:model").
#'   Defaults to NULL (no label).
#' @param ... Additional arguments passed to t2f().
#'
#' @return For knitr, returns the result of knitr::include_graphics().
#'   When called outside knitr, returns the file path invisibly.
#'
#' @details
#' This function streamlines the workflow for including tables in R Markdown:
#'
#' 1. Generates the table PDF via t2f()
#' 2. For HTML output, converts to PNG
#' 3. Returns appropriate include for knitr
#'
#' The alignment is handled via:
#' - PDF output: LaTeX commands (flushleft, center, flushright)
#' - HTML output: knitr chunk options or CSS
#'
#' @examples
#' \dontrun{
#' # In R Markdown chunk:
#' model <- lm(mpg ~ cyl + hp, data = mtcars)
#' t2f_inline(model, width = "2in", align = "left")
#'
#' # With caption and label for cross-referencing:
#' t2f_inline(model,
#'            width = "3in",
#'            caption = "Linear model coefficients",
#'            label = "tab:model")
#'
#' # With explicit format:
#' t2f_inline(mtcars[1:5,], width = "4in", format = "png", dpi = 300)
#' }
#'
#' @export
t2f_inline <- function(x,
                       width = NULL,
                       height = NULL,
                       align = c("center", "left", "right"),
                       filename = NULL,
                       format = c("auto", "pdf", "png"),
                       dpi = 150,
                       sub_dir = NULL,
                       caption = NULL,
                       caption_short = NULL,
                       label = NULL,
                       ...) {
  align <- match.arg(align)
  format <- match.arg(format)

  # Detect output format if auto
  if (format == "auto") {
    if (requireNamespace("knitr", quietly = TRUE)) {
      format <- if (knitr::is_latex_output()) "pdf" else "png"
    } else {
      format <- "pdf"
    }
  }

  # Generate temp filename if not provided
  if (is.null(filename)) {
    filename <- paste0("t2f_inline_", format(Sys.time(), "%Y%m%d%H%M%S"),
                       "_", sample(1000:9999, 1))
  }

  # Use tempdir if sub_dir not specified
  if (is.null(sub_dir)) {
    sub_dir <- tempdir()
  }


  # Generate the PDF
  pdf_path <- t2f(x,
                  filename = filename,
                  sub_dir = sub_dir,
                  caption = caption,
                  caption_short = caption_short,
                  label = label,
                  ...)

  # For PNG output, convert
  if (format == "png") {
    png_path <- sub("\\.pdf$", ".png", pdf_path)
    convert_pdf_to_png(pdf_path, png_path, dpi = dpi)
    output_path <- png_path
  } else {
    output_path <- pdf_path
  }

  # If in knitr context, use include_graphics
  if (requireNamespace("knitr", quietly = TRUE) &&
      isTRUE(getOption("knitr.in.progress"))) {
    # Build include_graphics call
    out_width <- width
    out_height <- height

    # For PDF/LaTeX with alignment, wrap in environment
    if (format == "pdf" && align != "center") {
      # Output raw LaTeX for alignment
      align_env <- switch(align,
        "left" = c("\\begin{flushleft}", "\\end{flushleft}"),
        "right" = c("\\begin{flushright}", "\\end{flushright}")
      )

      width_cmd <- if (!is.null(width)) {
        paste0("[width=", width, "]")
      } else {
        ""
      }

      latex_code <- paste0(
        align_env[1], "\n",
        "\\includegraphics", width_cmd, "{", output_path, "}\n",
        align_env[2]
      )

      return(knitr::asis_output(latex_code))
    }

    # Standard include_graphics
    knitr::include_graphics(output_path)
  } else {
    # Not in knitr - just return the path
    message("Table generated: ", output_path)
    invisible(output_path)
  }
}

#' Quick coefficient table from model
#'
#' @description Convenience function to generate an inline coefficient
#'   table from a regression model with sensible defaults.
#'
#' @param model A fitted model object (lm, glm, coxph, etc.).
#' @param width Figure width. Default "3in".
#' @param align Alignment. Default "left".
#' @param digits Number of decimal places.
#' @param stars Show significance stars. Default TRUE.
#' @param theme Table theme. Default "minimal".
#' @param caption Optional table caption.
#' @param caption_short Short caption for List of Tables. Defaults to NULL.
#' @param label LaTeX label for cross-referencing. Defaults to NULL.
#' @param ... Additional arguments passed to t2f_inline().
#'
#' @return Same as t2f_inline().
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
#' t2f_coef(model)
#' }
#'
#' @export
t2f_coef <- function(model,
                     width = "3in",
                     align = "left",
                     digits = 3,
                     stars = TRUE,
                     theme = "minimal",
                     caption = NULL,
                     caption_short = NULL,
                     label = NULL,
                     ...) {
  t2f_inline(
    model,
    width = width,
    align = align,
    digits = digits,
    theme = theme,
    caption = caption,
    caption_short = caption_short,
    label = label,
    ...
  )
}
