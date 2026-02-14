# Tests for rms package S3 methods

test_that("t2f.ols works with rms ordinary least squares", {
  skip_if_not_installed("rms")
  skip_if_no_latex()

  library(rms)
  output_dir <- tempdir()

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- ols(mpg ~ wt + cyl, data = mtcars)
  result <- t2f(model, filename = "ols_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.ols supports anova output", {
  skip_if_not_installed("rms")
  skip_if_no_latex()

  library(rms)
  output_dir <- tempdir()

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- ols(mpg ~ rcs(wt, 4) + cyl, data = mtcars)
  result <- t2f(model, output = "anova",
                filename = "ols_anova_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.lrm works with rms logistic regression", {
  skip_if_not_installed("rms")
  skip_if_no_latex()

  library(rms)
  output_dir <- tempdir()

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- lrm(am ~ mpg + wt, data = mtcars)
  result <- t2f(model, filename = "lrm_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.lrm supports exponentiate option", {
  skip_if_not_installed("rms")
  skip_if_no_latex()

  library(rms)
  output_dir <- tempdir()

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- lrm(am ~ mpg + wt, data = mtcars)

  result1 <- t2f(model, exponentiate = FALSE,
                 filename = "lrm_coef", sub_dir = output_dir)
  result2 <- t2f(model, exponentiate = TRUE,
                 filename = "lrm_or", sub_dir = output_dir)

  expect_true(file.exists(result1))
  expect_true(file.exists(result2))
})

test_that("t2f.cph works with rms Cox models", {
  skip_if_not_installed("rms")
  skip_if_not_installed("survival")
  skip_if_no_latex()

  library(rms)
  library(survival)
  output_dir <- tempdir()

  dd <- datadist(lung)
  options(datadist = "dd")

  model <- cph(Surv(time, status) ~ age + sex, data = lung)
  result <- t2f(model, filename = "cph_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.cph supports exponentiate for hazard ratios", {
  skip_if_not_installed("rms")
  skip_if_not_installed("survival")
  skip_if_no_latex()

  library(rms)
  library(survival)
  output_dir <- tempdir()

  dd <- datadist(lung)
  options(datadist = "dd")

  model <- cph(Surv(time, status) ~ age + sex, data = lung)

  result1 <- t2f(model, exponentiate = FALSE,
                 filename = "cph_coef", sub_dir = output_dir)
  result2 <- t2f(model, exponentiate = TRUE,
                 filename = "cph_hr", sub_dir = output_dir)

  expect_true(file.exists(result1))
  expect_true(file.exists(result2))
})

test_that("t2f.cph supports anova output", {
  skip_if_not_installed("rms")
  skip_if_not_installed("survival")
  skip_if_no_latex()

  library(rms)
  library(survival)
  output_dir <- tempdir()

  dd <- datadist(lung)
  options(datadist = "dd")

  model <- cph(Surv(time, status) ~ age + sex, data = lung)
  result <- t2f(model, output = "anova",
                filename = "cph_anova", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.orm works with rms ordinal regression", {
  skip_if_not_installed("rms")
  skip_if_no_latex()

  library(rms)
  output_dir <- tempdir()

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- orm(gear ~ mpg + wt, data = mtcars)
  result <- t2f(model, filename = "orm_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.orm intercepts parameter works", {
  skip_if_not_installed("rms")
  skip_if_no_latex()

  library(rms)
  output_dir <- tempdir()

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- orm(gear ~ mpg + wt, data = mtcars)

  result1 <- t2f(model, intercepts = FALSE,
                 filename = "orm_no_int", sub_dir = output_dir)
  result2 <- t2f(model, intercepts = TRUE,
                 filename = "orm_with_int", sub_dir = output_dir)

  expect_true(file.exists(result1))
  expect_true(file.exists(result2))
})

test_that("t2f.Glm works with rms generalized linear models", {
  skip_if_not_installed("rms")
  skip_if_no_latex()

  library(rms)
  output_dir <- tempdir()

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- Glm(am ~ mpg + wt, data = mtcars, family = binomial)
  result <- t2f(model, filename = "Glm_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.psm works with rms parametric survival models", {
  skip_if_not_installed("rms")
  skip_if_not_installed("survival")
  skip_if_no_latex()

  library(rms)
  library(survival)
  output_dir <- tempdir()

  dd <- datadist(lung)
  options(datadist = "dd")

  model <- psm(Surv(time, status) ~ age + sex, data = lung, dist = "weibull")
  result <- t2f(model, filename = "psm_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f_rms_compare creates model comparison table", {
  skip_if_not_installed("rms")
  skip_if_no_latex()

  library(rms)
  output_dir <- tempdir()

  dd <- datadist(mtcars)
  options(datadist = "dd")

  m1 <- ols(mpg ~ wt, data = mtcars)
  m2 <- ols(mpg ~ wt + cyl, data = mtcars)
  m3 <- ols(mpg ~ wt + cyl + hp, data = mtcars)

  result <- t2f_rms_compare(
    Model1 = m1, Model2 = m2, Model3 = m3,
    filename = "rms_compare_test",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("extract_rms_coefs returns correct structure", {
  skip_if_not_installed("rms")

  library(rms)

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- ols(mpg ~ wt + cyl, data = mtcars)
  result <- extract_rms_coefs(model, digits = 3)

  expect_s3_class(result, "data.frame")
  expect_true("Term" %in% names(result))
  expect_true("Estimate" %in% names(result))
  expect_true("Std. Error" %in% names(result))
  expect_true("p value" %in% names(result))
})

test_that("extract_rms_coefs handles exponentiation", {
  skip_if_not_installed("rms")

  library(rms)

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- lrm(am ~ mpg, data = mtcars)

  result_raw <- extract_rms_coefs(model, exponentiate = FALSE)
  result_exp <- extract_rms_coefs(model, exponentiate = TRUE)

  expect_true("Estimate" %in% names(result_raw))
  expect_true("OR" %in% names(result_exp))
})

test_that("extract_rms_anova returns correct structure", {
  skip_if_not_installed("rms")

  library(rms)

  dd <- datadist(mtcars)
  options(datadist = "dd")

  model <- ols(mpg ~ rcs(wt, 4) + cyl, data = mtcars)
  result <- extract_rms_anova(model, digits = 3)

  expect_s3_class(result, "data.frame")
  expect_true("Term" %in% names(result) || ncol(result) > 0
  )
})

test_that("check_rms errors without rms package", {
  skip_if(requireNamespace("rms", quietly = TRUE))

  expect_error(check_rms(), "Package 'rms' is required")
})
