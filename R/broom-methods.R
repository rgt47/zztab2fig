#' Broom-Based S3 Methods for Extended Object Support
#'
#' @description S3 methods that use the broom package to convert statistical
#'   objects to tidy data frames before generating LaTeX tables. These methods
#'   extend zztab2fig's support to survival models, time series, clustering,
#'   and other object types.
#'
#' @name broom-methods
NULL

# Helper function to check broom availability
check_broom <- function() {
  if (!requireNamespace("broom", quietly = TRUE)) {
    stop(
      "Package 'broom' is required for this object type.\n",
      "Install it with: install.packages('broom')",
      call. = FALSE
    )
  }
}

#' Convert any broom-supported object to a LaTeX table
#'
#' @description A general-purpose function that uses broom::tidy() to convert
#'   any broom-supported object to a tidy data frame, then generates a LaTeX
#'
#'   table via t2f().
#'
#' @param x An object supported by broom::tidy().
#' @param tidy_args A list of arguments to pass to broom::tidy().
#' @param glance Logical. If TRUE, append model-level statistics from
#'   broom::glance() as footnote or additional rows.
#' @param digits Number of decimal places for rounding.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' library(survival)
#' cox_model <- coxph(Surv(time, status) ~ age + sex, data = lung)
#' t2f_tidy(cox_model, filename = "cox_results")
#' }
#'
#' @export
t2f_tidy <- function(x, tidy_args = list(), glance = FALSE, digits = 3, ...) {
  check_broom()

  tidy_df <- do.call(broom::tidy, c(list(x), tidy_args))

  tidy_df <- round_numeric_cols(tidy_df, digits)

  if ("p.value" %in% names(tidy_df)) {
    tidy_df$p.value <- format_pvalue(tidy_df$p.value, digits)
  }

  if (glance && "glance" %in% methods(class = class(x)[1])) {
    glance_df <- broom::glance(x)
    glance_note <- paste(
      names(glance_df),
      sapply(glance_df, function(v) {
        if (is.numeric(v)) round(v, digits) else as.character(v)
      }),
      sep = " = ",
      collapse = "; "
    )
    message("Model statistics: ", glance_note)
  }

  t2f.default(tidy_df, ...)
}

#' Round numeric columns in a data frame
#' @keywords internal
round_numeric_cols <- function(df, digits) {
  numeric_cols <- sapply(df, is.numeric)
  df[numeric_cols] <- lapply(df[numeric_cols], function(col) {
    round(col, digits)
  })
  df
}


# Survival Analysis Methods -----------------------------------------------

#' t2f method for Cox proportional hazards models
#'
#' @param x A coxph object from the survival package.
#' @param digits Number of decimal places.
#' @param exponentiate Logical. If TRUE, exponentiate coefficients to get
#'   hazard ratios.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' library(survival)
#' model <- coxph(Surv(time, status) ~ age + sex + ph.ecog, data = lung)
#' t2f(model, exponentiate = TRUE, filename = "cox_hazard_ratios")
#' }
#'
#' @export
t2f.coxph <- function(x, digits = 3, exponentiate = TRUE,
                      conf.int = TRUE, conf.level = 0.95, ...) {
  check_broom()

  tidy_df <- broom::tidy(
    x,
    exponentiate = exponentiate,
    conf.int = conf.int,
    conf.level = conf.level
  )

  result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)

  est_label <- if (exponentiate) "HR" else "Estimate"
  result[[est_label]] <- round(tidy_df$estimate, digits)

  if ("std.error" %in% names(tidy_df)) {
    result$`Std. Error` <- round(tidy_df$std.error, digits)
  }

  if (conf.int && "conf.low" %in% names(tidy_df)) {
    result$`CI Lower` <- round(tidy_df$conf.low, digits)
    result$`CI Upper` <- round(tidy_df$conf.high, digits)
  }

  if ("p.value" %in% names(tidy_df)) {
    result$`p value` <- format_pvalue(tidy_df$p.value, digits)
  }

  t2f.default(result, ...)
}

