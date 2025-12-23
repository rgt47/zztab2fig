# Tests for broom-based S3 methods

test_that("t2f_tidy requires broom package", {
  skip_if_not_installed("broom")

  model <- lm(mpg ~ cyl, data = mtcars)
  output_dir <- tempdir()

  result <- t2f_tidy(model, filename = "tidy_lm", sub_dir = output_dir)
  expect_true(file.exists(result))
})

test_that("t2f.coxph works with survival models", {
  skip_if_not_installed("broom")
  skip_if_not_installed("survival")

  library(survival)
  output_dir <- tempdir()

  model <- coxph(Surv(time, status) ~ age + sex, data = lung)
  result <- t2f(model, filename = "cox_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.coxph supports exponentiate option", {
  skip_if_not_installed("broom")
  skip_if_not_installed("survival")

  library(survival)
  output_dir <- tempdir()

  model <- coxph(Surv(time, status) ~ age + sex, data = lung)

  result1 <- t2f(model, exponentiate = FALSE,
                 filename = "cox_coef", sub_dir = output_dir)
  result2 <- t2f(model, exponentiate = TRUE,
                 filename = "cox_hr", sub_dir = output_dir)

  expect_true(file.exists(result1))
  expect_true(file.exists(result2))
})

test_that("t2f.survreg works with parametric survival models", {
  skip_if_not_installed("broom")
  skip_if_not_installed("survival")

  library(survival)
  output_dir <- tempdir()

  model <- survreg(Surv(time, status) ~ age + sex, data = lung)
  result <- t2f(model, filename = "survreg_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.survfit works with survival curves", {
  skip_if_not_installed("broom")
  skip_if_not_installed("survival")

  library(survival)
  output_dir <- tempdir()

  fit <- survfit(Surv(time, status) ~ sex, data = lung)
  result <- t2f(fit, filename = "survfit_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.nls works with nonlinear models", {
  skip_if_not_installed("broom")

  output_dir <- tempdir()

  model <- nls(mpg ~ a * exp(b * wt), data = mtcars,
               start = list(a = 40, b = -0.5))
  result <- t2f(model, filename = "nls_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.polr works with ordinal logistic regression", {
  skip_if_not_installed("broom")
  skip_if_not_installed("MASS")

  library(MASS)
  output_dir <- tempdir()

  model <- polr(factor(gear) ~ mpg + hp, data = mtcars)
  result <- t2f(model, filename = "polr_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.prcomp works with PCA", {
  output_dir <- tempdir()

  pca <- prcomp(mtcars[, 1:5], scale. = TRUE)

  result_rot <- t2f(pca, matrix = "rotation",
                    filename = "pca_loadings", sub_dir = output_dir)
  result_sum <- t2f(pca, matrix = "summary",
                    filename = "pca_summary", sub_dir = output_dir)

  expect_true(file.exists(result_rot))
  expect_true(file.exists(result_sum))
})

test_that("t2f.kmeans works with clustering results", {
  output_dir <- tempdir()

  km <- kmeans(mtcars[, 1:5], centers = 3)

  result_centers <- t2f(km, matrix = "centers",
                        filename = "km_centers", sub_dir = output_dir)
  result_summary <- t2f(km, matrix = "summary",
                        filename = "km_summary", sub_dir = output_dir)

  expect_true(file.exists(result_centers))
  expect_true(file.exists(result_summary))
})

test_that("t2f.lmerMod works with lme4 models", {
  skip_if_not_installed("broom.mixed")
  skip_if_not_installed("lme4")

  library(lme4)
  output_dir <- tempdir()

  model <- lmer(mpg ~ cyl + (1 | gear), data = mtcars)
  result <- t2f(model, filename = "lmer_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("t2f.lme works with nlme models", {
  skip_if_not_installed("broom.mixed")
  skip_if_not_installed("nlme")

  library(nlme)
  output_dir <- tempdir()

  model <- lme(mpg ~ cyl, random = ~ 1 | gear, data = mtcars)
  result <- t2f(model, filename = "lme_test", sub_dir = output_dir)

  expect_true(file.exists(result))
})

test_that("check_broom errors without broom", {
  skip_if(requireNamespace("broom", quietly = TRUE))

  expect_error(check_broom(), "Package 'broom' is required")
})

test_that("round_numeric_cols rounds correctly", {
  df <- data.frame(
    a = c(1.2345, 2.3456),
    b = c("x", "y"),
    c = c(3.4567, 4.5678)
  )

  result <- round_numeric_cols(df, 2)

  expect_equal(result$a, c(1.23, 2.35))
  expect_equal(result$b, c("x", "y"))
  expect_equal(result$c, c(3.46, 4.57))
})
