#' Compile Typst source to an image file
#'
#' @description Escape hatch for users who want to post-process the
#'   Typst source between construction and compilation. Use in
#'   conjunction with \code{zzt2f(..., compile = FALSE)}.
#'
#' @param source A \code{zzt2f_source} object (returned by
#'   \code{zzt2f(..., compile = FALSE)}) or a character vector of
#'   Typst source lines.
#' @param filename Character. Base filename (no extension). If
#'   \code{source} carries a \code{filename} attribute, it is used
#'   when \code{filename} is NULL.
#' @param sub_dir Character. Output directory. Defaults to the
#'   attribute on \code{source} or \code{"figures"}.
#' @param format Character. "pdf", "png", or "svg".
#' @param dpi Integer. PNG resolution.
#' @param verbose Logical.
#'
#' @return Invisibly, the path to the compiled output file.
#'
#' @examples
#' \dontrun{
#' src <- zzt2f(mtcars[1:5, 1:3], filename = "demo", compile = FALSE)
#' src <- c("// user comment", src)
#' zzt2f_compile(src, filename = "demo")
#' }
#' @export
zzt2f_compile <- function(source,
                          filename = NULL,
                          sub_dir = NULL,
                          format = c("pdf", "png", "svg"),
                          dpi = 300L,
                          verbose = FALSE) {
  if (!command_exists("typst")) {
    stop(
      "Typst CLI not found on PATH. See check_typst_deps().",
      call. = FALSE
    )
  }
  format <- match.arg(format)

  if (inherits(source, "zzt2f_source")) {
    if (is.null(filename)) filename <- attr(source, "filename")
    if (is.null(sub_dir))  sub_dir  <- attr(source, "sub_dir")
    lines <- unclass(source)
  } else if (is.character(source)) {
    lines <- source
  } else {
    stop(
      "`source` must be a zzt2f_source object or character vector.",
      call. = FALSE
    )
  }

  if (is.null(filename)) {
    stop("`filename` must be provided.", call. = FALSE)
  }
  if (is.null(sub_dir)) sub_dir <- "figures"

  if (!dir.exists(sub_dir)) {
    dir.create(sub_dir, recursive = TRUE)
  }

  typ_file <- file.path(sub_dir, paste0(filename, ".typ"))
  output_file <- file.path(sub_dir, paste0(filename, ".", format))
  writeLines(lines, typ_file)

  typst_args <- c("compile", typ_file, output_file)
  if (format == "png") {
    typst_args <- c(typst_args, "--ppi", as.character(as.integer(dpi)))
  }

  result <- system2("typst", typst_args, stdout = TRUE, stderr = TRUE)
  exit_code <- attr(result, "status") %||% 0L

  if (exit_code != 0L) {
    stop(
      "Typst compilation failed (exit code ", exit_code, ").\n",
      paste(result, collapse = "\n"),
      call. = FALSE
    )
  }
  if (!file.exists(output_file)) {
    stop(
      "Typst compilation produced no output file: ", output_file,
      call. = FALSE
    )
  }
  if (isTRUE(verbose)) {
    message("Output saved to: ", output_file)
  }
  invisible(output_file)
}
