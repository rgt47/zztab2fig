#' Inline Rendering and knitr Engine for the Typst Backend
#'
#' @name zzt2f-inline
NULL

#' Render a table inline for R Markdown / Quarto (Typst backend)
#'
#' @description Generates a PDF or PNG via \code{zzt2f()} and, when
#'   running inside a knitr document, emits the appropriate markdown
#'   image reference so the image is embedded.
#'
#' @param x A data frame, matrix, or table.
#' @param width Character or NULL. Passed through to later include
#'   helpers; \code{zzt2f()} itself does not consume it.
#' @param align One of \code{"center"}, \code{"left"}, \code{"right"}.
#' @param filename Output base filename; generated if NULL.
#' @param format One of \code{"auto"}, \code{"pdf"}, \code{"png"}.
#'   \code{"auto"} picks \code{"pdf"} for LaTeX knitr output and
#'   \code{"png"} otherwise.
#' @param dpi PNG resolution.
#' @param sub_dir Output directory; \code{tempdir()} if NULL.
#' @param caption Character or NULL. Passed to \code{zzt2f()}.
#' @param label Character or NULL. Typst label (no angle brackets);
#'   appended to the emitted image reference when running under
#'   knitr.
#' @param ... Additional arguments forwarded to \code{zzt2f()}.
#' @return Character path to the rendered file (invisible when used
#'   inside knitr).
#' @examples
#' \dontrun{
#' zzt2f_inline(mtcars[1:5, 1:3], caption = "Demo")
#' }
#' @export
zzt2f_inline <- function(x,
                         width = NULL,
                         align = c("center", "left", "right"),
                         filename = NULL,
                         format = c("auto", "pdf", "png"),
                         dpi = 150L,
                         sub_dir = NULL,
                         caption = NULL,
                         label = NULL,
                         ...) {
  align <- match.arg(align)
  format <- match.arg(format)

  if (identical(format, "auto")) {
    format <- if (requireNamespace("knitr", quietly = TRUE) &&
                  isTRUE(knitr::is_latex_output())) {
      "pdf"
    } else {
      "png"
    }
  }

  if (is.null(filename)) {
    filename <- paste0(
      "zzt2f_inline_",
      format(Sys.time(), "%Y%m%d%H%M%S"),
      "_", sample.int(9000, 1L) + 999L
    )
  }
  if (is.null(sub_dir)) sub_dir <- tempdir()

  output_path <- zzt2f(
    x,
    filename = filename,
    sub_dir = sub_dir,
    format = format,
    dpi = dpi,
    caption = caption,
    ...
  )

  in_knitr <- requireNamespace("knitr", quietly = TRUE) &&
    isTRUE(getOption("knitr.in.progress"))

  if (in_knitr) {
    ref <- sprintf("![%s](%s)", caption %||% "", output_path)
    if (!is.null(label)) {
      ref <- paste0(ref, "{#", label, "}")
    }
    knitr::raw_output(ref)
    return(invisible(output_path))
  }
  output_path
}

#' knitr engine for Typst-rendered tables
#'
#' @description Used by \code{register_zzt2f_engine()} to handle
#'   chunks of the form \code{```{zzt2f, zzt2f.caption="...", ...}}.
#'   Chunk body should evaluate to a data frame.
#'
#' @param options knitr chunk options.
#' @return Engine output.
#' @keywords internal
zzt2f_engine <- function(options) {
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop("knitr is required for the zzt2f engine.", call. = FALSE)
  }
  code <- paste(options$code, collapse = "\n")
  env <- knitr::knit_global()
  result <- tryCatch(
    eval(parse(text = code), envir = env),
    error = function(e) list(error = e$message)
  )
  if (is.list(result) && !is.null(result$error)) {
    return(knitr::engine_output(
      options, code,
      paste("Error evaluating chunk:", result$error)
    ))
  }
  if (!is.data.frame(result)) {
    if (is.matrix(result)) {
      result <- as.data.frame(result)
    } else {
      return(knitr::engine_output(
        options, code,
        "Chunk must return a data frame or matrix."
      ))
    }
  }

  zzt_opts <- list()
  if (!is.null(options$zzt2f.caption)) {
    zzt_opts$caption <- options$zzt2f.caption
  }
  if (!is.null(options$zzt2f.theme)) {
    zzt_opts$theme <- options$zzt2f.theme
  }
  if (!is.null(options$zzt2f.align)) {
    zzt_opts$align <- options$zzt2f.align
  }
  if (!is.null(options$zzt2f.scolor)) {
    zzt_opts$scolor <- options$zzt2f.scolor
  }
  output_format <- options$zzt2f.output_format %||% "pdf"

  filename <- options$label %||%
    paste0("zzt2f_", format(Sys.time(), "%H%M%S"))
  filename <- gsub("[^a-zA-Z0-9_]", "_", filename)
  fig_path <- knitr::opts_chunk$get("fig.path") %||% "figure/"
  sub_dir <- dirname(file.path(fig_path, filename))

  args <- c(
    list(
      x = result, filename = filename, sub_dir = sub_dir,
      verbose = FALSE, format = output_format
    ),
    zzt_opts
  )
  output_path <- tryCatch(
    do.call(zzt2f, args),
    error = function(e) list(error = e$message)
  )
  if (is.list(output_path) && !is.null(output_path$error)) {
    return(knitr::engine_output(
      options, code,
      paste("Error generating table:", output_path$error)
    ))
  }
  if (!file.exists(output_path)) {
    return(knitr::engine_output(
      options, code,
      paste("Output file not found:", output_path)
    ))
  }
  out <- sprintf(
    "![%s](%s)", options$zzt2f.caption %||% "", output_path
  )
  knitr::engine_output(options, code, out)
}

#' Register the zzt2f knitr engine
#'
#' @description Registers the \code{zzt2f} chunk engine with knitr so
#'   that \code{```{zzt2f, ...}``` blocks render via the Typst
#'   backend. Normally called automatically in \code{.onLoad()}.
#'
#' @return NULL (invisible).
#' @export
register_zzt2f_engine <- function() {
  if (requireNamespace("knitr", quietly = TRUE)) {
    knitr::knit_engines$set(zzt2f = zzt2f_engine)
  }
  invisible(NULL)
}