#' t2f method for survreg (parametric survival models)
#'
#' @param x A survreg object from the survival package.
#' @param digits Number of decimal places.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.survreg <- function(x, digits = 3, conf.int = TRUE,
                        conf.level = 0.95, ...) {
  check_broom()

  tidy_df <- broom::tidy(x, conf.int = conf.int, conf.level = conf.level)

  result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)
  result$Estimate <- round(tidy_df$estimate, digits)

  if ("std.error" %in% names(tidy_df)) {
    result$`Std. Error` <- round(tidy_df$std.error, digits)
  }

  if (conf.int && "conf.low" %in% names(tidy_df)) {
    result$`CI Lower` <- round(tidy_df$conf.low, digits)
    result$`CI Upper` <- round(tidy_df$conf.high, digits)
  }

  if ("p.value" %in% names(tidy_df)) {
    result$`p value` <- format_pvalue(tidy_df$p.value, digits)
  }

  t2f.default(result, ...)
}

#' t2f method for survfit (survival curves)
#'
#' @param x A survfit object from the survival package.
#' @param digits Number of decimal places.
#' @param times Optional numeric vector of times at which to report survival.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.survfit <- function(x, digits = 3, times = NULL, ...) {
  check_broom()

  tidy_df <- broom::tidy(x)

  if (!is.null(times)) {
    tidy_df <- tidy_df[tidy_df$time %in% times, ]
  }

  tidy_df <- round_numeric_cols(tidy_df, digits)

  t2f.default(tidy_df, ...)
}

#' t2f method for survdiff (survival difference tests)
#'
#' @param x A survdiff object from the survival package.
#' @param digits Number of decimal places.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.survdiff <- function(x, digits = 3, ...) {
  check_broom()

  tidy_df <- broom::tidy(x)
  tidy_df <- round_numeric_cols(tidy_df, digits)

  t2f.default(tidy_df, ...)
}


# Time Series Methods -----------------------------------------------------

#' t2f method for ARIMA models
#'
#' @param x An Arima object from the stats or forecast package.
#' @param digits Number of decimal places.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.Arima <- function(x, digits = 3, conf.int = TRUE,
                      conf.level = 0.95, ...) {
  check_broom()

  tidy_df <- broom::tidy(x, conf.int = conf.int, conf.level = conf.level)

  result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)
  result$Estimate <- round(tidy_df$estimate, digits)

  if ("std.error" %in% names(tidy_df)) {
    result$`Std. Error` <- round(tidy_df$std.error, digits)
  }

  if (conf.int && "conf.low" %in% names(tidy_df)) {
    result$`CI Lower` <- round(tidy_df$conf.low, digits)
    result$`CI Upper` <- round(tidy_df$conf.high, digits)
  }

  t2f.default(result, ...)
}


# Nonlinear and Other Regression Methods ----------------------------------

#' t2f method for nonlinear least squares models
#'
#' @param x An nls object.
#' @param digits Number of decimal places.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.nls <- function(x, digits = 3, conf.int = TRUE,
                    conf.level = 0.95, ...) {
  check_broom()

  tidy_df <- broom::tidy(x, conf.int = conf.int, conf.level = conf.level)

  result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)
  result$Estimate <- round(tidy_df$estimate, digits)

  if ("std.error" %in% names(tidy_df)) {
    result$`Std. Error` <- round(tidy_df$std.error, digits)
  }

  if (conf.int && "conf.low" %in% names(tidy_df)) {
    result$`CI Lower` <- round(tidy_df$conf.low, digits)
    result$`CI Upper` <- round(tidy_df$conf.high, digits)
  }

  if ("p.value" %in% names(tidy_df)) {
    result$`p value` <- format_pvalue(tidy_df$p.value, digits)
  }

  t2f.default(result, ...)
}

