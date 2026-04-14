#' Statistical-Object Helpers for the Typst Backend
#'
#' @description Thin adapters that extract tabular content from
#'   fitted models or other statistical objects and route it through
#'   \code{zzt2f()}. Parallel in purpose to \code{t2f_tidy()},
#'   \code{t2f_coef()}, \code{t2f_rms_compare()}.
#'
#' @name zzt2f-stat
NULL

#' Tidy a model object and render with the Typst backend
#'
#' @param x A model object accepted by \code{broom::tidy()}.
#' @param tidy_args List of additional arguments to \code{broom::tidy()}.
#' @param glance Logical. If TRUE and a \code{glance()} method
#'   exists, a model-summary line is emitted via \code{message()}.
#' @param digits Integer. Decimal places.
#' @param ... Forwarded to \code{zzt2f.default()}.
#' @return Output-file path from \code{zzt2f()}.
#' @examples
#' \dontrun{
#' m <- lm(mpg ~ cyl, data = mtcars)
#' zzt2f_tidy(m, filename = "lm_tidy")
#' }
#' @export
zzt2f_tidy <- function(x, tidy_args = list(),
                       glance = FALSE, digits = 3L, ...) {
  check_broom()
  tidy_df <- do.call(broom::tidy, c(list(x), tidy_args))
  tidy_df <- round_numeric_cols(tidy_df, digits)
  if ("p.value" %in% names(tidy_df)) {
    tidy_df$p.value <- format_pvalue(tidy_df$p.value, digits)
  }
  if (isTRUE(glance) &&
      "glance" %in% methods(class = class(x)[1L])) {
    glance_df <- broom::glance(x)
    glance_note <- paste(
      names(glance_df),
      vapply(glance_df, function(v) {
        if (is.numeric(v)) format(round(v, digits))
        else as.character(v)
      }, character(1L)),
      sep = " = ", collapse = "; "
    )
    message("Model statistics: ", glance_note)
  }
  zzt2f.default(tidy_df, ...)
}

#' Coefficient table rendered inline with the Typst backend
#'
#' @description Convenience wrapper that renders a fitted model as a
#'   coefficient table via \code{zzt2f_inline()}. Matches the shape
#'   of \code{t2f_coef()}, minus LaTeX-specific arguments
#'   (\code{frame}, \code{background}, \code{inner_sep}, etc.) that
#'   have no Typst analog.
#'
#' @param model A fitted model (\code{lm}, \code{glm}, or any object
#'   with a \code{zzt2f} S3 method).
#' @param width Character. Typst-compatible width (e.g.
#'   \code{"3in"}, \code{"80%"}).
#' @param align One of \code{"center"}, \code{"left"},
#'   \code{"right"}.
#' @param digits Decimal places.
#' @param theme Theme name or object.
#' @param caption Character or NULL.
#' @param label Character or NULL.
#' @param ... Forwarded to \code{zzt2f_inline()} / \code{zzt2f()}.
#' @return Path to the rendered file.
#' @export
zzt2f_coef <- function(model,
                       width = "3in",
                       align = "center",
                       digits = 3L,
                       theme = "minimal",
                       caption = NULL,
                       label = NULL,
                       ...) {
  zzt2f_inline(
    model,
    width = width,
    align = align,
    digits = digits,
    theme = theme,
    caption = caption,
    label = label,
    ...
  )
}

#' Side-by-side RMS regression comparison (Typst backend)
#'
#' @param ... Named \code{rms} model objects.
#' @param digits Decimal places.
#' @param exponentiate Logical.
#' @param stars Numeric vector of significance thresholds.
#' @param filename Output base filename.
#' @param sub_dir Output directory.
#' @param zzt2f_args List of arguments forwarded to \code{zzt2f()}.
#' @return Path to the rendered file.
#' @export
zzt2f_rms_compare <- function(...,
                              digits = 3L,
                              exponentiate = FALSE,
                              stars = c(0.05, 0.01, 0.001),
                              filename = "rms_comparison",
                              sub_dir = get_default_figures_dir(),
                              zzt2f_args = list()) {
  check_rms()
  models <- list(...)
  if (length(models) == 0L) {
    stop("At least one model must be provided.", call. = FALSE)
  }
  if (is.null(names(models))) {
    names(models) <- paste0("Model ", seq_along(models))
  }

  all_terms <- unique(unlist(lapply(models, function(m) {
    names(stats::coef(m))
  })))
  result <- data.frame(Term = all_terms, stringsAsFactors = FALSE)

  for (mn in names(models)) {
    m <- models[[mn]]
    coefs <- stats::coef(m)
    se <- sqrt(diag(stats::vcov(m)))
    est <- rep(NA_real_, length(all_terms))
    pvals <- rep(NA_real_, length(all_terms))
    for (i in seq_along(all_terms)) {
      term <- all_terms[i]
      if (term %in% names(coefs)) {
        idx <- which(names(coefs) == term)
        est[i] <- coefs[idx]
        pvals[i] <- 2 * stats::pnorm(-abs(coefs[idx] / se[idx]))
      }
    }
    if (isTRUE(exponentiate)) est <- exp(est)
    result[[mn]] <- format_with_stars(est, pvals, stars, digits)
  }

  do.call(zzt2f.default, c(
    list(x = result, filename = filename, sub_dir = sub_dir),
    zzt2f_args
  ))
}
