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
zzt2f <- function(x, ...) {
  UseMethod("zzt2f")
}

#' Default method for zzt2f (data frames)
#'
#' @param x A data frame, matrix, or table object to render.
#' @param filename Base name for output file.
#' @param sub_dir Output directory.
#' @param verbose Print progress messages.
#' @param caption Table caption.
#' @param align Column alignment.
#' @param theme Theme name or object.
#' @param scolor Row stripe color override.
#' @param footnote A t2f_footnote object.
#' @param header_above A t2f_header object.
#' @param format Output format: "pdf", "png", or "svg".
#' @param dpi PNG resolution.
#' @param ... Additional arguments passed to tinytable::tt().
#'
#' @return Invisibly returns the path to the output file.
#' @export
zzt2f.default <- function(x,
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
                          separator_row = NULL,
                          ...) {
  if (!is.data.frame(x) && !is.matrix(x) && !inherits(x, "table")) {
    stop("No zzt2f method for class '", class(x)[1],
      "'. Convert to data.frame first.",
      call. = FALSE
    )
  }
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
    separator_row = separator_row,
    ...
  )
}

#' @rdname zzt2f.default
#' @export
zzt2f.data.frame <- function(x, ...) {
  zzt2f.default(x, ...)
}

#' @rdname zzt2f.default
#' @export
zzt2f.matrix <- function(x, ...) {
  zzt2f.default(x, ...)
}

#' @rdname zzt2f.default
#' @export
zzt2f.table <- function(x, ...) {
  zzt2f.default(x, ...)
}

#' zzt2f method for linear models
#'
#' @param x An lm object.
#' @param digits Number of decimal places.
#' @param include Character vector of statistics to include.
#' @param conf.level Confidence level for confidence intervals.
#' @param ... Additional arguments passed to zzt2f.default.
#'
#' @return Invisibly returns the path to the output file.
#' @export
zzt2f.lm <- function(x,
                     digits = 3,
                     include = c("estimate", "std.error",
                                 "statistic", "p.value"),
                     conf.level = 0.95,
                     ...) {
  s <- summary(x)
  coef_df <- as.data.frame(s$coefficients)

  result <- data.frame(
    Term = rownames(coef_df),
    stringsAsFactors = FALSE
  )

  if ("estimate" %in% include) {
    result$Estimate <- round(coef_df[, "Estimate"], digits)
  }
  if ("std.error" %in% include) {
    result$`Std. Error` <- round(coef_df[, "Std. Error"], digits)
  }
  if ("statistic" %in% include) {
    result$`t value` <- round(coef_df[, "t value"], digits)
  }
  if ("p.value" %in% include) {
    result$`p value` <- format_pvalue(coef_df[, "Pr(>|t|)"], digits)
  }
  if ("conf.int" %in% include) {
    ci <- confint(x, level = conf.level)
    result$`CI Lower` <- round(ci[, 1], digits)
    result$`CI Upper` <- round(ci[, 2], digits)
  }

  rownames(result) <- NULL
  zzt2f.default(result, ...)
}

#' zzt2f method for generalized linear models
#'
#' @param x A glm object.
#' @param digits Number of decimal places.
#' @param include Character vector of statistics to include.
#' @param exponentiate Logical. Exponentiate coefficients.
#' @param conf.level Confidence level for confidence intervals.
#' @param ... Additional arguments passed to zzt2f.default.
#'
#' @return Invisibly returns the path to the output file.
#' @export
zzt2f.glm <- function(x,
                      digits = 3,
                      include = c("estimate", "std.error",
                                  "statistic", "p.value"),
                      exponentiate = FALSE,
                      conf.level = 0.95,
                      ...) {
  s <- summary(x)
  coef_df <- as.data.frame(s$coefficients)

  result <- data.frame(
    Term = rownames(coef_df),
    stringsAsFactors = FALSE
  )

  estimates <- coef_df[, "Estimate"]
  std_errors <- coef_df[, "Std. Error"]

  if (exponentiate) {
    estimates <- exp(estimates)
    std_errors <- estimates * std_errors
  }

  est_label <- if (exponentiate) "OR" else "Estimate"

  if ("estimate" %in% include) {
    result[[est_label]] <- round(estimates, digits)
  }
  if ("std.error" %in% include) {
    result$`Std. Error` <- round(std_errors, digits)
  }
  if ("statistic" %in% include) {
    stat_name <- colnames(coef_df)[3]
    result[[stat_name]] <- round(coef_df[, 3], digits)
  }
  if ("p.value" %in% include) {
    result$`p value` <- format_pvalue(coef_df[, 4], digits)
  }
  if ("conf.int" %in% include) {
    ci <- confint(x, level = conf.level)
    if (exponentiate) ci <- exp(ci)
    result$`CI Lower` <- round(ci[, 1], digits)
    result$`CI Upper` <- round(ci[, 2], digits)
  }

  rownames(result) <- NULL
  zzt2f.default(result, ...)
}

#' zzt2f method for ANOVA objects
#'
#' @param x An anova object.
#' @param digits Number of decimal places.
#' @param ... Additional arguments passed to zzt2f.default.
#'
#' @return Invisibly returns the path to the output file.
#' @export
zzt2f.anova <- function(x, digits = 3, ...) {
  df <- as.data.frame(x)
  df <- cbind(Source = rownames(df), df)
  rownames(df) <- NULL

  df <- round_numeric_cols(df, digits)

  pval_cols <- grep("Pr|p.value|P-value", names(df),
                    ignore.case = TRUE)
  for (col in pval_cols) {
    df[[col]] <- format_pvalue(df[[col]], digits)
  }

  zzt2f.default(df, ...)
}

