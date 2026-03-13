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


# --- Siunitx ---

# t2f_siunitx creates valid column specification
spec <- t2f_siunitx(table_format = "3.2")
expect_inherits(spec, "t2f_siunitx")
expect_true(grepl("^S\\[", as.character(spec)))
expect_true(grepl("table-format=3.2", as.character(spec)))

# t2f_siunitx includes required packages
packages <- attr(spec, "packages")
expect_true(any(grepl("siunitx", packages)))
expect_true(any(grepl("detect-all", packages)))

# t2f_decimal is convenience wrapper
spec <- t2f_decimal(2, 3)
expect_inherits(spec, "t2f_siunitx")
expect_true(grepl("table-format=2.3", as.character(spec)))

# detect_siunitx_columns from list
align <- list(
  "l",
  t2f_siunitx(table_format = "3.2"),
  "r",
  t2f_siunitx(table_format = "2.3")
)
result <- zztab2fig:::detect_siunitx_columns(align)
expect_equal(result, c(2, 4))

# detect_siunitx_columns from character vector
align <- c(
  "l",
  "S[table-format=3.2]",
  "r",
  "S[table-format=2.3]"
)
result <- zztab2fig:::detect_siunitx_columns(align)
expect_equal(result, c(2, 4))

# detect_siunitx_columns returns empty for no siunitx columns
align <- c("l", "c", "r")
result <- zztab2fig:::detect_siunitx_columns(align)
expect_equal(result, integer(0))

# protect_siunitx_headers wraps headers in braces
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
expect_true(grepl("\\{\\\\textbf\\{Value1\\}\\}", result))
expect_true(grepl("\\{\\\\textbf\\{Value2\\}\\}", result))
expect_false(grepl("\\{\\\\textbf\\{Item\\}\\}", result))

# protect_siunitx_headers preserves non-siunitx columns
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
expect_true(grepl("\\{\\\\textbf\\{Value\\}\\}", result))
expect_true(grepl("\\\\textbf\\{Item\\}", result))
expect_true(grepl("\\\\textbf\\{Count\\}", result))


# --- Footnotes ---

# t2f_footnote creates valid object
fn <- t2f_footnote(general = "Note text")
expect_inherits(fn, "t2f_footnote")
expect_equal(fn$general, "Note text")
expect_true(fn$threeparttable)

# t2f_footnote accepts multiple notation types
fn <- t2f_footnote(
  general = "General note",
  number = c("First", "Second"),
  symbol = c("p < 0.05", "p < 0.01")
)
expect_equal(fn$general, "General note")
expect_equal(length(fn$number), 2)
expect_equal(length(fn$symbol), 2)

# t2f_mark creates footnote marker
result <- t2f_mark("23.5", 1, "symbol")
expect_true(grepl("textsuperscript", result))
expect_true(grepl("\\*", result))


# --- Headers ---

# t2f_header_above creates valid header object
hdr <- t2f_header_above(" " = 1, "Group A" = 2, "Group B" = 2)
expect_inherits(hdr, "t2f_header")
expect_equal(sum(hdr$header), 5)
expect_true(hdr$bold)

# t2f_header_above rejects invalid input
expect_error(
  t2f_header_above("Group A", "Group B"),
  "named with numeric spans"
)


# --- Collapse rows ---

# t2f_collapse_rows creates valid object
collapse <- t2f_collapse_rows(1, valign = "top")
expect_inherits(collapse, "t2f_collapse")
expect_equal(collapse$columns, 1)
expect_equal(collapse$valign, "top")


# --- Integration: t2f with siunitx (requires LaTeX) ---

if (!has_latex()) exit_file("pdflatex not available")

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
expect_true(grepl("\\\\usepackage\\{siunitx\\}", tex_content))
expect_true(grepl("S\\[table-format=3.2", tex_content))
expect_true(grepl("\\{\\\\textbf\\{Value\\}\\}", tex_content))
