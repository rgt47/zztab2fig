#' Output Format Handlers
#'
#' @description Functions for converting PDF tables to alternative output
#'   formats including PNG, SVG, and TEX-only output.
#'
#' @name output-formats
NULL


#' Convert PDF to PNG
#'
#' @description Convert a PDF file to PNG format using ImageMagick.
#'
#' @param pdf_path Path to the input PDF file.
#' @param png_path Path for the output PNG file. If NULL, uses the same path
#'   with .png extension.
#' @param dpi Resolution in dots per inch. Defaults to 300.
#' @param background Background color. Defaults to "white".
#'
#' @return Invisibly returns the path to the PNG file.
#'
#' @export
convert_pdf_to_png <- function(pdf_path, png_path = NULL, dpi = 300,
                               background = "white") {
  if (!file.exists(pdf_path)) {
    stop("PDF file not found: ", pdf_path, call. = FALSE)
  }

  if (is.null(png_path)) {
    png_path <- sub("\\.pdf$", ".png", pdf_path, ignore.case = TRUE)
  }

  # Check for ImageMagick
  if (!command_exists("convert")) {
    stop("ImageMagick 'convert' command not found. ",
      "Please install ImageMagick to use PNG output.",
      call. = FALSE
    )
  }

  cmd <- paste(
    "convert",
    "-density", dpi,
    "-background", shQuote(background),
    "-flatten",
    shQuote(pdf_path),
    shQuote(png_path)
  )

  result <- system(cmd)

  if (result != 0) {
    stop("PNG conversion failed with exit code: ", result, call. = FALSE)
  }

  if (!file.exists(png_path)) {
    stop("PNG conversion failed: output file was not created.", call. = FALSE)
  }

  invisible(png_path)
}

#' Convert PDF to SVG
#'
#' @description Convert a PDF file to SVG format using pdf2svg or Inkscape.
#'
#' @param pdf_path Path to the input PDF file.
#' @param svg_path Path for the output SVG file. If NULL, uses the same path
#'   with .svg extension.
#'
#' @return Invisibly returns the path to the SVG file.
#'
#' @export
convert_pdf_to_svg <- function(pdf_path, svg_path = NULL) {
  if (!file.exists(pdf_path)) {
    stop("PDF file not found: ", pdf_path, call. = FALSE)
  }

  if (is.null(svg_path)) {
    svg_path <- sub("\\.pdf$", ".svg", pdf_path, ignore.case = TRUE)
  }

  # Try pdf2svg first, then inkscape
  if (command_exists("pdf2svg")) {
    cmd <- paste("pdf2svg", shQuote(pdf_path), shQuote(svg_path))
  } else if (command_exists("inkscape")) {
    cmd <- paste(
      "inkscape",
      "--export-filename", shQuote(svg_path),
      shQuote(pdf_path)
    )
  } else {
    stop("Neither 'pdf2svg' nor 'inkscape' found. ",
      "Please install one of these tools to use SVG output.",
      call. = FALSE
    )
  }

  result <- system(cmd)

  if (result != 0) {
    stop("SVG conversion failed with exit code: ", result, call. = FALSE)
  }

  if (!file.exists(svg_path)) {
    stop("SVG conversion failed: output file was not created.", call. = FALSE)
  }

  invisible(svg_path)
}

#' Generate output in specified format
#'
#' @description Internal function to handle output format conversion after
#'   PDF generation.
#'
#' @param pdf_path Path to the generated PDF file.
#' @param output_format Target format: "pdf", "png", "svg", or "tex".
#' @param dpi Resolution for PNG output.
#' @param tex_path Path to the TEX file (for "tex" format).
#'
#' @return Path to the final output file.
#' @keywords internal
handle_output_format <- function(pdf_path, output_format = "pdf",
                                 dpi = 300, tex_path = NULL) {
  output_format <- tolower(output_format)

  switch(output_format,
    "pdf" = pdf_path,
    "png" = convert_pdf_to_png(pdf_path, dpi = dpi),
    "svg" = convert_pdf_to_svg(pdf_path),
    "tex" = {
      if (is.null(tex_path)) {
        stop("TEX path required for 'tex' output format.", call. = FALSE)
      }
      tex_path
    },
    stop("Unknown output format: ", output_format,
      ". Supported formats: pdf, png, svg, tex",
      call. = FALSE
    )
  )
}

#' List available output formats
#'
#' @description Check which output formats are available based on installed
#'   system tools.
#'
#' @return Named logical vector indicating availability of each format.
#'
#' @examples
#' \dontrun{
#' t2f_output_formats()
#' }
#'
#' @export
t2f_output_formats <- function() {
  formats <- c(
    pdf = TRUE,
    tex = TRUE,
    png = command_exists("convert"),
    svg = command_exists("pdf2svg") || command_exists("inkscape")
  )

  if (!formats["png"]) {
    message("PNG output requires ImageMagick. Install with:",
      "\n  macOS: brew install imagemagick",
      "\n  Ubuntu: sudo apt-get install imagemagick"
    )
  }

  if (!formats["svg"]) {
    message("SVG output requires pdf2svg or Inkscape. Install with:",
      "\n  macOS: brew install pdf2svg",
      "\n  Ubuntu: sudo apt-get install pdf2svg"
    )
  }

  formats
}
