#' S3 Methods for Statistical Objects
#'
#' @description S3 methods for generating LaTeX tables from various R objects
#'   including linear models, generalized linear models, ANOVA results, and
#'   hypothesis tests.
#'
#' @name s3-methods
NULL

#' Convert objects to LaTeX tables
#'
#' @description Generic function for converting R objects to LaTeX tables
#'   and generating PDF output.
#'
#' @param x An object to convert to a LaTeX table.
#' @param ... Additional arguments passed to methods.
#'
#' @return Invisibly returns the path to the generated PDF file.
#'
#' @examples
#' \dontrun{
#' # Data frame
#' t2f(mtcars)
#'
#' # Linear model
#' model <- lm(mpg ~ cyl + hp, data = mtcars)
#' t2f(model)
#'
#' # t-test
#' t2f(t.test(mtcars$mpg, mu = 20))
#' }
#'
#' @export
t2f <- function(x, ...) {
  UseMethod("t2f")
}

#' Default method for t2f (data frames)
#'
#' @param x A data frame to convert to a LaTeX table.
#' @param filename Base name for output files.
#' @param sub_dir Output directory.
#' @param scolor Row shading color.
#' @param verbose Print progress messages.
#' @param extra_packages Additional LaTeX packages.
#' @param document_class LaTeX document class.
#' @param caption Table caption.
#' @param caption_short Short caption for List of Tables.
#' @param label LaTeX label for cross-referencing.
#' @param align Column alignment (can include t2f_siunitx for decimal align).
#' @param longtable Use longtable for multi-page tables.
#' @param crop Crop the PDF output.
#' @param crop_margin Crop margin size.
#' @param theme Theme name or t2f_theme object.
#' @param footnote A t2f_footnote object for table footnotes.
#' @param header_above A t2f_header object or list for spanning headers.
#' @param collapse_rows A t2f_collapse object for multi-row cells.
#' @param ... Additional arguments (ignored).
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.default <- function(x, filename = NULL,
                        sub_dir = "figures",
                        scolor = NULL, verbose = FALSE,
                        extra_packages = NULL,
                        document_class = NULL,
                        caption = NULL,
                        caption_short = NULL,
                        label = NULL,
                        align = NULL,
                        longtable = FALSE,
                        crop = TRUE,
                        crop_margin = 10,
                        theme = NULL,
                        footnote = NULL,
                        header_above = NULL,
                        collapse_rows = NULL,
                        ...) {
  if (!is.data.frame(x)) {
    stop("No t2f method for class '", class(x)[1],
      "'. Convert to data.frame first.",
      call. = FALSE
    )
  }

  # Get filename from call if not provided
  if (is.null(filename)) {
    filename <- deparse(substitute(x))
  }

  # Call the internal implementation
  t2f_internal(
    df = x,
    filename = filename,
    sub_dir = sub_dir,
    scolor = scolor,
    verbose = verbose,
    extra_packages = extra_packages,
    document_class = document_class,
    caption = caption,
    caption_short = caption_short,
    label = label,
    align = align,
    longtable = longtable,
    crop = crop,
    crop_margin = crop_margin,
    theme = theme,
    footnote = footnote,
    header_above = header_above,
    collapse_rows = collapse_rows
  )
}

#' t2f method for data.frame
#' @rdname t2f.default
#' @export
t2f.data.frame <- function(x, ...) {
  t2f.default(x, ...)
}

#' t2f method for matrix
#'
#' @param x A matrix to convert to a LaTeX table.
#' @param rownames Logical. Include row names as first column.
#' @param ... Additional arguments passed to t2f.default.
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.matrix <- function(x, rownames = TRUE, ...) {
  df <- as.data.frame(x)
  if (rownames && !is.null(rownames(x))) {
    df <- cbind(rowname = rownames(x), df)
  }
  t2f.default(df, ...)
}

#' t2f method for table
#'
#' @param x A table object to convert to a LaTeX table.
#' @param ... Additional arguments passed to t2f.default.
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.table <- function(x, ...) {
  df <- as.data.frame.matrix(x)
  if (!is.null(rownames(df))) {
    df <- cbind(rowname = rownames(df), df)
  }
  t2f.default(df, ...)
}

