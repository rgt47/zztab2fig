#' Inline Table for R Markdown Documents
#'
#' @description Generate a table and include it inline in an R Markdown
#'   document. Automatically handles PDF vs HTML output and provides
#'   control over size, alignment, captioning, and visual styling without
#'   using floats.
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
#' @param caption Table caption. Uses \\captionof for non-float placement.
#'   Defaults to NULL (no caption).
#' @param caption_short Short caption for List of Tables. Defaults to NULL.
#' @param label LaTeX label for cross-referencing (e.g., "tab:model").
#'   Defaults to NULL (no label).
#' @param caption_position Position of caption: "above" (default, standard for
#'   tables) or "below".
#' @param frame Logical. If TRUE, draw a border around the table. Default FALSE.
#' @param frame_color Color for the frame border. Uses xcolor syntax (e.g.,
#'   "black", "blue!50"). Default "black".
#' @param frame_width Line width for the frame. Default "0.4pt".
#' @param background Background color for the table container. Uses xcolor
#'   syntax (e.g., "gray!10", "yellow!5"). Default NULL (no background).
#' @param inner_sep Padding between content and frame. Default "2pt".
#' @param ... Additional arguments passed to t2f().
#'
#' @return For knitr, returns the result of knitr::asis_output() with LaTeX
#'   code. When called outside knitr, returns the file path invisibly.
#'
#' @details
#' This function streamlines the workflow for including tables in R Markdown:
#'
#' 1. Generates the table PDF via t2f() (without embedded caption)
#' 2. For HTML output, converts to PNG
#' 3. Wraps in LaTeX with alignment and caption using \\captionof
#'
#' The table is placed exactly where the code chunk appears (no float).
#' Captions use `\\captionof\{table\}\{...\}` which requires the LaTeX `caption`
#' package. Add to your R Markdown YAML header:
#'
#' ```
#' header-includes:
#'   - \\usepackage{caption}
#' ```
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
#' # Caption below the table:
#' t2f_inline(model,
#'            width = "3in",
#'            caption = "Results",
#'            caption_position = "below")
#'
#' # With frame border:
#' t2f_inline(model,
#'            width = "3in",
#'            frame = TRUE,
#'            frame_color = "gray",
#'            frame_width = "0.5pt")
#'
#' # With background color:
#' t2f_inline(model,
#'            width = "3in",
#'            background = "gray!5")
#'
#' # With both frame and background:
#' t2f_inline(model,
#'            width = "3in",
#'            frame = TRUE,
#'            frame_color = "blue!50",
#'            background = "blue!5",
#'            inner_sep = "4pt")
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
                       caption_position = c("above", "below"),
                       frame = FALSE,
                       frame_color = "black",
                       frame_width = "0.4pt",
                       background = NULL,
                       inner_sep = "2pt",
                       ...) {
  align <- match.arg(align)
  format <- match.arg(format)
  caption_position <- match.arg(caption_position)

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

  # Generate the PDF (without caption - we handle it at document level)
  pdf_path <- t2f(x, filename = filename, sub_dir = sub_dir, ...)

  # For PNG output, convert
  if (format == "png") {
    png_path <- sub("\\.pdf$", ".png", pdf_path)
    convert_pdf_to_png(pdf_path, png_path, dpi = dpi)
    output_path <- png_path
  } else {
    output_path <- pdf_path
  }

  # If in knitr context, generate appropriate output

  if (requireNamespace("knitr", quietly = TRUE) &&
      isTRUE(getOption("knitr.in.progress"))) {

    # For PDF/LaTeX output, generate raw LaTeX
    if (format == "pdf") {
      latex_code <- build_inline_latex(
        path = output_path,
        width = width,
        height = height,
        align = align,
        caption = caption,
        caption_short = caption_short,
        label = label,
        caption_position = caption_position,
        frame = frame,
        frame_color = frame_color,
        frame_width = frame_width,
        background = background,
        inner_sep = inner_sep
      )
      return(knitr::asis_output(latex_code))
    }

    # For HTML/PNG, use include_graphics
    knitr::include_graphics(output_path)
  } else {
    message("Table generated: ", output_path)
    invisible(output_path)
  }
}

