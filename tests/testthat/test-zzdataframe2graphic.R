library(testthat)
library(withr)  # For withr::defer()

# Test: Basic functionality of d2g
test_that("d2g generates LaTeX and PDF files correctly", {
  dir.create("test_output")
  withr::defer(unlink("test_output", recursive = TRUE))  # Cleanup after the test
  
  output <- d2g(mtcars, filename = "test_table", sub_dir = "test_output", verbose = FALSE)
  expect_true(file.exists("test_output/test_table.tex"))
  expect_true(file.exists("test_output/test_table.pdf"))
})

# Test: Empty dataframe error
test_that("d2g throws an error for empty dataframe", {
  empty_df <- data.frame()
  expect_error(d2g(empty_df, filename = "empty_table"), "`df` must not be empty")
})

# Test: Non-dataframe input
test_that("d2g throws an error for non-dataframe input", {
  expect_error(d2g(matrix(1:10, ncol = 2), filename = "matrix_table"), "`df` must be a dataframe")
})

# Test: Sanitize column names
test_that("sanitize_column_names sanitizes correctly", {
  cols <- c("Column#1", "Another Column%", "final&column")
  sanitized <- sanitize_column_names(cols)
  expect_equal(sanitized, c("Column_1", "Another_Column_", "final_column"))
})

# Test: Sanitize table cells
test_that("sanitize_table_cells escapes LaTeX characters correctly", {
  cells <- c("X&Y", "Z#W", "1%2", "3$4")
  sanitized <- sanitize_table_cells(cells)
  expect_equal(sanitized, c("X\\&Y", "Z\\#W", "1\\%2", "3\\$4"))
})

# Test: Filename sanitization
test_that("sanitize_filename removes invalid characters", {
  filename <- "test:file|name<>*"
  sanitized <- sanitize_filename(filename)
  expect_equal(sanitized, "test_file_name___")
})

# Test: Missing kableExtra package
test_that("create_latex_table throws error if kableExtra is missing", {
  skip_if(requireNamespace("kableExtra", quietly = TRUE), "kableExtra is installed")
  expect_error(create_latex_table(mtcars, "test.tex", "blue!10"), "The 'kableExtra' package is required but not installed")
})

# Test: Directory creation
test_that("d2g creates missing sub_dir", {
  temp_dir <- tempfile("test_sub_dir")
  withr::defer(unlink(temp_dir, recursive = TRUE))  # Cleanup after the test
  
  d2g(mtcars, filename = "test_table", sub_dir = temp_dir, verbose = FALSE)
  expect_true(dir.exists(temp_dir))
})

# Test: Custom filename
test_that("d2g uses custom filename", {
  dir.create("custom_output")
  withr::defer(unlink("custom_output", recursive = TRUE))  # Cleanup after the test
  
  d2g(mtcars, filename = "custom_table", sub_dir = "custom_output", verbose = FALSE)
  expect_true(file.exists("custom_output/custom_table.tex"))
  expect_true(file.exists("custom_output/custom_table.pdf"))
})
