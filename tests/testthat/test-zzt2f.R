# Tests for zzt2f() Typst backend

# --- Color translation ---

test_that("translate_latex_color passes hex through unchanged", {
  expect_equal(
    zztab2fig:::translate_latex_color("#FF0000"),
    "#FF0000"
  )
  expect_equal(
    zztab2fig:::translate_latex_color("#aabbcc"),
    "#AABBCC"
  )
})

test_that("translate_latex_color handles named LaTeX colors", {
  expect_equal(zztab2fig:::translate_latex_color("red"), "#FF0000")
  expect_equal(zztab2fig:::translate_latex_color("blue"), "#0000FF")
  expect_equal(zztab2fig:::translate_latex_color("white"), "#FFFFFF")
  expect_equal(zztab2fig:::translate_latex_color("black"), "#000000")
})

test_that("translate_latex_color handles color!N mixing syntax", {
  result <- zztab2fig:::translate_latex_color("blue!10")
  expect_match(result, "^#[0-9A-F]{6}$")
  rgb <- grDevices::col2rgb(result)[, 1]
  expect_true(rgb[3] > rgb[1])

  pure_white <- zztab2fig:::translate_latex_color("blue!0")
  expect_equal(pure_white, "#FFFFFF")

  pure_blue <- zztab2fig:::translate_latex_color("blue!100")
  expect_equal(pure_blue, "#0000FF")
})

test_that("translate_latex_color handles gray!5", {
  result <- zztab2fig:::translate_latex_color("gray!5")
  expect_match(result, "^#[0-9A-F]{6}$")
  rgb <- grDevices::col2rgb(result)[, 1]
  expect_true(all(rgb > 240))
})

test_that("translate_latex_color handles nejmshade", {
  expect_equal(zztab2fig:::translate_latex_color("nejmshade"), "#FEF8EA")
})

test_that("translate_latex_color returns NULL for NULL input", {
  expect_null(zztab2fig:::translate_latex_color(NULL))
})

test_that("translate_latex_color warns for unknown colors", {
  expect_warning(
    result <- zztab2fig:::translate_latex_color("xyzcolor"),
    "Unrecognized color"
  )
  expect_match(result, "^#[0-9A-F]{6}$")
})

test_that("translate_latex_color warns for unknown base in mix syntax", {
  expect_warning(
    zztab2fig:::translate_latex_color("xyzcolor!50"),
    "Unknown LaTeX color"
  )
})

# --- Font size translation ---

test_that("translate_font_size maps standard LaTeX sizes", {
  expect_equal(zztab2fig:::translate_font_size("footnotesize"), 8)
  expect_equal(zztab2fig:::translate_font_size("small"), 9)
  expect_equal(zztab2fig:::translate_font_size("normalsize"), 10)
  expect_equal(zztab2fig:::translate_font_size("tiny"), 5)
  expect_equal(zztab2fig:::translate_font_size("large"), 12)
})

test_that("translate_font_size returns NULL for NULL input", {
  expect_null(zztab2fig:::translate_font_size(NULL))
})

test_that("translate_font_size handles numeric strings", {
  expect_equal(zztab2fig:::translate_font_size("11"), 11)
  expect_equal(zztab2fig:::translate_font_size("8.5"), 8.5)
})

test_that("translate_font_size warns for unknown sizes", {
  expect_warning(
    result <- zztab2fig:::translate_font_size("notasize"),
    "Unknown LaTeX font size"
  )
  expect_equal(result, 10)
})

# --- Footnote translation ---

test_that("translate_footnote handles NULL", {
  expect_null(zztab2fig:::translate_footnote(NULL))
})

test_that("translate_footnote rejects non-t2f_footnote input", {
  expect_error(
    zztab2fig:::translate_footnote("plain string"),
    "must be a t2f_footnote"
  )
})

test_that("translate_footnote converts general notes", {
  fn <- t2f_footnote(general = c("Note 1.", "Note 2."))
  result <- zztab2fig:::translate_footnote(fn)
  expect_equal(result, c("Note 1.", "Note 2."))
})

test_that("translate_footnote converts numbered notes", {
  fn <- t2f_footnote(number = c("First", "Second"))
  result <- zztab2fig:::translate_footnote(fn)
  expect_equal(result, c("1. First", "2. Second"))
})

test_that("translate_footnote converts alphabetic notes", {
  fn <- t2f_footnote(alphabet = c("Alpha", "Beta"))
  result <- zztab2fig:::translate_footnote(fn)
  expect_equal(result, c("a. Alpha", "b. Beta"))
})

