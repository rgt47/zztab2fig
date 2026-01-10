#' Internal Utility Functions
#'
#' @description Shared utility functions used across the zztab2fig package.
#'
#' @name utils
#' @keywords internal
NULL

# Null-coalescing operator
`%||%` <- function(x, y) if (is.null(x)) y else x

# Assertion Helpers ----

#' Assert parameter is a single logical value
#' @param x Value to check.
#' @param name Parameter name for error message.
#' @keywords internal
assert_single_logical <- function(x, name) {
  if (!is.logical(x) || length(x) != 1) {
    stop("`", name, "` must be a single logical value.", call. = FALSE)
  }
}

#' Assert parameter is a single character string or NULL
#' @param x Value to check.
#' @param name Parameter name for error message.
#' @keywords internal
assert_string_or_null <- function(x, name) {
  if (!is.null(x) && (!is.character(x) || length(x) != 1)) {
    stop("`", name, "` must be a single character string or NULL.", call. = FALSE)
  }
}

#' Assert parameter is a single character string
#' @param x Value to check.
#' @param name Parameter name for error message.
#' @keywords internal
assert_single_string <- function(x, name) {
  if (!is.character(x) || length(x) != 1) {
    stop("`", name, "` must be a single character string.", call. = FALSE)
  }
}

# Package Requirement Helper ----

#' Check that a package is available
#' @param pkg Package name.
#' @param for_what Description of what requires this package.
#' @keywords internal
require_package <- function(pkg, for_what = "this object type") {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      "Package '", pkg, "' is required for ", for_what, ".\n",
      "Install it with: install.packages('", pkg, "')",
      call. = FALSE
    )
  }
}

# System Command Helper ----

#' Check if a system command is available
#' @param cmd Command name to check.
#' @return Logical indicating if command is available.
#' @keywords internal
command_exists <- function(cmd) {
  nzchar(Sys.which(cmd))
}

# Data Frame Helpers ----

#' Round numeric columns in a data frame
#' @param df A data frame.
#' @param digits Number of decimal places.
#' @return Data frame with rounded numeric columns.
#' @keywords internal
round_numeric_cols <- function(df, digits) {
  numeric_cols <- vapply(df, is.numeric, logical(1))
  df[numeric_cols] <- lapply(df[numeric_cols], round, digits = digits)
  df
}

# Formatting Helpers ----

#' Format p-values for display
#' @param p Numeric vector of p-values.
#' @param digits Number of decimal places.
#' @return Character vector of formatted p-values.
#' @keywords internal
format_pvalue <- function(p, digits = 3) {
  vapply(p, function(pval) {
    if (is.na(pval)) {
      ""
    } else if (pval < 0.001) {
      "<0.001"
    } else {
      format(round(pval, digits), nsmall = digits)
    }
  }, character(1))
}

# Coefficient Table Builder ----

#' Build a coefficient table from tidy output
#'
#' @description Constructs a standardized coefficient table from broom::tidy()
#'   output. Used by multiple S3 methods for statistical objects.
#'
#' @param tidy_df Data frame from broom::tidy().
#' @param digits Number of decimal places for rounding.
#' @param est_label Label for estimate column (e.g., "Estimate", "HR", "OR").
#' @param conf.int Logical. Include confidence intervals if available.
#' @param include_pvalue Logical. Include p-value column if available.
#' @return Data frame with formatted coefficients.
#' @keywords internal
build_coef_table <- function(tidy_df, digits, est_label = "Estimate",
                             conf.int = TRUE, include_pvalue = TRUE) {
  result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)
  result[[est_label]] <- round(tidy_df$estimate, digits)

  if ("std.error" %in% names(tidy_df)) {
    result$`Std. Error` <- round(tidy_df$std.error, digits)
  }

  if (conf.int && "conf.low" %in% names(tidy_df)) {
    result$`CI Lower` <- round(tidy_df$conf.low, digits)
    result$`CI Upper` <- round(tidy_df$conf.high, digits)
  }

  if (include_pvalue && "p.value" %in% names(tidy_df)) {
    result$`p value` <- format_pvalue(tidy_df$p.value, digits)
  }

  result
}
