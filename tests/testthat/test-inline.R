# Tests for inline table functions

test_that("t2f_inline generates PDF output", {
  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:5, 1:3],
    format = "pdf",
    filename = "inline_test_pdf",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
  expect_match(result, "\\.pdf$")
})

test_that("t2f_inline generates PNG output", {
  skip_if_not(nzchar(Sys.which("convert")), "ImageMagick not available")

  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:5, 1:3],
    format = "png",
    filename = "inline_test_png",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
  expect_match(result, "\\.png$")
})

test_that("t2f_inline accepts width parameter", {
  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:3, 1:2],
    width = "3in",
    format = "pdf",
    filename = "inline_width",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("t2f_inline accepts align parameter", {
  output_dir <- tempdir()

  result_left <- t2f_inline(
    mtcars[1:3, 1:2],
    align = "left",
    format = "pdf",
    filename = "inline_align_left",
    sub_dir = output_dir
  )

  result_right <- t2f_inline(
    mtcars[1:3, 1:2],
    align = "right",
    format = "pdf",
    filename = "inline_align_right",
    sub_dir = output_dir
  )

  expect_true(file.exists(result_left))
  expect_true(file.exists(result_right))
})

test_that("t2f_inline works with lm objects", {
  output_dir <- tempdir()
  model <- lm(mpg ~ cyl + hp, data = mtcars)

  result <- t2f_inline(
    model,
    format = "pdf",
    filename = "inline_lm",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("t2f_coef generates coefficient table", {
  output_dir <- tempdir()
  model <- lm(mpg ~ cyl + hp + wt, data = mtcars)

  result <- t2f_coef(
    model,
    filename = "coef_test",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("t2f_coef uses default width", {
  output_dir <- tempdir()
  model <- lm(mpg ~ cyl, data = mtcars)

  result <- t2f_coef(
    model,
    filename = "coef_default_width",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("t2f_inline auto-generates filename if NULL", {
  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:3, 1:2],
    filename = NULL,
    format = "pdf",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
  expect_match(basename(result), "^t2f_inline_")
})

test_that("t2f_inline accepts caption and label", {
  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:3, 1:2],
    caption = "Test caption",
    label = "tab:test",
    format = "pdf",
    filename = "inline_caption_label",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("t2f_coef accepts caption and label", {
  output_dir <- tempdir()
  model <- lm(mpg ~ cyl, data = mtcars)

  result <- t2f_coef(
    model,
    caption = "Model coefficients",
    label = "tab:coef",
    filename = "coef_caption_label",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})