#' t2f method for ordinal logistic regression (polr)
#'
#' @param x A polr object from the MASS package.
#' @param digits Number of decimal places.
#' @param exponentiate Logical. Exponentiate coefficients to get odds ratios.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.polr <- function(x, digits = 3, exponentiate = FALSE,
                     conf.int = TRUE, conf.level = 0.95, ...) {
  check_broom()

  tidy_df <- broom::tidy(
    x,
    exponentiate = exponentiate,
    conf.int = conf.int,
    conf.level = conf.level
  )

  result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)

  est_label <- if (exponentiate) "OR" else "Estimate"
  result[[est_label]] <- round(tidy_df$estimate, digits)

  if ("std.error" %in% names(tidy_df)) {
    result$`Std. Error` <- round(tidy_df$std.error, digits)
  }

  if (conf.int && "conf.low" %in% names(tidy_df)) {
    result$`CI Lower` <- round(tidy_df$conf.low, digits)
    result$`CI Upper` <- round(tidy_df$conf.high, digits)
  }

  if ("p.value" %in% names(tidy_df)) {
    result$`p value` <- format_pvalue(tidy_df$p.value, digits)
  }

  if ("coef.type" %in% names(tidy_df)) {
    result$Type <- tidy_df$coef.type
  }

  t2f.default(result, ...)
}

#' t2f method for multinomial logistic regression
#'
#' @param x A multinom object from the nnet package.
#' @param digits Number of decimal places.
#' @param exponentiate Logical. Exponentiate coefficients.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.multinom <- function(x, digits = 3, exponentiate = FALSE,
                         conf.int = TRUE, conf.level = 0.95, ...) {
  check_broom()

  tidy_df <- broom::tidy(
    x,
    exponentiate = exponentiate,
    conf.int = conf.int,
    conf.level = conf.level
  )

  result <- data.frame(
    Response = tidy_df$y.level,
    Term = tidy_df$term,
    stringsAsFactors = FALSE
  )

  est_label <- if (exponentiate) "RRR" else "Estimate"
  result[[est_label]] <- round(tidy_df$estimate, digits)

  if ("std.error" %in% names(tidy_df)) {
    result$`Std. Error` <- round(tidy_df$std.error, digits)
  }

  if (conf.int && "conf.low" %in% names(tidy_df)) {
    result$`CI Lower` <- round(tidy_df$conf.low, digits)
    result$`CI Upper` <- round(tidy_df$conf.high, digits)
  }

  if ("p.value" %in% names(tidy_df)) {
    result$`p value` <- format_pvalue(tidy_df$p.value, digits)
  }

  t2f.default(result, ...)
}


# Multivariate Methods ----------------------------------------------------

#' t2f method for principal component analysis
#'
#' @param x A prcomp object.
#' @param matrix Character. Which matrix to display: "rotation" (loadings),
#'   "x" (scores), or "summary" (variance explained).
#' @param digits Number of decimal places.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.prcomp <- function(x, matrix = "rotation", digits = 3, ...) {
  if (matrix == "summary") {
    s <- summary(x)
    result <- as.data.frame(t(s$importance))
    result <- cbind(Component = rownames(result), result)
    rownames(result) <- NULL
  } else if (matrix == "rotation") {
    result <- as.data.frame(x$rotation)
    result <- cbind(Variable = rownames(result), result)
    rownames(result) <- NULL
  } else if (matrix == "x") {
    result <- as.data.frame(x$x)
    result <- cbind(Observation = rownames(result), result)
    rownames(result) <- NULL
  } else {
    stop("matrix must be 'rotation', 'x', or 'summary'", call. = FALSE)
  }

  result <- round_numeric_cols(result, digits)
  t2f.default(result, ...)
}

#' t2f method for k-means clustering
#'
#' @param x A kmeans object.
#' @param matrix Character. Which results to display: "centers" (cluster
#'   centers) or "summary" (cluster sizes and SS).
#' @param digits Number of decimal places.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.kmeans <- function(x, matrix = "centers", digits = 3, ...) {
  if (matrix == "centers") {
    result <- as.data.frame(x$centers)
    result <- cbind(Cluster = seq_len(nrow(result)), result)
  } else if (matrix == "summary") {
    result <- data.frame(
      Cluster = seq_along(x$size),
      Size = x$size,
      `Within SS` = x$withinss,
      check.names = FALSE
    )
  } else {
    stop("matrix must be 'centers' or 'summary'", call. = FALSE)
  }

  result <- round_numeric_cols(result, digits)
  t2f.default(result, ...)
}


# Mixed Effects (requires broom.mixed) ------------------------------------