#' Build LaTeX code for inline table
#'
#' @param path Path to the PDF file.
#' @param width Width specification.
#' @param height Height specification.
#' @param align Alignment (left, center, right).
#' @param caption Caption text.
#' @param caption_short Short caption for LoT.
#' @param label LaTeX label.
#' @param caption_position Above or below.
#' @param frame Whether to draw a frame border.
#' @param frame_color Color for frame border.
#' @param frame_width Line width for frame.
#' @param background Background color.
#' @param inner_sep Padding inside the box.
#'
#' @return Character string with LaTeX code.
#' @keywords internal
build_inline_latex <- function(path, width, height, align,
                               caption, caption_short, label,
                               caption_position,
                               frame = FALSE, frame_color = "black",
                               frame_width = "0.4pt", background = NULL,
                               inner_sep = "2pt") {
  # Alignment environment
  align_env <- switch(align,
    "left" = c("\\begin{flushleft}", "\\end{flushleft}"),
    "center" = c("\\begin{center}", "\\end{center}"),
    "right" = c("\\begin{flushright}", "\\end{flushright}")
  )

  # Build includegraphics options
  options <- c()
  if (!is.null(width)) options <- c(options, paste0("width=", width))
  if (!is.null(height)) options <- c(options, paste0("height=", height))
  options_str <- if (length(options) > 0) {
    paste0("[", paste(options, collapse = ", "), "]")
  } else {
    ""
  }

  # Build includegraphics command
  include_cmd <- paste0("\\includegraphics", options_str, "{", path, "}")

  # Wrap in box if frame or background specified
  has_frame <- isTRUE(frame)
  has_background <- !is.null(background)

  if (has_frame || has_background) {
    # Set fboxsep for inner padding
    box_setup <- paste0("\\setlength{\\fboxsep}{", inner_sep, "}")

    if (has_frame) {
      # Set fboxrule for frame width
      box_setup <- paste0(box_setup, "\\setlength{\\fboxrule}{", frame_width, "}")

      if (has_background) {
        # Both frame and background: use fcolorbox
        include_cmd <- paste0(
          "{", box_setup,
          "\\fcolorbox{", frame_color, "}{", background, "}{",
          include_cmd, "}}"
        )
      } else {
        # Frame only: use fbox with color
        include_cmd <- paste0(
          "{", box_setup,
          "\\fcolorbox{", frame_color, "}{white}{",
          include_cmd, "}}"
        )
      }
    } else {
      # Background only: use colorbox
      include_cmd <- paste0(
        "{", box_setup,
        "\\colorbox{", background, "}{",
        include_cmd, "}}"
      )
    }
  }

  # Build caption command if provided
  caption_cmd <- NULL
  if (!is.null(caption)) {
    # Handle short caption for List of Tables
    if (!is.null(caption_short)) {
      caption_cmd <- paste0("\\captionof{table}[", caption_short, "]{",
                            caption, "}")
    } else {
      caption_cmd <- paste0("\\captionof{table}{", caption, "}")
    }
    # Add label if provided
    if (!is.null(label)) {
      caption_cmd <- paste0(caption_cmd, "\\label{", label, "}")
    }
  } else if (!is.null(label)) {
    # Label without caption (unusual but possible)
    caption_cmd <- paste0("\\label{", label, "}")
  }

  # Assemble LaTeX code
  lines <- c(align_env[1])

  if (!is.null(caption_cmd) && caption_position == "above") {
    lines <- c(lines, caption_cmd)
  }

  lines <- c(lines, include_cmd)

  if (!is.null(caption_cmd) && caption_position == "below") {
    lines <- c(lines, caption_cmd)
  }

  lines <- c(lines, align_env[2])

  paste(lines, collapse = "\n")
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
#' @param caption_position Position of caption: "above" (default) or "below".
#' @param frame Logical. If TRUE, draw a border around the table. Default FALSE.
#' @param frame_color Color for the frame border. Default "black".
#' @param frame_width Line width for the frame. Default "0.4pt".
#' @param background Background color for the table container. Default NULL.
#' @param inner_sep Padding between content and frame. Default "2pt".
#' @param ... Additional arguments passed to t2f_inline().
#'
#' @return Same as t2f_inline().
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
#' t2f_coef(model)
#'
#' # With frame and background
#' t2f_coef(model, frame = TRUE, background = "gray!5")
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
                     caption_position = "above",
                     frame = FALSE,
                     frame_color = "black",
                     frame_width = "0.4pt",
                     background = NULL,
                     inner_sep = "2pt",
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
    caption_position = caption_position,
    frame = frame,
    frame_color = frame_color,
    frame_width = frame_width,
    background = background,
    inner_sep = inner_sep,
    ...
  )
}
