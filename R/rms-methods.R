#' RMS Package S3 Methods
#'
#' @description S3 methods for generating LaTeX tables from Frank Harrell's
#'   rms (Regression Modeling Strategies) package objects. These methods
#'   provide publication-ready output for ols, lrm, cph, orm, Glm, and psm
#'   models commonly used in biostatistics and clinical trials.
#'
#' @name rms-methods
NULL

# Helper function to check rms availability
check_rms <- function() {
  require_package("rms", "rms model objects")
}

#' Extract coefficient table from rms objects
#'
#' @description Internal helper to extract and format coefficients from
#'
#'   rms model objects using their native summary methods.
#'
#' @param x An rms model object.
#' @param digits Number of decimal places.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param exponentiate Logical. Exponentiate coefficients.
#'
#' @return A data frame with formatted coefficients.
#'
#' @keywords internal
extract_rms_coefs <- function(x, digits = 3, conf.int = TRUE,
                              conf.level = 0.95, exponentiate = FALSE) {
  check_rms()

  coefs <- stats::coef(x)
  se <- sqrt(diag(stats::vcov(x)))

  if (exponentiate) {
    est <- exp(coefs)
    se_exp <- est * se
  } else {
    est <- coefs
    se_exp <- se
  }

  result <- data.frame(
    Term = names(coefs),
    stringsAsFactors = FALSE
  )

  est_label <- if (exponentiate) {
    if (inherits(x, "cph")) "HR" else "OR"
  } else {
    "Estimate"
  }

  result[[est_label]] <- round(est, digits)
  result$`Std. Error` <- round(se_exp, digits)

  if (conf.int) {
    z <- stats::qnorm(1 - (1 - conf.level) / 2)
    ci_low <- coefs - z * se
    ci_high <- coefs + z * se
    if (exponentiate) {
      ci_low <- exp(ci_low)
      ci_high <- exp(ci_high)
    }
    result$`CI Lower` <- round(ci_low, digits)
    result$`CI Upper` <- round(ci_high, digits)
  }

  z_stat <- coefs / se
  p_vals <- 2 * stats::pnorm(-abs(z_stat))
  result$`p value` <- format_pvalue(p_vals, digits)

  result
}

#' Extract ANOVA-style output from rms objects
#'
#' @description Internal helper to extract ANOVA (chunk test) results from
#'   rms model objects.
#'
#' @param x An rms model object.
#' @param digits Number of decimal places.
#'
#' @return A data frame with ANOVA results.
#'
#' @keywords internal
extract_rms_anova <- function(x, digits = 3) {
  check_rms()

  a <- rms::anova.rms(x)
  result <- as.data.frame(a)

  result <- cbind(Term = rownames(result), result)
  rownames(result) <- NULL

  result <- round_numeric_cols(result, digits)

  pval_cols <- grep("^P$|^Pr|p.value", names(result), ignore.case = TRUE)
  for (col in pval_cols) {
    if (is.numeric(result[[col]])) {
      result[[col]] <- format_pvalue(result[[col]], digits)
    }
  }

  result
}


# OLS (Ordinary Least Squares) --------------------------------------------

#' t2f method for rms ordinary least squares models
#'
#' @param x An ols object from the rms package.
#' @param digits Number of decimal places.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param output Character. Type of output: "coef" for coefficient table,
#'   "anova" for ANOVA-style chunk tests.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' library(rms)
#' dd <- datadist(mtcars)
#' options(datadist = "dd")
#' model <- ols(mpg ~ rcs(wt, 4) + cyl, data = mtcars)
#' t2f(model, filename = "ols_results")
#' t2f(model, output = "anova", filename = "ols_anova")
#' }
#'
#' @export
t2f.ols <- function(x, digits = 3, conf.int = TRUE, conf.level = 0.95,
                    output = c("coef", "anova"), ...) {
  output <- match.arg(output)

  if (output == "anova") {
    result <- extract_rms_anova(x, digits)
  } else {
    result <- extract_rms_coefs(x, digits, conf.int, conf.level,
                                exponentiate = FALSE)
  }

  t2f.default(result, ...)
}


# LRM (Logistic Regression Model) -----------------------------------------

#' t2f method for rms logistic regression models
#'
#' @param x An lrm object from the rms package.
#' @param digits Number of decimal places.
#' @param exponentiate Logical. If TRUE, exponentiate coefficients to get
#'   odds ratios.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param output Character. Type of output: "coef" for coefficient table,
#'   "anova" for ANOVA-style chunk tests.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' library(rms)
#' dd <- datadist(mtcars)
#' options(datadist = "dd")
#' model <- lrm(am ~ rcs(mpg, 4) + wt, data = mtcars)
#' t2f(model, exponentiate = TRUE, filename = "lrm_odds_ratios")
#' t2f(model, output = "anova", filename = "lrm_anova")
#' }
#'
#' @export
t2f.lrm <- function(x, digits = 3, exponentiate = TRUE,
                    conf.int = TRUE, conf.level = 0.95,
                    output = c("coef", "anova"), ...) {
  output <- match.arg(output)

  if (output == "anova") {
    result <- extract_rms_anova(x, digits)
  } else {
    result <- extract_rms_coefs(x, digits, conf.int, conf.level, exponentiate)
  }

  t2f.default(result, ...)
}


