has_latex <- function() {
  has_pdflatex <- suppressWarnings(
    system("pdflatex --version",
      ignore.stdout = TRUE, ignore.stderr = TRUE
    )
  ) == 0
  if (!has_pdflatex) return(FALSE)

  temp_dir <- tempdir()
  tex_file <- file.path(temp_dir, "test_latex.tex")
  writeLines(c(
    "\\documentclass{article}",
    "\\usepackage{booktabs}",
    "\\begin{document}",
    "test",
    "\\end{document}"
  ), tex_file)

  old_wd <- setwd(temp_dir)
  on.exit(setwd(old_wd))

  result <- suppressWarnings(
    system("pdflatex -interaction=batchmode test_latex.tex",
      ignore.stdout = TRUE, ignore.stderr = TRUE
    )
  )
  result == 0
}


# --- Non-LaTeX tests ---

# round_numeric_cols
df <- data.frame(
  a = c(1.2345, 2.3456),
  b = c("x", "y"),
  c = c(3.4567, 4.5678)
)
result <- round_numeric_cols(df, 2)
expect_equal(result$a, c(1.23, 2.35))
expect_equal(result$b, c("x", "y"))
expect_equal(result$c, c(3.46, 4.57))

# check_broom errors without broom (only runs if broom absent)
if (!requireNamespace("broom", quietly = TRUE)) {
  expect_error(check_broom(), "Package 'broom' is required")
}


# --- LaTeX-dependent tests ---

if (!has_latex()) exit_file("pdflatex not available")

output_dir <- tempdir()

# t2f_tidy with broom
if (requireNamespace("broom", quietly = TRUE)) {
  model <- lm(mpg ~ cyl, data = mtcars)
  result <- t2f_tidy(
    model, filename = "tidy_lm", sub_dir = output_dir
  )
  expect_true(file.exists(result))
}

# t2f.coxph with survival models
if (requireNamespace("broom", quietly = TRUE) &&
    requireNamespace("survival", quietly = TRUE)) {
  library(survival)

  model <- coxph(Surv(time, status) ~ age + sex, data = lung)
  result <- t2f(
    model, filename = "cox_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))

  # exponentiate option
  result1 <- t2f(
    model, exponentiate = FALSE,
    filename = "cox_coef", sub_dir = output_dir
  )
  result2 <- t2f(
    model, exponentiate = TRUE,
    filename = "cox_hr", sub_dir = output_dir
  )
  expect_true(file.exists(result1))
  expect_true(file.exists(result2))

  # survreg
  model2 <- survreg(
    Surv(time, status) ~ age + sex, data = lung
  )
  result <- t2f(
    model2, filename = "survreg_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))

  # survfit
  fit <- survfit(Surv(time, status) ~ sex, data = lung)
  result <- t2f(
    fit, filename = "survfit_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))
}

# t2f.nls
if (requireNamespace("broom", quietly = TRUE)) {
  model <- nls(
    mpg ~ a * exp(b * wt), data = mtcars,
    start = list(a = 40, b = -0.5)
  )
  result <- t2f(
    model, filename = "nls_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))
}

# t2f.polr with MASS
if (requireNamespace("broom", quietly = TRUE) &&
    requireNamespace("MASS", quietly = TRUE)) {
  library(MASS)
  model <- polr(factor(gear) ~ mpg + hp, data = mtcars)
  result <- t2f(
    model, filename = "polr_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))
}

# t2f.prcomp (no broom needed)
pca <- prcomp(mtcars[, 1:5], scale. = TRUE)
result_rot <- t2f(
  pca, matrix = "rotation",
  filename = "pca_loadings", sub_dir = output_dir
)
result_sum <- t2f(
  pca, matrix = "summary",
  filename = "pca_summary", sub_dir = output_dir
)
expect_true(file.exists(result_rot))
expect_true(file.exists(result_sum))

# t2f.kmeans (no broom needed)
km <- kmeans(mtcars[, 1:5], centers = 3)
result_centers <- t2f(
  km, matrix = "centers",
  filename = "km_centers", sub_dir = output_dir
)
result_summary <- t2f(
  km, matrix = "summary",
  filename = "km_summary", sub_dir = output_dir
)
expect_true(file.exists(result_centers))
expect_true(file.exists(result_summary))

# t2f.lmerMod with lme4
if (requireNamespace("broom.mixed", quietly = TRUE) &&
    requireNamespace("lme4", quietly = TRUE)) {
  library(lme4)
  model <- lmer(mpg ~ cyl + (1 | gear), data = mtcars)
  result <- t2f(
    model, filename = "lmer_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))
}

# t2f.lme with nlme
if (requireNamespace("broom.mixed", quietly = TRUE) &&
    requireNamespace("nlme", quietly = TRUE)) {
  library(nlme)
  model <- lme(mpg ~ cyl, random = ~ 1 | gear, data = mtcars)
  result <- t2f(
    model, filename = "lme_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))
}
