#' knitr Engine Integration
#'
#' @description Custom knitr engine for embedding t2f tables directly in
#'   R Markdown documents.
#'
#' @name knitr-engine
NULL

#' t2f knitr engine
#'
#' @description Process a t2f code chunk in R Markdown. The chunk should
#'   contain R code that evaluates to a data frame.
#'
#' @param options Chunk options passed by knitr.
#'
#' @return Engine output for knitr.
#'
#' @details
#' Supported chunk options (prefix with `t2f.`):
#'
#' - `t2f.scolor`: Row shading color
#' - `t2f.caption`: Table caption
#' - `t2f.label`: LaTeX label
#' - `t2f.theme`: Theme name
#' - `t2f.align`: Column alignment
#' - `t2f.crop_margin`: Crop margin
#' - `t2f.output_format`: Output format (pdf, png, svg)
#'
#' @examples
#' \dontrun{
#' # In R Markdown:
#' # ```{t2f, t2f.caption="My Table", t2f.theme="nejm"}
#' # mtcars[1:5, 1:4]
#' # ```
#' }
#'
#' @keywords internal
t2f_engine <- function(options) {
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop("knitr is required for the t2f engine.", call. = FALSE)
  }

  # Get the code from the chunk
 code <- paste(options$code, collapse = "\n")

  # Evaluate the code to get the data frame
  env <- knitr::knit_global()
  result <- tryCatch(
    eval(parse(text = code), envir = env),
    error = function(e) {
      return(list(error = e$message))
    }
  )

  # Handle evaluation errors
  if (is.list(result) && !is.null(result$error)) {
    return(knitr::engine_output(
      options,
      code,
      paste("Error evaluating chunk:", result$error)
    ))
  }

  # Ensure result is a data frame
  if (!is.data.frame(result)) {
    if (is.matrix(result)) {
      result <- as.data.frame(result)
    } else {
      return(knitr::engine_output(
        options,
        code,
        "Chunk must return a data frame or matrix."
      ))
    }
  }

  # Extract t2f-specific options
  t2f_opts <- list()

  if (!is.null(options$t2f.scolor)) t2f_opts$scolor <- options$t2f.scolor
  if (!is.null(options$t2f.caption)) t2f_opts$caption <- options$t2f.caption
  if (!is.null(options$t2f.label)) t2f_opts$label <- options$t2f.label
  if (!is.null(options$t2f.theme)) t2f_opts$theme <- options$t2f.theme
  if (!is.null(options$t2f.align)) t2f_opts$align <- options$t2f.align
  if (!is.null(options$t2f.crop_margin)) {
    t2f_opts$crop_margin <- options$t2f.crop_margin
  }
  if (!is.null(options$t2f.longtable)) t2f_opts$longtable <- options$t2f.longtable

  # Determine output format
  output_format <- options$t2f.output_format %||% "pdf"

  # Generate unique filename based on chunk label
  filename <- options$label %||% paste0("t2f_", format(Sys.time(), "%H%M%S"))
  filename <- gsub("[^a-zA-Z0-9_]", "_", filename)

  # Determine output directory
  fig_path <- knitr::opts_chunk$get("fig.path") %||% "figure/"
  sub_dir <- dirname(file.path(fig_path, filename))

  # Build t2f arguments
  t2f_args <- c(
    list(
      x = result,
      filename = filename,
      sub_dir = sub_dir,
      verbose = FALSE
    ),
    t2f_opts
  )

  # Generate the table
  output_path <- tryCatch(
    do.call(t2f, t2f_args),
    error = function(e) {
      return(list(error = e$message))
    }
  )

  # Handle t2f errors
  if (is.list(output_path) && !is.null(output_path$error)) {
    return(knitr::engine_output(
      options,
      code,
      paste("Error generating table:", output_path$error)
    ))
  }

  # Handle output format conversion if needed
  if (output_format != "pdf") {
    output_path <- tryCatch(
      handle_output_format(output_path, output_format),
      error = function(e) output_path
    )
  }

  # Generate markdown image reference
  if (file.exists(output_path)) {
    # Use relative path for output
    rel_path <- output_path

    # Generate appropriate output based on format
    if (output_format == "tex") {
      tex_content <- readLines(sub("\\.pdf$", ".tex", output_path))
      out <- paste(c("```latex", tex_content, "```"), collapse = "\n")
    } else {
      out <- sprintf("![%s](%s)", options$t2f.caption %||% "", rel_path)
    }

    knitr::engine_output(options, code, out)
  } else {
    knitr::engine_output(
      options,
      code,
      paste("Output file not found:", output_path)
    )
  }
}

#' Register the t2f knitr engine
#'
#' @description Register the t2f engine with knitr. This is called
#'   automatically when the package is loaded.
#'
#' @return Invisible NULL.
#'
#' @export
register_t2f_engine <- function() {
  if (requireNamespace("knitr", quietly = TRUE)) {
    knitr::knit_engines$set(t2f = t2f_engine)
  }
  invisible(NULL)
}
