# Tests for advanced features (siunitx, footnotes, headers)

# Siunitx tests ----

test_that("t2f_siunitx creates valid column specification", {
  spec <- t2f_siunitx(table_format = "3.2")

  expect_s3_class(spec, "t2f_siunitx")
  expect_match(as.character(spec), "^S\\[")
  expect_match(as.character(spec), "table-format=3.2")
})

test_that("t2f_siunitx includes required packages", {
  spec <- t2f_siunitx(table_format = "3.2")

  packages <- attr(spec, "packages")
  expect_true(any(grepl("siunitx", packages)))
  expect_true(any(grepl("detect-all", packages)))
})

test_that("t2f_decimal is a convenience wrapper for t2f_siunitx", {
  spec <- t2f_decimal(2, 3)

  expect_s3_class(spec, "t2f_siunitx")
  expect_match(as.character(spec), "table-format=2.3")
})

test_that("detect_siunitx_columns identifies S columns from list", {
  align <- list(
    "l",
    t2f_siunitx(table_format = "3.2"),
    "r",
    t2f_siunitx(table_format = "2.3")
  )

  result <- zztab2fig:::detect_siunitx_columns(align)
  expect_equal(result, c(2, 4))
})

test_that("detect_siunitx_columns identifies S columns from character vector", {
  align <- c(
    "l",
    "S[table-format=3.2]",
    "r",
    "S[table-format=2.3]"
  )

  result <- zztab2fig:::detect_siunitx_columns(align)
  expect_equal(result, c(2, 4))
})

test_that("detect_siunitx_columns returns empty for no siunitx columns", {
  align <- c("l", "c", "r")
  result <- zztab2fig:::detect_siunitx_columns(align)
  expect_equal(result, integer(0))
})

test_that("protect_siunitx_headers wraps headers in braces", {
  latex_table <- paste(
    "\\begin{table}",
    "\\begin{tabular}{lS[...]S[...]}",
    "\\toprule",
    "\\textbf{Item} & \\textbf{Value1} & \\textbf{Value2}\\\\",
    "\\midrule",
    "A & 1.5 & 2.5\\\\",
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    sep = "\n"
  )

  result <- zztab2fig:::protect_siunitx_headers(latex_table, c(2, 3))

  expect_match(result, "\\{\\\\textbf\\{Value1\\}\\}")
  expect_match(result, "\\{\\\\textbf\\{Value2\\}\\}")
  expect_no_match(result, "\\{\\\\textbf\\{Item\\}\\}")
})

test_that("protect_siunitx_headers preserves non-siunitx columns", {
  latex_table <- paste(
    "\\begin{table}",
    "\\begin{tabular}{lS[...]r}",
    "\\toprule",
    "\\textbf{Item} & \\textbf{Value} & \\textbf{Count}\\\\",
    "\\midrule",
    "A & 1.5 & 10\\\\",
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    sep = "\n"
  )

  result <- zztab2fig:::protect_siunitx_headers(latex_table, c(2))

  expect_match(result, "\\{\\\\textbf\\{Value\\}\\}")
  expect_match(result, "\\\\textbf\\{Item\\}")
  expect_match(result, "\\\\textbf\\{Count\\}")
})

test_that("t2f with siunitx alignment generates valid LaTeX", {
  skip_if_no_latex()

  df <- data.frame(
    Item = c("A", "B"),
    Value = c(1.5, 123.45)
  )

  output_dir <- tempdir()
  result <- t2f(
    df,
    filename = "test_siunitx",
    sub_dir = output_dir,
    align = list("l", t2f_siunitx(table_format = "3.2"))
  )

  expect_true(file.exists(result))

  tex_file <- file.path(output_dir, "test_siunitx.tex")
  tex_content <- paste(readLines(tex_file), collapse = "\n")

  expect_match(tex_content, "\\\\usepackage\\{siunitx\\}")
  expect_match(tex_content, "S\\[table-format=3.2")
  expect_match(tex_content, "\\{\\\\textbf\\{Value\\}\\}")
})

# Footnote tests ----

test_that("t2f_footnote creates valid footnote object", {
  fn <- t2f_footnote(general = "Note text")

  expect_s3_class(fn, "t2f_footnote")
  expect_equal(fn$general, "Note text")
  expect_true(fn$threeparttable)
})

test_that("t2f_footnote accepts multiple notation types", {
  fn <- t2f_footnote(
    general = "General note",
    number = c("First", "Second"),
    symbol = c("p < 0.05", "p < 0.01")
  )

  expect_equal(fn$general, "General note")
  expect_equal(length(fn$number), 2)
  expect_equal(length(fn$symbol), 2)
})

test_that("t2f_mark creates footnote marker", {
  result <- t2f_mark("23.5", 1, "symbol")
  expect_match(result, "textsuperscript")
  expect_match(result, "\\*")
})

# Header tests ----

test_that("t2f_header_above creates valid header object", {
  hdr <- t2f_header_above(" " = 1, "Group A" = 2, "Group B" = 2)

  expect_s3_class(hdr, "t2f_header")
  expect_equal(sum(hdr$header), 5)
  expect_true(hdr$bold)
})

test_that("t2f_header_above rejects invalid input", {
  expect_error(
    t2f_header_above("Group A", "Group B"),
    "named with numeric spans"
  )
})

# Collapse rows tests ----

test_that("t2f_collapse_rows creates valid collapse object", {
  collapse <- t2f_collapse_rows(1, valign = "top")

  expect_s3_class(collapse, "t2f_collapse")
  expect_equal(collapse$columns, 1)
  expect_equal(collapse$valign, "top")
})