# CPH (Cox Proportional Hazards) ------------------------------------------

#' t2f method for rms Cox proportional hazards models
#'
#' @param x A cph object from the rms package.
#' @param digits Number of decimal places.
#' @param exponentiate Logical. If TRUE, exponentiate coefficients to get
#'   hazard ratios.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param output Character. Type of output: "coef" for coefficient table,
#'   "anova" for ANOVA-style chunk tests.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' library(rms)
#' library(survival)
#' dd <- datadist(lung)
#' options(datadist = "dd")
#' model <- cph(Surv(time, status) ~ age + rcs(meal.cal, 4) + sex, data = lung)
#' t2f(model, exponentiate = TRUE, filename = "cox_hazard_ratios")
#' t2f(model, output = "anova", filename = "cox_anova")
#' }
#'
#' @export
t2f.cph <- function(x, digits = 3, exponentiate = TRUE,
                    conf.int = TRUE, conf.level = 0.95,
                    output = c("coef", "anova"), ...) {
  output <- match.arg(output)

  if (output == "anova") {
    result <- extract_rms_anova(x, digits)
  } else {
    result <- extract_rms_coefs(x, digits, conf.int, conf.level, exponentiate)
  }

  t2f.default(result, ...)
}


# ORM (Ordinal Regression Model) ------------------------------------------

#' t2f method for rms ordinal regression models
#'
#' @param x An orm object from the rms package.
#' @param digits Number of decimal places.
#' @param exponentiate Logical. If TRUE, exponentiate coefficients to get
#'   odds ratios.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param output Character. Type of output: "coef" for coefficient table,
#'   "anova" for ANOVA-style chunk tests.
#' @param intercepts Logical. If TRUE, include intercept terms in coefficient
#'   table. Default FALSE since ordinal models often have many intercepts.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' library(rms)
#' dd <- datadist(mtcars)
#' options(datadist = "dd")
#' mtcars$gear_ord <- ordered(mtcars$gear)
#' model <- orm(gear_ord ~ mpg + wt, data = mtcars)
#' t2f(model, exponentiate = TRUE, filename = "orm_odds_ratios")
#' }
#'
#' @export
t2f.orm <- function(x, digits = 3, exponentiate = TRUE,
                    conf.int = TRUE, conf.level = 0.95,
                    output = c("coef", "anova"),
                    intercepts = FALSE, ...) {
  output <- match.arg(output)

  if (output == "anova") {
    result <- extract_rms_anova(x, digits)
  } else {
    result <- extract_rms_coefs(x, digits, conf.int, conf.level, exponentiate)
    if (!intercepts) {
      intercept_rows <- grep("^y>=|^y>", result$Term)
      if (length(intercept_rows) > 0) {
        result <- result[-intercept_rows, , drop = FALSE]
      }
    }
  }

  t2f.default(result, ...)
}


# Glm (Generalized Linear Model - rms version) ----------------------------

#' t2f method for rms generalized linear models
#'
#' @param x A Glm object from the rms package.
#' @param digits Number of decimal places.
#' @param exponentiate Logical. If TRUE, exponentiate coefficients.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param output Character. Type of output: "coef" for coefficient table,
#'   "anova" for ANOVA-style chunk tests.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @export
t2f.Glm <- function(x, digits = 3, exponentiate = FALSE,
                    conf.int = TRUE, conf.level = 0.95,
                    output = c("coef", "anova"), ...) {
  output <- match.arg(output)

  if (output == "anova") {
    result <- extract_rms_anova(x, digits)
  } else {
    result <- extract_rms_coefs(x, digits, conf.int, conf.level, exponentiate)
  }

  t2f.default(result, ...)
}


# PSM (Parametric Survival Model) -----------------------------------------

#' t2f method for rms parametric survival models
#'
#' @param x A psm object from the rms package.
#' @param digits Number of decimal places.
#' @param conf.int Logical. Include confidence intervals.
#' @param conf.level Confidence level for intervals.
#' @param output Character. Type of output: "coef" for coefficient table,
#'   "anova" for ANOVA-style chunk tests.
#' @param ... Additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' library(rms)
#' library(survival)
#' dd <- datadist(lung)
#' options(datadist = "dd")
#' model <- psm(Surv(time, status) ~ age + sex, data = lung, dist = "weibull")
#' t2f(model, filename = "psm_results")
#' }
#'
#' @export
t2f.psm <- function(x, digits = 3, conf.int = TRUE, conf.level = 0.95,
                    output = c("coef", "anova"), ...) {
  output <- match.arg(output)

  if (output == "anova") {
    result <- extract_rms_anova(x, digits)
  } else {
    result <- extract_rms_coefs(x, digits, conf.int, conf.level,
                                exponentiate = FALSE)
  }

  t2f.default(result, ...)
}