#' t2f method for lme4 linear mixed models
#'
#' @param x A lmerMod object from lme4.
#' @param effects Character. Which effects to show: "fixed", "ran_pars",
#'   or "ran_vals".
#' @param digits Number of decimal places.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.lmerMod <- function(x, effects = "fixed", digits = 3,
                        conf.int = TRUE, conf.level = 0.95, ...) {
  if (!requireNamespace("broom.mixed", quietly = TRUE)) {
    stop(
      "Package 'broom.mixed' is required for lme4 models.\n",
      "Install it with: install.packages('broom.mixed')",
      call. = FALSE
    )
  }

  tidy_df <- broom.mixed::tidy(
    x,
    effects = effects,
    conf.int = conf.int,
    conf.level = conf.level
  )

  if (effects == "fixed") {
    result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)
    result$Estimate <- round(tidy_df$estimate, digits)

    if ("std.error" %in% names(tidy_df)) {
      result$`Std. Error` <- round(tidy_df$std.error, digits)
    }

    if (conf.int && "conf.low" %in% names(tidy_df)) {
      result$`CI Lower` <- round(tidy_df$conf.low, digits)
      result$`CI Upper` <- round(tidy_df$conf.high, digits)
    }
  } else {
    result <- round_numeric_cols(tidy_df, digits)
  }

  t2f.default(result, ...)
}

#' t2f method for lme4 generalized linear mixed models
#'
#' @inheritParams t2f.lmerMod
#' @param exponentiate Logical. Exponentiate coefficients.
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.glmerMod <- function(x, effects = "fixed", digits = 3,
                         exponentiate = FALSE, conf.int = TRUE,
                         conf.level = 0.95, ...) {
  if (!requireNamespace("broom.mixed", quietly = TRUE)) {
    stop(
      "Package 'broom.mixed' is required for lme4 models.\n",
      "Install it with: install.packages('broom.mixed')",
      call. = FALSE
    )
  }

  tidy_df <- broom.mixed::tidy(
    x,
    effects = effects,
    exponentiate = exponentiate,
    conf.int = conf.int,
    conf.level = conf.level
  )

  if (effects == "fixed") {
    result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)

    est_label <- if (exponentiate) "OR" else "Estimate"
    result[[est_label]] <- round(tidy_df$estimate, digits)

    if ("std.error" %in% names(tidy_df)) {
      result$`Std. Error` <- round(tidy_df$std.error, digits)
    }

    if (conf.int && "conf.low" %in% names(tidy_df)) {
      result$`CI Lower` <- round(tidy_df$conf.low, digits)
      result$`CI Upper` <- round(tidy_df$conf.high, digits)
    }

    if ("p.value" %in% names(tidy_df)) {
      result$`p value` <- format_pvalue(tidy_df$p.value, digits)
    }
  } else {
    result <- round_numeric_cols(tidy_df, digits)
  }

  t2f.default(result, ...)
}

#' t2f method for nlme linear mixed models
#'
#' @param x An lme object from nlme.
#' @param effects Character. Which effects to show: "fixed" or "ran_pars".
#' @param digits Number of decimal places.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.lme <- function(x, effects = "fixed", digits = 3,
                    conf.int = TRUE, conf.level = 0.95, ...) {
  if (!requireNamespace("broom.mixed", quietly = TRUE)) {
    stop(
      "Package 'broom.mixed' is required for nlme models.\n",
      "Install it with: install.packages('broom.mixed')",
      call. = FALSE
    )
  }

  tidy_df <- broom.mixed::tidy(
    x,
    effects = effects,
    conf.int = conf.int,
    conf.level = conf.level
  )

  if (effects == "fixed") {
    result <- data.frame(Term = tidy_df$term, stringsAsFactors = FALSE)
    result$Estimate <- round(tidy_df$estimate, digits)

    if ("std.error" %in% names(tidy_df)) {
      result$`Std. Error` <- round(tidy_df$std.error, digits)
    }

    if (conf.int && "conf.low" %in% names(tidy_df)) {
      result$`CI Lower` <- round(tidy_df$conf.low, digits)
      result$`CI Upper` <- round(tidy_df$conf.high, digits)
    }

    if ("p.value" %in% names(tidy_df)) {
      result$`p value` <- format_pvalue(tidy_df$p.value, digits)
    }
  } else {
    result <- round_numeric_cols(tidy_df, digits)
  }

  t2f.default(result, ...)
}
