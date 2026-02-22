#' Typst Backend for Table-to-Figure Conversion
#'
#' @description Convert data frames to publication-quality table images using
#'   tinytable and the Typst CLI. This provides a lightweight alternative to
#'   the LaTeX-based \code{\link{t2f}} pipeline, requiring only Typst (~40 MB
#'   binary) instead of a full LaTeX distribution.
#'
#' @name zzt2f
NULL

#' Convert a data frame to a table image via Typst
#'
#' @description Generates PDF, PNG, or SVG table images from data frames using
#'   the tinytable package and Typst CLI. Typst auto-sizes pages, so no
#'   cropping step is needed.
#'
#' @param x A data frame, matrix, or table object to render.
#' @param filename Character string. Base name for output file (without
#'   extension). Defaults to the deparsed name of \code{x}.
#' @param sub_dir Character string. Output directory. Defaults to
#'   "analysis/figures" in zzcollab projects, "figures" otherwise.
#' @param verbose Logical. Print progress messages. Default FALSE.
#' @param caption Character string or NULL. Table caption.
#' @param align Character vector or NULL. Column alignments ("l", "c", "r").
#'   Length 1 (applied to all columns) or one per column. NULL for auto-detect.
#' @param theme Character string, t2f_theme object, or NULL. Theme name
#'   (e.g., "nejm", "apa") or custom theme. Uses the existing t2f theme system.
#' @param scolor Character string or NULL. LaTeX color spec for row striping,
#'   translated to hex. Overrides theme setting.
#' @param footnote A t2f_footnote object or NULL. Table footnotes.
#' @param header_above A t2f_header object, list of t2f_header objects, or
#'   NULL. Spanning column headers.
#' @param format Character string. Output format: "pdf" (default), "png",
#'   or "svg".
#' @param dpi Integer. PNG resolution in dots per inch. Default 300.
#' @param ... Additional arguments passed to \code{tinytable::tt()}.
#'
#' @return Invisibly returns the path to the output file.
#'
#' @details
#' The pipeline:
#' \enumerate{
#'   \item Validate inputs and coerce to data.frame
#'   \item Resolve theme via existing t2f theme system, translate to Typst
#'   \item Build tinytable object with \code{tt()} / \code{style_tt()} /
#'     \code{group_tt()}
#'   \item Save to \code{.typ} via \code{save_tt()}
#'   \item Compile via \code{typst compile}
#' }
#'
#' Parameters from \code{t2f()} that are dropped (LaTeX-specific):
#' \code{extra_packages}, \code{document_class}, \code{caption_short},
#' \code{label}, \code{longtable}, \code{crop}, \code{crop_margin},
#' \code{collapse_rows}.
#'
#' @examples
#' \dontrun{
#' zzt2f(mtcars[1:6, 1:4], filename = "mtcars_sample")
#' zzt2f(mtcars[1:6, 1:4], filename = "nejm_table",
#'       theme = "nejm", format = "png")
#' }
#'
#' @export
zzt2f <- function(x,
                  filename = NULL,
                  sub_dir = get_default_figures_dir(),
                  verbose = FALSE,
                  caption = NULL,
                  align = NULL,
                  theme = NULL,
                  scolor = NULL,
                  footnote = NULL,
                  header_above = NULL,
                  format = c("pdf", "png", "svg"),
                  dpi = 300L,
                  ...) {
  if (is.null(filename)) filename <- deparse(substitute(x))
  format <- match.arg(format)
  zzt2f_internal(
    x = x,
    filename = filename,
    sub_dir = sub_dir,
    verbose = verbose,
    caption = caption,
    align = align,
    theme = theme,
    scolor = scolor,
    footnote = footnote,
    header_above = header_above,
    format = format,
    dpi = dpi,
    ...
  )
}