test_that("translate_footnote converts symbol notes", {
  fn <- t2f_footnote(symbol = c("p < 0.05", "p < 0.01"))
  result <- zztab2fig:::translate_footnote(fn)
  expect_length(result, 2)
  expect_true(grepl("p", result[1], fixed = TRUE))
  expect_true(grepl("0.05", result[1], fixed = TRUE))
  expect_true(grepl("p", result[2], fixed = TRUE))
  expect_true(grepl("0.01", result[2], fixed = TRUE))
})

test_that("translate_footnote combines all note types", {
  fn <- t2f_footnote(
    general = "General note.",
    number = "Numbered note.",
    alphabet = "Lettered note.",
    symbol = "Symbol note."
  )
  result <- zztab2fig:::translate_footnote(fn)
  expect_length(result, 4)
})

test_that("translate_footnote returns NULL for empty footnote", {
  fn <- t2f_footnote()
  result <- zztab2fig:::translate_footnote(fn)
  expect_null(result)
})

# --- Header translation ---

test_that("translate_header_above handles NULL", {
  expect_null(zztab2fig:::translate_header_above(NULL))
})

test_that("translate_header_above converts single header", {
  hdr <- t2f_header_above(" " = 1, "Treatment" = 2, "Control" = 2)
  result <- zztab2fig:::translate_header_above(hdr)
  expect_type(result, "list")
  expect_true("Treatment" %in% names(result))
  expect_true("Control" %in% names(result))
  expect_equal(result$Treatment, 2:3)
  expect_equal(result$Control, 4:5)
})

test_that("translate_header_above skips blank labels", {
  hdr <- t2f_header_above(" " = 2, "Group" = 3)
  result <- zztab2fig:::translate_header_above(hdr)
  expect_false(" " %in% names(result))
  expect_true("Group" %in% names(result))
  expect_equal(result$Group, 3:5)
})

test_that("translate_header_above handles list of headers", {
  hdr1 <- t2f_header_above(" " = 1, "A" = 2)
  hdr2 <- t2f_header_above(" " = 1, "B" = 2)
  result <- zztab2fig:::translate_header_above(list(hdr1, hdr2))
  expect_type(result, "list")
  expect_length(result, 2)
})

# --- resolve_typst_theme ---

test_that("resolve_typst_theme returns valid structure", {
  ts <- zztab2fig:::resolve_typst_theme(NULL)
  expect_type(ts, "list")
  expect_true("stripe_color" %in% names(ts))
  expect_true("header_bold" %in% names(ts))
  expect_true("font_size" %in% names(ts))
  expect_true("striped" %in% names(ts))
})

test_that("resolve_typst_theme translates nejm theme", {
  ts <- zztab2fig:::resolve_typst_theme("nejm")
  expect_equal(ts$stripe_color, "#FEF8EA")
  expect_true(ts$header_bold)
  expect_equal(ts$font_size, 8)
  expect_true(ts$striped)
})

test_that("resolve_typst_theme translates apa theme", {
  ts <- zztab2fig:::resolve_typst_theme("apa")
  expect_null(ts$stripe_color)
  expect_false(ts$striped)
})

test_that("resolve_typst_theme respects scolor override", {
  ts <- zztab2fig:::resolve_typst_theme("apa", scolor = "red!20")
  expect_match(ts$stripe_color, "^#[0-9A-F]{6}$")
})

# --- Input validation ---

test_that("zzt2f rejects non-data.frame input", {
  skip_if_not_installed("tinytable")
  expect_error(zzt2f("not a df"), "must be a data.frame")
})

test_that("zzt2f rejects empty data frame", {
  skip_if_not_installed("tinytable")
  expect_error(zzt2f(data.frame()), "must not be empty")
})

test_that("zzt2f rejects invalid align", {
  skip_if_not_installed("tinytable")
  expect_error(
    zzt2f(mtcars[1:3, 1:3], align = c("x", "y", "z")),
    "must contain only"
  )
})

test_that("zzt2f rejects invalid dpi", {
  skip_if_not_installed("tinytable")
  expect_error(
    zzt2f(mtcars[1:3, 1:3], dpi = -1),
    "must be a positive"
  )
})

test_that("zzt2f rejects invalid footnote", {
  skip_if_not_installed("tinytable")
  expect_error(
    zzt2f(mtcars[1:3, 1:3], footnote = "not a footnote"),
    "must be a t2f_footnote"
  )
})

# --- check_typst_deps ---

test_that("check_typst_deps returns list with expected fields", {
  result <- suppressMessages(check_typst_deps())
  expect_type(result, "list")
  expect_true("tinytable" %in% names(result))
  expect_true("typst" %in% names(result))
  expect_true("ready" %in% names(result))
})

# --- Integration tests (require tinytable + typst) ---