#' t2f method for linear models
#'
#' @param x An lm object.
#' @param digits Number of decimal places for coefficients.
#' @param include Character vector of statistics to include. Options:
#'   "estimate", "std.error", "statistic", "p.value", "conf.int".
#' @param conf.level Confidence level for confidence intervals.
#' @param ... Additional arguments passed to t2f.default.
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
#' t2f(model, filename = "regression_table")
#' }
#'
#' @export
t2f.lm <- function(x,
                   digits = 3,
                   include = c("estimate", "std.error", "statistic", "p.value"),
                   conf.level = 0.95,
                   ...) {
  # Extract summary
  s <- summary(x)
  coef_df <- as.data.frame(s$coefficients)

  # Build result data frame
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
  t2f.default(result, ...)
}

#' t2f method for generalized linear models
#'
#' @param x A glm object.
#' @param digits Number of decimal places.
#' @param include Character vector of statistics to include.
#' @param exponentiate Logical. Exponentiate coefficients (for logistic/Poisson
#'   regression).
#' @param conf.level Confidence level for confidence intervals.
#' @param ... Additional arguments passed to t2f.default.
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' model <- glm(am ~ mpg + hp, data = mtcars, family = binomial)
#' t2f(model, exponentiate = TRUE)
#' }
#'
#' @export
t2f.glm <- function(x,
                    digits = 3,
                    include = c("estimate", "std.error", "statistic", "p.value"),
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
  t2f.default(result, ...)
}

#' t2f method for ANOVA objects
#'
#' @param x An anova or aov object.
#' @param digits Number of decimal places.
#' @param ... Additional arguments passed to t2f.default.
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.anova <- function(x, digits = 3, ...) {
  df <- as.data.frame(x)
  df <- cbind(Source = rownames(df), df)
  rownames(df) <- NULL

  # Round numeric columns
  numeric_cols <- sapply(df, is.numeric)
  df[numeric_cols] <- lapply(df[numeric_cols], function(col) {
    round(col, digits)
  })

  # Format p-values if present
  pval_cols <- grep("Pr|p.value|P-value", names(df), ignore.case = TRUE)
  for (col in pval_cols) {
    df[[col]] <- format_pvalue(df[[col]], digits)
  }

  t2f.default(df, ...)
}

#' t2f method for aov objects
#' @rdname t2f.anova
#' @export
t2f.aov <- function(x, digits = 3, ...) {
  t2f.anova(summary(x)[[1]], digits = digits, ...)
}

#' t2f method for hypothesis tests
#'
#' @param x An htest object (from t.test, chisq.test, etc.).
#' @param digits Number of decimal places.
#' @param ... Additional arguments passed to t2f.default.
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' test <- t.test(mtcars$mpg, mu = 20)
#' t2f(test, filename = "ttest_result")
#' }
#'
#' @export
t2f.htest <- function(x, digits = 3, ...) {
  result <- data.frame(
    Statistic = names(x$statistic),
    Value = round(x$statistic, digits),
    stringsAsFactors = FALSE
  )

  # Add degrees of freedom if present
  if (!is.null(x$parameter)) {
    result$df <- round(x$parameter, digits)
  }

  # Add p-value
  result$`p value` <- format_pvalue(x$p.value, digits)

  # Add confidence interval if present
  if (!is.null(x$conf.int)) {
    result$`CI Lower` <- round(x$conf.int[1], digits)
    result$`CI Upper` <- round(x$conf.int[2], digits)
  }

  # Add estimate if present
  if (!is.null(x$estimate)) {
    for (i in seq_along(x$estimate)) {
      result[[names(x$estimate)[i]]] <- round(x$estimate[i], digits)
    }
  }

  rownames(result) <- NULL
  t2f.default(result, ...)
}

