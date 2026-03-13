if (!requireNamespace("rms", quietly = TRUE)) {
  exit_file("rms not installed")
}

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

library(rms)


# --- Non-LaTeX tests ---

# extract_rms_coefs returns correct structure
dd <- datadist(mtcars)
options(datadist = "dd")

model <- ols(mpg ~ wt + cyl, data = mtcars)
result <- extract_rms_coefs(model, digits = 3)
expect_inherits(result, "data.frame")
expect_true("Term" %in% names(result))
expect_true("Estimate" %in% names(result))
expect_true("Std. Error" %in% names(result))
expect_true("p value" %in% names(result))

# extract_rms_coefs handles exponentiation
model <- lrm(am ~ mpg, data = mtcars)
result_raw <- extract_rms_coefs(model, exponentiate = FALSE)
result_exp <- extract_rms_coefs(model, exponentiate = TRUE)
expect_true("Estimate" %in% names(result_raw))
expect_true("OR" %in% names(result_exp))

# extract_rms_anova returns correct structure
model <- ols(mpg ~ rcs(wt, 4) + cyl, data = mtcars)
result <- extract_rms_anova(model, digits = 3)
expect_inherits(result, "data.frame")
expect_true("Term" %in% names(result) || ncol(result) > 0)

# check_rms errors without rms (only runs if rms absent)
if (!requireNamespace("rms", quietly = TRUE)) {
  expect_error(check_rms(), "Package 'rms' is required")
}


# --- LaTeX-dependent tests ---

if (!has_latex()) exit_file("pdflatex not available")

output_dir <- tempdir()
dd <- datadist(mtcars)
options(datadist = "dd")

# t2f.ols
model <- ols(mpg ~ wt + cyl, data = mtcars)
result <- t2f(
  model, filename = "ols_test", sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f.ols with anova output
model <- ols(mpg ~ rcs(wt, 4) + cyl, data = mtcars)
result <- t2f(
  model, output = "anova",
  filename = "ols_anova_test", sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f.lrm
model <- lrm(am ~ mpg + wt, data = mtcars)
result <- t2f(
  model, filename = "lrm_test", sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f.lrm with exponentiate
result1 <- t2f(
  model, exponentiate = FALSE,
  filename = "lrm_coef", sub_dir = output_dir
)
result2 <- t2f(
  model, exponentiate = TRUE,
  filename = "lrm_or", sub_dir = output_dir
)
expect_true(file.exists(result1))
expect_true(file.exists(result2))

# t2f.cph
if (requireNamespace("survival", quietly = TRUE)) {
  library(survival)

  dd_lung <- datadist(lung)
  options(datadist = "dd_lung")

  model <- cph(Surv(time, status) ~ age + sex, data = lung)
  result <- t2f(
    model, filename = "cph_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))

  # exponentiate for hazard ratios
  result1 <- t2f(
    model, exponentiate = FALSE,
    filename = "cph_coef", sub_dir = output_dir
  )
  result2 <- t2f(
    model, exponentiate = TRUE,
    filename = "cph_hr", sub_dir = output_dir
  )
  expect_true(file.exists(result1))
  expect_true(file.exists(result2))

  # anova output
  result <- t2f(
    model, output = "anova",
    filename = "cph_anova", sub_dir = output_dir
  )
  expect_true(file.exists(result))

  # t2f.psm
  model <- psm(
    Surv(time, status) ~ age + sex,
    data = lung, dist = "weibull"
  )
  result <- t2f(
    model, filename = "psm_test", sub_dir = output_dir
  )
  expect_true(file.exists(result))

  options(datadist = "dd")
}

# t2f.orm
model <- orm(gear ~ mpg + wt, data = mtcars)
result <- t2f(
  model, filename = "orm_test", sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f.orm intercepts parameter
result1 <- t2f(
  model, intercepts = FALSE,
  filename = "orm_no_int", sub_dir = output_dir
)
result2 <- t2f(
  model, intercepts = TRUE,
  filename = "orm_with_int", sub_dir = output_dir
)
expect_true(file.exists(result1))
expect_true(file.exists(result2))

# t2f.Glm
model <- Glm(am ~ mpg + wt, data = mtcars, family = binomial)
result <- t2f(
  model, filename = "Glm_test", sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_rms_compare
m1 <- ols(mpg ~ wt, data = mtcars)
m2 <- ols(mpg ~ wt + cyl, data = mtcars)
m3 <- ols(mpg ~ wt + cyl + hp, data = mtcars)
result <- t2f_rms_compare(
  Model1 = m1, Model2 = m2, Model3 = m3,
  filename = "rms_compare_test",
  sub_dir = output_dir
)
expect_true(file.exists(result))