#' Internal Typst pipeline
#'
#' @param x Input object.
#' @param filename Base filename.
#' @param sub_dir Output directory.
#' @param verbose Logical.
#' @param caption Caption string or NULL.
#' @param align Alignment spec or NULL.
#' @param theme Theme spec or NULL.
#' @param scolor Color override or NULL.
#' @param footnote t2f_footnote or NULL.
#' @param header_above t2f_header or NULL.
#' @param format Output format.
#' @param dpi PNG resolution.
#' @param ... Passed to tt().
#' @return Output file path (invisible).
#' @keywords internal
zzt2f_internal <- function(x,
                           filename,
                           sub_dir,
                           verbose,
                           caption,
                           align,
                           theme,
                           scolor,
                           footnote,
                           header_above,
                           format,
                           dpi,
                           ...) {
  require_package("tinytable", "the zzt2f() Typst backend")
  if (!command_exists("typst")) {
    stop(
      "Typst CLI not found on PATH.\n",
      "Install from: https://github.com/typst/typst/releases\n",
      "  macOS:  brew install typst\n",
      "  Linux:  curl -fsSL https://typst.community | sh",
      call. = FALSE
    )
  }

  # --- Validate inputs ---
  assert_single_logical(verbose, "verbose")
  assert_string_or_null(caption, "caption")
  assert_single_string(sub_dir, "sub_dir")
  if (sub_dir == "") stop("Directory name cannot be empty.", call. = FALSE)

  if (!is.null(footnote) && !inherits(footnote, "t2f_footnote")) {
    stop("`footnote` must be a t2f_footnote object or NULL.", call. = FALSE)
  }
  if (!is.null(header_above) &&
      !inherits(header_above, "t2f_header") &&
      !is.list(header_above)) {
    stop(
      "`header_above` must be a t2f_header object, list, or NULL.",
      call. = FALSE
    )
  }
  if (!is.numeric(dpi) || length(dpi) != 1 || dpi < 1) {
    stop("`dpi` must be a positive integer.", call. = FALSE)
  }

  # --- Coerce input ---
  if (is.matrix(x) || inherits(x, "table")) {
    x <- as.data.frame(x)
  }
  if (!is.data.frame(x)) {
    stop("`x` must be a data.frame, matrix, or table.", call. = FALSE)
  }
  if (nrow(x) == 0) stop("`x` must not be empty.", call. = FALSE)

  # --- Validate alignment ---
  if (!is.null(align)) {
    if (!is.character(align)) {
      stop("`align` must be a character vector or NULL.", call. = FALSE)
    }
    valid_aligns <- c("l", "c", "r")
    if (!all(align %in% valid_aligns)) {
      stop("`align` must contain only 'l', 'c', or 'r'.", call. = FALSE)
    }
    if (length(align) != 1 && length(align) != ncol(x)) {
      stop(
        "`align` must be length 1 or match number of columns.",
        call. = FALSE
      )
    }
  }

  # --- Resolve theme ---
  log_message("Resolving theme...", verbose)
  ts <- resolve_typst_theme(theme, scolor = scolor)

  # --- Prepare filename and directory ---
  filename <- sanitize_filename(filename)

  if (!dir.exists(sub_dir)) {
    tryCatch(
      dir.create(sub_dir, recursive = TRUE),
      error = function(e) {
        stop(
          "Cannot create directory: ", sub_dir, "\n",
          "Error: ", e$message,
          call. = FALSE
        )
      }
    )
  }
  if (file.access(sub_dir, mode = 2) != 0) {
    stop("Directory is not writable: ", sub_dir, call. = FALSE)
  }

  # --- Escape Typst-special characters in cell data ---
  x[] <- lapply(x, function(col) {
    if (is.character(col)) {
      vapply(col, escape_typst_content, character(1), USE.NAMES = FALSE)
    } else if (is.factor(col)) {
      factor(
        vapply(
          as.character(col), escape_typst_content,
          character(1), USE.NAMES = FALSE
        ),
        levels = vapply(
          levels(col), escape_typst_content,
          character(1), USE.NAMES = FALSE
        )
      )
    } else {
      col
    }
  })

  # --- Build tinytable ---
  log_message("Building tinytable object...", verbose)

  notes <- translate_footnote(footnote)

  tt_args <- list(x = x)
  if (!is.null(caption)) tt_args$caption <- caption
  if (!is.null(notes)) tt_args$notes <- notes
  tt_args <- c(tt_args, list(...))
  tbl <- do.call(tinytable::tt, tt_args)

  # --- Apply alignment ---
  # tinytable expects align as a single collapsed string (e.g., "llrr")
  if (!is.null(align)) {
    if (length(align) == 1) align <- rep(align, ncol(x))
    align_str <- paste0(align, collapse = "")
  } else {
    align_str <- paste0(auto_align(x), collapse = "")
  }
  tbl <- tinytable::style_tt(tbl, align = align_str)

  # --- Apply theme styling ---
  if (!is.null(ts$stripe_color)) {
    odd_rows <- seq(1, nrow(x), by = 2)
    tbl <- tinytable::style_tt(
      tbl, i = odd_rows, background = ts$stripe_color
    )
  }

  if (isTRUE(ts$header_bold)) {
    tbl <- tinytable::style_tt(tbl, i = 0, bold = TRUE)
  }

  if (!is.null(ts$font_size)) {
    fontsize_em <- ts$font_size / 10
    tbl <- tinytable::style_tt(
      tbl, j = seq_len(ncol(x)), fontsize = fontsize_em
    )
  }

  # --- Apply spanning headers ---
  j_spec <- translate_header_above(header_above)
  if (!is.null(j_spec) && length(j_spec) > 0) {
    tbl <- tinytable::group_tt(tbl, j = j_spec)
  }

  # --- Save and compile ---
  typ_file <- file.path(sub_dir, paste0(filename, ".typ"))
  ext <- format
  output_file <- file.path(sub_dir, paste0(filename, ".", ext))

  log_message("Saving Typst source...", verbose)
  tinytable::save_tt(tbl, output = typ_file, overwrite = TRUE)

  typ_content <- readLines(typ_file)
  page_directive <- "#set page(width: auto, height: auto, margin: (x: 5pt, y: 5pt))"
  writeLines(c(page_directive, typ_content), typ_file)

  log_message(paste0("Compiling to ", toupper(format), "..."), verbose)

  typst_args <- c("compile", typ_file, output_file)
  if (format == "png") {
    typst_args <- c(typst_args, "--ppi", as.character(as.integer(dpi)))
  }

  result <- system2("typst", typst_args, stdout = TRUE, stderr = TRUE)
  exit_code <- attr(result, "status") %||% 0L

  if (exit_code != 0) {
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

  log_message(paste("Output saved to:", output_file), verbose)
  invisible(output_file)
}

#' Check Typst dependencies for zzt2f
#'
#' @description Checks that tinytable and the Typst CLI are available,
#'   providing installation guidance if not.
#'
#' @return A list with availability status for each component (invisibly).
#'
#' @examples
#' \dontrun{
#' check_typst_deps()
#' }
#'
#' @export
check_typst_deps <- function() {
  message("Checking Typst dependencies for zzt2f()...\n")

  has_tinytable <- requireNamespace("tinytable", quietly = TRUE)
  has_typst <- command_exists("typst")

  message(
    "tinytable: ",
    if (has_tinytable) "OK" else "NOT FOUND"
  )
  message(
    "typst CLI: ",
    if (has_typst) "OK" else "NOT FOUND"
  )

  if (has_typst) {
    version_out <- tryCatch(
      system2("typst", "--version", stdout = TRUE, stderr = TRUE),
      error = function(e) NULL
    )
    if (!is.null(version_out) && length(version_out) > 0) {
      message("  Version: ", version_out[1])
    }
  }

  if (!has_tinytable) {
    message(
      "\nInstall tinytable with:\n",
      "  install.packages('tinytable')"
    )
  }

  if (!has_typst) {
    message(
      "\nInstall Typst CLI:\n",
      "  macOS:   brew install typst\n",
      "  Linux:   curl -fsSL https://typst.community | sh\n",
      "  Windows: winget install --id Typst.Typst\n",
      "  Or download from: ",
      "https://github.com/typst/typst/releases"
    )
  }

  ready <- has_tinytable && has_typst
  if (ready) {
    message("\nAll dependencies available. zzt2f() is ready to use.")
  } else {
    message("\nSome dependencies are missing. See instructions above.")
  }

  invisible(list(
    tinytable = has_tinytable,
    typst = has_typst,
    ready = ready
  ))
}