# Model Comparison for RMS Objects ----------------------------------------

#' Create side-by-side comparison table for rms models
#'
#' @description Generate a publication-ready table comparing multiple rms
#'   regression models side-by-side, similar to t2f_regression() but
#'   optimized for rms objects.
#'
#' @param ... Named rms model objects to compare (ols, lrm, cph, etc.).
#' @param digits Number of decimal places.
#' @param exponentiate Logical. Exponentiate coefficients where appropriate.
#' @param stars Logical or numeric vector for significance stars.
#' @param filename Base name for output files.
#' @param sub_dir Output directory.
#' @param t2f_args List of additional arguments passed to t2f().
#'
#' @return Invisibly returns the path to the generated PDF.
#'
#' @examples
#' \dontrun{
#' library(rms)
#' dd <- datadist(mtcars)
#' options(datadist = "dd")
#' m1 <- ols(mpg ~ wt, data = mtcars)
#' m2 <- ols(mpg ~ wt + cyl, data = mtcars)
#' m3 <- ols(mpg ~ wt + cyl + hp, data = mtcars)
#' t2f_rms_compare(Model1 = m1, Model2 = m2, Model3 = m3)
#' }
#'
#' @export
t2f_rms_compare <- function(...,
                            digits = 3,
                            exponentiate = FALSE,
                            stars = c(0.05, 0.01, 0.001),
                            filename = "rms_comparison",
                            sub_dir = "figures",
                            t2f_args = list()) {
  check_rms()
  models <- list(...)

  if (length(models) == 0) {
    stop("At least one model must be provided.", call. = FALSE)
  }

  if (is.null(names(models))) {
    names(models) <- paste0("Model ", seq_along(models))
  }

  all_terms <- unique(unlist(lapply(models, function(m) {
    names(stats::coef(m))
  })))

  result <- data.frame(Term = all_terms, stringsAsFactors = FALSE)

  for (model_name in names(models)) {
    m <- models[[model_name]]
    coefs <- stats::coef(m)
    se <- sqrt(diag(stats::vcov(m)))

    estimates <- rep(NA_real_, length(all_terms))
    std_errors <- rep(NA_real_, length(all_terms))
    pvals <- rep(NA_real_, length(all_terms))

    for (i in seq_along(all_terms)) {
      term <- all_terms[i]
      if (term %in% names(coefs)) {
        idx <- which(names(coefs) == term)
        estimates[i] <- coefs[idx]
        std_errors[i] <- se[idx]
        z_stat <- coefs[idx] / se[idx]
        pvals[i] <- 2 * stats::pnorm(-abs(z_stat))
      }
    }

    if (exponentiate) {
      estimates <- exp(estimates)
    }

    formatted <- format_with_stars(estimates, pvals, stars, digits)
    se_formatted <- ifelse(is.na(std_errors), "",
                           paste0("(", round(std_errors, digits), ")"))
    formatted <- paste(formatted, se_formatted, sep = "\n")

    result[[model_name]] <- formatted
  }

  stats_rows <- build_rms_model_stats(models, digits)
  result <- rbind(result, stats_rows)

  do.call(t2f.default, c(list(x = result, filename = filename,
                              sub_dir = sub_dir), t2f_args))
}

#' Build model statistics rows for rms models
#' @keywords internal
build_rms_model_stats <- function(models, digits) {
  n_obs <- sapply(models, function(m) {
    if (!is.null(m$stats["Obs"])) m$stats["Obs"] else NA
  })

  r_squared <- sapply(models, function(m) {
    if (!is.null(m$stats["R2"])) round(m$stats["R2"], digits) else NA
  })

  c_index <- sapply(models, function(m) {
    if (!is.null(m$stats["C"])) round(m$stats["C"], digits) else NA
  })

  stats <- data.frame(Term = character(0), stringsAsFactors = FALSE)

  if (any(!is.na(n_obs))) {
    row <- data.frame(Term = "N", stringsAsFactors = FALSE)
    for (model_name in names(models)) {
      i <- which(names(models) == model_name)
      row[[model_name]] <- if (is.na(n_obs[i])) "" else as.character(n_obs[i])
    }
    stats <- rbind(stats, row)
  }

  if (any(!is.na(r_squared))) {
    row <- data.frame(Term = "R-squared", stringsAsFactors = FALSE)
    for (model_name in names(models)) {
      i <- which(names(models) == model_name)
      row[[model_name]] <- if (is.na(r_squared[i])) "" else
        as.character(r_squared[i])
    }
    stats <- rbind(stats, row)
  }

  if (any(!is.na(c_index))) {
    row <- data.frame(Term = "C-index", stringsAsFactors = FALSE)
    for (model_name in names(models)) {
      i <- which(names(models) == model_name)
      row[[model_name]] <- if (is.na(c_index[i])) "" else
        as.character(c_index[i])
    }
    stats <- rbind(stats, row)
  }

  stats
}
