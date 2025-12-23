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

test_that("build_inline_latex generates correct LaTeX for caption above", {
  result <- zztab2fig:::build_inline_latex(
    path = "test.pdf",
    width = "3in",
    height = NULL,
    align = "center",
    caption = "Test caption",
    caption_short = NULL,
    label = "tab:test",
    caption_position = "above"
  )

  expect_match(result, "\\\\begin\\{center\\}")
  expect_match(result, "\\\\captionof\\{table\\}\\{Test caption\\}")
  expect_match(result, "\\\\label\\{tab:test\\}")
  expect_match(result, "\\\\includegraphics\\[width=3in\\]\\{test.pdf\\}")

  lines <- strsplit(result, "\n")[[1]]
  caption_line <- grep("captionof", lines)
  include_line <- grep("includegraphics", lines)
  expect_true(caption_line < include_line)
})

test_that("build_inline_latex generates correct LaTeX for caption below", {
  result <- zztab2fig:::build_inline_latex(
    path = "test.pdf",
    width = "2in",
    height = NULL,
    align = "left",
    caption = "Below caption",
    caption_short = NULL,
    label = NULL,
    caption_position = "below"
  )

  expect_match(result, "\\\\begin\\{flushleft\\}")
  expect_match(result, "\\\\captionof\\{table\\}\\{Below caption\\}")
  expect_match(result, "\\\\includegraphics\\[width=2in\\]\\{test.pdf\\}")

  lines <- strsplit(result, "\n")[[1]]
  caption_line <- grep("captionof", lines)
  include_line <- grep("includegraphics", lines)
  expect_true(caption_line > include_line)
})

test_that("build_inline_latex handles short caption", {
  result <- zztab2fig:::build_inline_latex(
    path = "test.pdf",
    width = NULL,
    height = NULL,
    align = "center",
    caption = "A very long caption for the table",
    caption_short = "Short caption",
    label = "tab:short",
    caption_position = "above"
  )

  expect_match(result, "\\\\captionof\\{table\\}\\[Short caption\\]\\{A very long caption")
})

test_that("build_inline_latex works without caption", {
  result <- zztab2fig:::build_inline_latex(
    path = "test.pdf",
    width = "4in",
    height = NULL,
    align = "right",
    caption = NULL,
    caption_short = NULL,
    label = NULL,
    caption_position = "above"
  )

  expect_match(result, "\\\\begin\\{flushright\\}")
  expect_match(result, "\\\\includegraphics\\[width=4in\\]\\{test.pdf\\}")
  expect_false(grepl("captionof", result))
})

test_that("t2f_inline accepts caption_position parameter", {
  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:3, 1:2],
    caption = "Test",
    caption_position = "below",
    format = "pdf",
    filename = "inline_caption_below",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("build_inline_latex generates frame with fcolorbox", {
  result <- zztab2fig:::build_inline_latex(
    path = "test.pdf",
    width = "3in",
    height = NULL,
    align = "center",
    caption = NULL,
    caption_short = NULL,
    label = NULL,
    caption_position = "above",
    frame = TRUE,
    frame_color = "black",
    frame_width = "0.4pt",
    background = NULL,
    inner_sep = "2pt"
  )

  expect_match(result, "\\\\fcolorbox\\{black\\}\\{white\\}")
  expect_match(result, "\\\\setlength\\{\\\\fboxsep\\}\\{2pt\\}")
  expect_match(result, "\\\\setlength\\{\\\\fboxrule\\}\\{0.4pt\\}")
})

test_that("build_inline_latex generates background with colorbox", {
  result <- zztab2fig:::build_inline_latex(
    path = "test.pdf",
    width = "3in",
    height = NULL,
    align = "center",
    caption = NULL,
    caption_short = NULL,
    label = NULL,
    caption_position = "above",
    frame = FALSE,
    frame_color = "black",
    frame_width = "0.4pt",
    background = "gray!10",
    inner_sep = "4pt"
  )

  expect_match(result, "\\\\colorbox\\{gray!10\\}")
  expect_match(result, "\\\\setlength\\{\\\\fboxsep\\}\\{4pt\\}")
  expect_false(grepl("fcolorbox", result))
})

test_that("build_inline_latex generates frame with background using fcolorbox", {
  result <- zztab2fig:::build_inline_latex(
    path = "test.pdf",
    width = "3in",
    height = NULL,
    align = "center",
    caption = NULL,
    caption_short = NULL,
    label = NULL,
    caption_position = "above",
    frame = TRUE,
    frame_color = "blue!50",
    frame_width = "1pt",
    background = "blue!5",
    inner_sep = "3pt"
  )

  expect_match(result, "\\\\fcolorbox\\{blue!50\\}\\{blue!5\\}")
  expect_match(result, "\\\\setlength\\{\\\\fboxsep\\}\\{3pt\\}")
  expect_match(result, "\\\\setlength\\{\\\\fboxrule\\}\\{1pt\\}")
})

test_that("build_inline_latex without frame or background has no box commands", {
  result <- zztab2fig:::build_inline_latex(
    path = "test.pdf",
    width = "3in",
    height = NULL,
    align = "center",
    caption = NULL,
    caption_short = NULL,
    label = NULL,
    caption_position = "above",
    frame = FALSE,
    frame_color = "black",
    frame_width = "0.4pt",
    background = NULL,
    inner_sep = "2pt"
  )

  expect_false(grepl("fcolorbox", result))
  expect_false(grepl("colorbox", result))
  expect_false(grepl("fboxsep", result))
})

test_that("t2f_inline accepts frame parameters", {
  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:3, 1:2],
    frame = TRUE,
    frame_color = "gray",
    frame_width = "0.5pt",
    format = "pdf",
    filename = "inline_frame",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("t2f_inline accepts background parameter", {
  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:3, 1:2],
    background = "yellow!10",
    format = "pdf",
    filename = "inline_background",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("t2f_inline accepts frame and background together", {
  output_dir <- tempdir()

  result <- t2f_inline(
    mtcars[1:3, 1:2],
    frame = TRUE,
    frame_color = "blue!50",
    background = "blue!5",
    inner_sep = "4pt",
    format = "pdf",
    filename = "inline_frame_bg",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})

test_that("t2f_coef accepts frame parameters", {
  output_dir <- tempdir()
  model <- lm(mpg ~ cyl, data = mtcars)

  result <- t2f_coef(
    model,
    frame = TRUE,
    background = "gray!5",
    filename = "coef_frame",
    sub_dir = output_dir
  )

  expect_true(file.exists(result))
})
