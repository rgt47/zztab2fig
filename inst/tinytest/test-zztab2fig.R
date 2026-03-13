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

has_pdfcrop <- function() {
  system("pdfcrop -version",
    ignore.stdout = TRUE, ignore.stderr = TRUE
  ) == 0
}


# --- Input validation (no LaTeX needed) ---

# t2f rejects invalid input type
expect_error(t2f("not a dataframe"), "No t2f method for class")

# t2f rejects empty dataframe
expect_error(t2f(data.frame()), "`df` must not be empty")

# t2f rejects invalid scolor
test_df <- data.frame(a = 1:3, b = letters[1:3])
expect_error(
  t2f(test_df, scolor = c("red", "blue")),
  "`scolor` must be a single character value"
)

# t2f rejects invalid verbose
expect_error(
  t2f(test_df, verbose = "true"),
  "`verbose` must be a single logical value"
)

# t2f rejects invalid directory
expect_error(t2f(test_df, sub_dir = NULL), "Directory name cannot be NULL")
expect_error(t2f(test_df, sub_dir = ""), "Directory name cannot be empty")


# --- Sanitize functions ---

# sanitize_column_names
test_names <- c("col #1", "col%2", "col&3")
expected <- c("col\\_\\_1", "col\\_2", "col\\_3")
expect_equal(sanitize_column_names(test_names), expected)

# sanitize_filename
expect_equal(sanitize_filename("file#1"), "file_1")
expect_equal(sanitize_filename("file%2"), "file_2")
expect_equal(sanitize_filename("file&3"), "file_3")


# --- log_message ---

expect_message(log_message("test message", verbose = TRUE))

msgs <- capture.output(
  log_message("test message", verbose = FALSE),
  type = "message"
)
expect_equal(length(msgs), 0L)


# --- LaTeX helper functions ---

# geometry()
expect_equal(geometry(), "\\usepackage{geometry}")
expect_equal(
  geometry(margin = "5mm"),
  "\\usepackage[margin=5mm]{geometry}"
)
expect_equal(
  geometry(margin = "5mm", paper = "a4paper"),
  "\\usepackage[margin=5mm,paper=a4paper]{geometry}"
)
expect_true(grepl("landscape", geometry(landscape = TRUE)))

# babel()
expect_equal(babel("spanish"), "\\usepackage[spanish]{babel}")
expect_equal(babel("french"), "\\usepackage[french]{babel}")
expect_error(babel(c("spanish", "french")), "single character string")

# fontspec()
expect_equal(fontspec(), "\\usepackage{fontspec}")
result <- fontspec(main_font = "Times New Roman")
expect_equal(length(result), 2)
expect_true(any(grepl("usepackage\\{fontspec\\}", result)))
expect_true(any(grepl("setmainfont\\{Times New Roman\\}", result)))

# sanitize_table_cells
test_cells <- c("100%", "Cost $50", "R&D", "Item #1")
result <- sanitize_table_cells(test_cells)
expect_true(all(grepl("\\\\%", result[1])))
expect_true(all(grepl("\\\\\\$", result[2])))
expect_true(all(grepl("\\\\&", result[3])))
expect_true(all(grepl("\\\\#", result[4])))


# --- Integration tests (require LaTeX + pdfcrop) ---

if (!has_latex() || !has_pdfcrop()) {
  exit_file("pdflatex or pdfcrop not available")
}

# t2f handles basic dataframe conversion
dir.create("test_output", showWarnings = FALSE)
on.exit(unlink("test_output", recursive = TRUE))

test_df <- data.frame(
  col1 = 1:3,
  col2 = letters[1:3],
  stringsAsFactors = FALSE
)
output_file <- t2f(test_df, "test_table", sub_dir = "test_output")
expect_true(file.exists("test_output/test_table.tex"))
expect_true(file.exists("test_output/test_table.pdf"))

# t2f handles special characters in column names
test_df2 <- data.frame(
  `col #1` = 1:3,
  `col %2` = letters[1:3],
  check.names = FALSE,
  stringsAsFactors = FALSE
)
output_file <- t2f(test_df2, "special_chars", sub_dir = "test_output")
expect_true(file.exists("test_output/special_chars.tex"))
expect_true(file.exists("test_output/special_chars.pdf"))

# t2f creates directory if it doesn't exist
test_df3 <- data.frame(a = 1:3, b = letters[1:3])
output_file <- t2f(test_df3, "new_table", sub_dir = "new_dir")
expect_true(dir.exists("new_dir"))
expect_true(file.exists("new_dir/new_table.pdf"))
unlink("new_dir", recursive = TRUE)

# t2f handles custom shading color
test_df4 <- data.frame(a = 1:3, b = letters[1:3])
output_file <- t2f(
  test_df4, "shaded_table",
  sub_dir = "test_output", scolor = "red!5"
)
expect_true(file.exists("test_output/shaded_table.pdf"))

# t2f handles extra_packages
test_df5 <- data.frame(a = 1:3, b = letters[1:3])
output_file <- t2f(
  test_df5, "extra_packages",
  sub_dir = "test_output",
  extra_packages = list(geometry(margin = "5mm"))
)
expect_true(file.exists("test_output/extra_packages.tex"))
expect_true(file.exists("test_output/extra_packages.pdf"))
tex_content <- readLines("test_output/extra_packages.tex")
expect_true(any(grepl("usepackage.*geometry", tex_content)))