#' zzt2f method for aov objects
#' @rdname zzt2f.anova
#' @export
zzt2f.aov <- function(x, digits = 3, ...) {
  zzt2f.anova(summary(x)[[1]], digits = digits, ...)
}

#' zzt2f method for hypothesis tests
#'
#' @param x An htest object.
#' @param digits Number of decimal places.
#' @param ... Additional arguments passed to zzt2f.default.
#'
#' @return Invisibly returns the path to the output file.
#' @export
zzt2f.htest <- function(x, digits = 3, ...) {
  result <- data.frame(
    Statistic = names(x$statistic),
    Value = round(x$statistic, digits),
    stringsAsFactors = FALSE
  )

  if (!is.null(x$parameter)) {
    result$df <- round(x$parameter, digits)
  }

  result$`p value` <- format_pvalue(x$p.value, digits)

  if (!is.null(x$conf.int)) {
    result$`CI Lower` <- round(x$conf.int[1], digits)
    result$`CI Upper` <- round(x$conf.int[2], digits)
  }

  if (!is.null(x$estimate)) {
    for (i in seq_along(x$estimate)) {
      result[[names(x$estimate)[i]]] <- round(x$estimate[i], digits)
    }
  }

  rownames(result) <- NULL
  zzt2f.default(result, ...)
}

#' Side-by-side regression comparison table (Typst backend)
#'
#' @param ... Named lm or glm objects to compare.
#' @param include Character vector of statistics to include.
#' @param stars Logical or numeric vector for significance thresholds.
#' @param digits Number of decimal places.
#' @param se_in_parens Show standard errors in parentheses.
#' @param filename Base name for output files.
#' @param sub_dir Output directory.
#' @param zzt2f_args List of additional arguments passed to zzt2f().
#'
#' @return Invisibly returns the path to the output file.
#'
#' @examples
#' \dontrun{
#' m1 <- lm(mpg ~ cyl, data = mtcars)
#' m2 <- lm(mpg ~ cyl + hp, data = mtcars)
#' m3 <- lm(mpg ~ cyl + hp + wt, data = mtcars)
#' zzt2f_regression(Model1 = m1, Model2 = m2, Model3 = m3)
#' }
#'
#' @export
zzt2f_regression <- function(...,
                             include = c("estimate", "std.error"),
                             stars = c(0.05, 0.01, 0.001),
                             digits = 3,
                             se_in_parens = TRUE,
                             filename = "regression_table",
                             sub_dir = get_default_figures_dir(),
                             format = c("pdf", "png", "svg"),
                             theme = NULL,
                             caption = NULL,
                             zzt2f_args = list()) {
  format <- match.arg(format)
  models <- list(...)

  if (length(models) == 0) {
    stop("At least one model must be provided.", call. = FALSE)
  }

  if (is.null(names(models))) {
    names(models) <- paste0("Model ", seq_along(models))
  }

  all_terms <- unique(unlist(lapply(models, function(m) {
    names(coef(m))
  })))

  result <- data.frame(Term = all_terms, stringsAsFactors = FALSE)

  for (model_name in names(models)) {
    m <- models[[model_name]]
    s <- summary(m)
    coefs <- s$coefficients

    estimates <- rep(NA_real_, length(all_terms))
    se <- rep(NA_real_, length(all_terms))
    pvals <- rep(NA_real_, length(all_terms))

    for (i in seq_along(all_terms)) {
      term <- all_terms[i]
      if (term %in% rownames(coefs)) {
        estimates[i] <- coefs[term, "Estimate"]
        se[i] <- coefs[term, "Std. Error"]
        pval_col <- grep("Pr|p.value", colnames(coefs),
                         ignore.case = TRUE)
        if (length(pval_col) > 0) {
          pvals[i] <- coefs[term, pval_col[1]]
        }
      }
    }

    formatted <- format_with_stars(estimates, pvals, stars, digits)

    if (se_in_parens && "std.error" %in% include) {
      se_formatted <- ifelse(is.na(se), "",
        paste0("(", round(se, digits), ")")
      )
      formatted <- paste(formatted, se_formatted, sep = " ")
    }

    result[[model_name]] <- formatted
  }

  stats_rows <- build_model_stats(models, digits)
  coef_nrow <- nrow(result)
  result <- rbind(result, stats_rows)

  do.call(zzt2f.default, c(
    list(x = result, filename = filename, sub_dir = sub_dir,
         format = format, theme = theme, caption = caption,
         separator_row = coef_nrow),
    zzt2f_args
  ))
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
                           separator_row = NULL,
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

  # --- Promote non-default row names to first column ---
  rn <- rownames(x)
  default_rn <- as.character(seq_len(nrow(x)))
  has_rownames <- !is.null(rn) && !identical(rn, default_rn)
  if (has_rownames) {
    x <- cbind(" " = rn, x)
    rownames(x) <- NULL
    if (!is.null(align) && length(align) > 1) {
      align <- c("l", align)
    }
    if (!is.null(header_above) && inherits(header_above, "t2f_header")) {
      h <- header_above$header
      if (length(h) > 0 && trimws(names(h)[1]) == "") {
        h[1] <- h[1] + 1L
        header_above$header <- h
      }
    }
  }

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
  typ_content <- postprocess_typst(typ_content, list(
    font_family = ts$font_family,
    caption_above = !is.null(caption),
    separator_row = separator_row,
    n_cols = ncol(x),
    compact_footnotes = !is.null(footnote)
  ))
  writeLines(typ_content, typ_file)

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