skip_if_no_typst <- function() {
  if (!requireNamespace("tinytable", quietly = TRUE)) {
    testthat::skip("tinytable not installed")
  }
  if (!nzchar(Sys.which("typst"))) {
    testthat::skip("Typst CLI not available")
  }
}

test_that("zzt2f produces PDF from data.frame", {
  skip_if_no_typst()
  tmp <- tempdir()
  out_dir <- file.path(tmp, "zzt2f_test_pdf")
  dir.create(out_dir, showWarnings = FALSE)
  on.exit(unlink(out_dir, recursive = TRUE))

  result <- zzt2f(
    mtcars[1:5, 1:4],
    filename = "test_pdf",
    sub_dir = out_dir,
    format = "pdf"
  )
  expect_true(file.exists(result))
  expect_match(result, "\\.pdf$")
})

test_that("zzt2f produces PNG with custom dpi", {
  skip_if_no_typst()
  tmp <- tempdir()
  out_dir <- file.path(tmp, "zzt2f_test_png")
  dir.create(out_dir, showWarnings = FALSE)
  on.exit(unlink(out_dir, recursive = TRUE))

  result <- zzt2f(
    mtcars[1:5, 1:4],
    filename = "test_png",
    sub_dir = out_dir,
    format = "png",
    dpi = 150L
  )
  expect_true(file.exists(result))
  expect_match(result, "\\.png$")
})

test_that("zzt2f produces SVG", {
  skip_if_no_typst()
  tmp <- tempdir()
  out_dir <- file.path(tmp, "zzt2f_test_svg")
  dir.create(out_dir, showWarnings = FALSE)
  on.exit(unlink(out_dir, recursive = TRUE))

  result <- zzt2f(
    mtcars[1:5, 1:4],
    filename = "test_svg",
    sub_dir = out_dir,
    format = "svg"
  )
  expect_true(file.exists(result))
  expect_match(result, "\\.svg$")
})

test_that("zzt2f applies nejm theme", {
  skip_if_no_typst()
  tmp <- tempdir()
  out_dir <- file.path(tmp, "zzt2f_test_nejm")
  dir.create(out_dir, showWarnings = FALSE)
  on.exit(unlink(out_dir, recursive = TRUE))

  result <- zzt2f(
    mtcars[1:5, 1:4],
    filename = "test_nejm",
    sub_dir = out_dir,
    theme = "nejm",
    format = "pdf"
  )
  expect_true(file.exists(result))
})

test_that("zzt2f applies apa theme", {
  skip_if_no_typst()
  tmp <- tempdir()
  out_dir <- file.path(tmp, "zzt2f_test_apa")
  dir.create(out_dir, showWarnings = FALSE)
  on.exit(unlink(out_dir, recursive = TRUE))

  result <- zzt2f(
    mtcars[1:5, 1:4],
    filename = "test_apa",
    sub_dir = out_dir,
    theme = "apa",
    format = "pdf"
  )
  expect_true(file.exists(result))
})

test_that("zzt2f handles caption and footnotes", {
  skip_if_no_typst()
  tmp <- tempdir()
  out_dir <- file.path(tmp, "zzt2f_test_caption")
  dir.create(out_dir, showWarnings = FALSE)
  on.exit(unlink(out_dir, recursive = TRUE))

  fn <- t2f_footnote(
    general = "Data from mtcars.",
    symbol = c("p < 0.05")
  )

  result <- zzt2f(
    mtcars[1:5, 1:4],
    filename = "test_caption",
    sub_dir = out_dir,
    caption = "Motor Trend Cars",
    footnote = fn,
    format = "pdf"
  )
  expect_true(file.exists(result))
})

test_that("zzt2f handles matrix input", {
  skip_if_no_typst()
  tmp <- tempdir()
  out_dir <- file.path(tmp, "zzt2f_test_matrix")
  dir.create(out_dir, showWarnings = FALSE)
  on.exit(unlink(out_dir, recursive = TRUE))

  m <- matrix(1:12, nrow = 3, dimnames = list(NULL, c("A", "B", "C", "D")))
  result <- zzt2f(m, filename = "test_matrix", sub_dir = out_dir)
  expect_true(file.exists(result))
})

test_that("zzt2f handles spanning headers", {
  skip_if_no_typst()
  tmp <- tempdir()
  out_dir <- file.path(tmp, "zzt2f_test_header")
  dir.create(out_dir, showWarnings = FALSE)
  on.exit(unlink(out_dir, recursive = TRUE))

  hdr <- t2f_header_above(" " = 1, "Group A" = 2, "Group B" = 1)

  result <- zzt2f(
    mtcars[1:5, 1:4],
    filename = "test_header",
    sub_dir = out_dir,
    header_above = hdr,
    format = "pdf"
  )
  expect_true(file.exists(result))
})