#' Create side-by-side regression comparison table
#'
#' @description Generate a publication-ready table comparing multiple
#'   regression models side-by-side.
#'
#' @param ... Named lm or glm objects to compare.
#' @param include Character vector of statistics to include per model.
#' @param stars Logical or numeric vector. If TRUE, use default significance
#'   thresholds. If numeric, specifies p-value cutoffs for stars.
#' @param digits Number of decimal places.
#' @param se_in_parens Logical. Show standard errors in parentheses below
#'   estimates.
#' @param filename Base name for output files.
#' @param sub_dir Output directory for generated files.
#' @param t2f_args List of additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' m1 <- lm(mpg ~ cyl, data = mtcars)
#' m2 <- lm(mpg ~ cyl + hp, data = mtcars)
#' m3 <- lm(mpg ~ cyl + hp + wt, data = mtcars)
#' t2f_regression(Model1 = m1, Model2 = m2, Model3 = m3)
#' }
#'
#' @export
t2f_regression <- function(...,
                           include = c("estimate", "std.error"),
                           stars = c(0.05, 0.01, 0.001),
                           digits = 3,
                           se_in_parens = TRUE,
                           filename = "regression_table",
                           sub_dir = "figures",
                           t2f_args = list()) {
  models <- list(...)

  if (length(models) == 0) {
    stop("At least one model must be provided.", call. = FALSE)
  }

  # Ensure models are named
  if (is.null(names(models))) {
    names(models) <- paste0("Model ", seq_along(models))
  }

  # Get all unique terms across models
  all_terms <- unique(unlist(lapply(models, function(m) {
    names(coef(m))
  })))

  # Build result data frame
  result <- data.frame(Term = all_terms, stringsAsFactors = FALSE)

  for (model_name in names(models)) {
    m <- models[[model_name]]
    s <- summary(m)
    coefs <- s$coefficients

    # Extract estimates
    estimates <- rep(NA_real_, length(all_terms))
    se <- rep(NA_real_, length(all_terms))
    pvals <- rep(NA_real_, length(all_terms))

    for (i in seq_along(all_terms)) {
      term <- all_terms[i]
      if (term %in% rownames(coefs)) {
        estimates[i] <- coefs[term, "Estimate"]
        se[i] <- coefs[term, "Std. Error"]
        pval_col <- grep("Pr|p.value", colnames(coefs), ignore.case = TRUE)
        if (length(pval_col) > 0) {
          pvals[i] <- coefs[term, pval_col[1]]
        }
      }
    }

    # Format with stars if requested
    formatted <- format_with_stars(estimates, pvals, stars, digits)

    if (se_in_parens && "std.error" %in% include) {
      se_formatted <- ifelse(is.na(se), "",
        paste0("(", round(se, digits), ")")
      )
      formatted <- paste(formatted, se_formatted, sep = "\n")
    }

    result[[model_name]] <- formatted
  }

  # Add model statistics at bottom
  stats_rows <- build_model_stats(models, digits)
  result <- rbind(result, stats_rows)

  # Call t2f with the comparison table
  do.call(t2f.default, c(list(x = result, filename = filename, sub_dir = sub_dir),
                         t2f_args))
}

# Helper functions

#' Format p-values for display
#' @keywords internal
format_pvalue <- function(p, digits = 3) {
  sapply(p, function(pval) {
    if (is.na(pval)) {
      return("")
    }
    if (pval < 0.001) {
      "<0.001"
    } else {
      format(round(pval, digits), nsmall = digits)
    }
  })
}

#' Format estimates with significance stars
#' @keywords internal
format_with_stars <- function(estimates, pvals, stars, digits) {
  if (isFALSE(stars)) {
    return(ifelse(is.na(estimates), "",
      as.character(round(estimates, digits))
    ))
  }

  if (isTRUE(stars)) {
    stars <- c(0.05, 0.01, 0.001)
  }

  stars <- sort(stars, decreasing = TRUE)
  star_chars <- c("*", "**", "***")[seq_along(stars)]

  sapply(seq_along(estimates), function(i) {
    if (is.na(estimates[i])) {
      return("")
    }
    est_str <- as.character(round(estimates[i], digits))
    if (!is.na(pvals[i])) {
      for (j in seq_along(stars)) {
        if (pvals[i] < stars[j]) {
          est_str <- paste0(est_str, star_chars[j])
          break
        }
      }
    }
    est_str
  })
}

#' Build model statistics rows
#' @keywords internal
build_model_stats <- function(models, digits) {
  n_obs <- sapply(models, function(m) nobs(m))
  r_squared <- sapply(models, function(m) {
    if (inherits(m, "lm") && !inherits(m, "glm")) {
      round(summary(m)$r.squared, digits)
    } else {
      NA
    }
  })
  adj_r_squared <- sapply(models, function(m) {
    if (inherits(m, "lm") && !inherits(m, "glm")) {
      round(summary(m)$adj.r.squared, digits)
    } else {
      NA
    }
  })

  stats <- data.frame(
    Term = c("N", "R-squared", "Adj. R-squared"),
    stringsAsFactors = FALSE
  )

  for (model_name in names(models)) {
    i <- which(names(models) == model_name)
    stats[[model_name]] <- c(
      as.character(n_obs[i]),
      if (is.na(r_squared[i])) "" else as.character(r_squared[i]),
      if (is.na(adj_r_squared[i])) "" else as.character(adj_r_squared[i])
    )
  }

  stats
}
