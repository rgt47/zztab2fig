# Tests for zzt2f Batch A styling helpers and compile = FALSE mode.

# --- Spec constructors ---

spec <- zzt2f_format(rows = 1:3, cols = 1, bold = TRUE)
expect_inherits(spec, "zzt2f_format")
expect_equal(spec$rows, 1:3)
expect_equal(spec$cols, 1)
expect_true(spec$bold)

expect_error(
  zzt2f_format(rows = "a"),
  "must be NULL or a numeric vector"
)
expect_error(
  zzt2f_format(bold = c(TRUE, FALSE)),
  "single logical value"
)
expect_error(
  zzt2f_format(condition = 1),
  "must be NULL or a function"
)

# --- Convenience wrappers ---

expect_inherits(zzt2f_bold_col("x"), "zzt2f_format")
expect_true(zzt2f_bold_col(1:2)$bold)
expect_error(zzt2f_bold_col(NULL), "non-empty")

expect_true(zzt2f_italic_col("x")$italic)
expect_error(zzt2f_italic_col(character(0)), "non-empty")

row_spec <- zzt2f_color_row(c(1, 3), "blue!10")
expect_equal(row_spec$rows, c(1, 3))
expect_equal(row_spec$background, "blue!10")
expect_error(zzt2f_color_row(NULL, "red"), "non-empty")
expect_error(zzt2f_color_row(1, c("a", "b")), "single character")

hl <- zzt2f_highlight(function(x) as.numeric(x) < 0.05, bold = TRUE)
expect_inherits(hl, "zzt2f_format")
expect_equal(hl$background, "yellow!30")
expect_true(is.function(hl$condition))
expect_error(zzt2f_highlight("not a function"), "must be a function")

dec <- zzt2f_decimal("mpg", digits = 2)
expect_inherits(dec, "zzt2f_decimal")
expect_inherits(dec, "zzt2f_format")
expect_equal(dec$digits, 2L)
expect_error(zzt2f_decimal("x", digits = -1), "non-negative")
expect_error(zzt2f_decimal(NULL, digits = 2), "non-empty")

# --- resolve_cols ---

df <- data.frame(a = 1:3, b = letters[1:3])
expect_equal(zztab2fig:::resolve_cols(NULL, df), NULL)
expect_equal(zztab2fig:::resolve_cols("b", df), 2L)
expect_equal(zztab2fig:::resolve_cols(c("a", "b"), df), 1:2)
expect_equal(zztab2fig:::resolve_cols(1L, df), 1L)
expect_error(zztab2fig:::resolve_cols("z", df), "Unknown column")
expect_error(zztab2fig:::resolve_cols(5L, df), "out of range")

# --- Spec application (does not require Typst compilation) ---

if (requireNamespace("tinytable", quietly = TRUE)) {
  df <- mtcars[1:4, 1:3]
  tbl <- tinytable::tt(df)

  # single spec
  out <- zztab2fig:::apply_zzt2f_formats(
    tbl, zzt2f_bold_col("mpg"), df
  )
  expect_inherits(out, "tinytable")

  # list of specs
  specs <- list(
    zzt2f_bold_col(1),
    zzt2f_color_row(1, "gray!20")
  )
  out <- zztab2fig:::apply_zzt2f_formats(tbl, specs, df)
  expect_inherits(out, "tinytable")

  # condition spec against numeric column
  hl <- zzt2f_highlight(function(x) as.numeric(x) > 20,
                         background = "yellow!30")
  out <- zztab2fig:::apply_zzt2f_formats(tbl, hl, df)
  expect_inherits(out, "tinytable")

  # decimal spec
  out <- zztab2fig:::apply_zzt2f_formats(
    tbl, zzt2f_decimal("mpg", digits = 1), df
  )
  expect_inherits(out, "tinytable")

  # NULL passes through
  expect_identical(
    zztab2fig:::apply_zzt2f_formats(tbl, NULL, df),
    tbl
  )

  # invalid input
  expect_error(
    zztab2fig:::apply_zzt2f_formats(tbl, list("not a spec"), df),
    "zzt2f_format spec"
  )
}

# --- End-to-end with Typst (requires CLI) ---

has_typst <- nzchar(Sys.which("typst"))
has_tt <- requireNamespace("tinytable", quietly = TRUE)

if (has_typst && has_tt) {
  tmp <- file.path(tempdir(), "zzt2f_helpers_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)

  # compile = FALSE returns Typst source
  src <- zzt2f(
    mtcars[1:4, 1:3],
    filename = "bold_demo",
    sub_dir = tmp,
    compile = FALSE,
    formats = zzt2f_bold_col("mpg")
  )
  expect_inherits(src, "zzt2f_source")
  expect_true(any(grepl("bold", src, ignore.case = TRUE)))

  # zzt2f_compile renders the source
  out <- zzt2f_compile(
    src, filename = "bold_demo", sub_dir = tmp, format = "pdf"
  )
  expect_true(file.exists(out))
  expect_true(grepl("\\.pdf$", out))

  # Full pipeline with multiple specs
  out2 <- zzt2f(
    mtcars[1:4, 1:3],
    filename = "multi_demo",
    sub_dir = tmp,
    formats = list(
      zzt2f_bold_col("mpg"),
      zzt2f_color_row(1, "gray!20"),
      zzt2f_highlight(function(x) as.numeric(x) > 20,
                       background = "yellow!30")
    )
  )
  expect_true(file.exists(out2))
}
