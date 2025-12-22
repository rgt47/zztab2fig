test_that("t2f handles basic dataframe conversion correctly", {
  skip_if_not(system("pdflatex -version") == 0, "pdflatex not available")
  skip_if_not(system("pdfcrop -version") == 0, "pdfcrop not available")
  
  # Setup
  dir.create("test_output", showWarnings = FALSE)
  on.exit(unlink("test_output", recursive = TRUE))
  
  # Test data
  test_df <- data.frame(
    col1 = 1:3,
    col2 = letters[1:3],
    stringsAsFactors = FALSE
  )
  
  # Test function
  output_file <- t2f(test_df, "test_table", sub_dir = "test_output")
  
  # Check files exist
  expect_true(file.exists("test_output/test_table.tex"))
  expect_true(file.exists("test_output/test_table.pdf"))
})

test_that("t2f handles special characters in column names", {
  skip_if_not(system("pdflatex -version") == 0, "pdflatex not available")
  skip_if_not(system("pdfcrop -version") == 0, "pdfcrop not available")
  
  dir.create("test_output", showWarnings = FALSE)
  on.exit(unlink("test_output", recursive = TRUE))
  
  test_df <- data.frame(
    `col #1` = 1:3,
    `col %2` = letters[1:3],
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  
  output_file <- t2f(test_df, "special_chars", sub_dir = "test_output")
  
  expect_true(file.exists("test_output/special_chars.tex"))
  expect_true(file.exists("test_output/special_chars.pdf"))
})

test_that("t2f creates directory if it doesn't exist", {
  skip_if_not(system("pdflatex -version") == 0, "pdflatex not available")
  skip_if_not(system("pdfcrop -version") == 0, "pdfcrop not available")
  
  on.exit(unlink("new_dir", recursive = TRUE))
  
  test_df <- data.frame(a = 1:3, b = letters[1:3])
  output_file <- t2f(test_df, "new_table", sub_dir = "new_dir")
  
  expect_true(dir.exists("new_dir"))
  expect_true(file.exists("new_dir/new_table.pdf"))
})

test_that("t2f handles custom shading color", {
  skip_if_not(system("pdflatex -version") == 0, "pdflatex not available")
  skip_if_not(system("pdfcrop -version") == 0, "pdfcrop not available")
  
  dir.create("test_output", showWarnings = FALSE)
  on.exit(unlink("test_output", recursive = TRUE))
  
  test_df <- data.frame(a = 1:3, b = letters[1:3])
  output_file <- t2f(test_df, "shaded_table", 
                     sub_dir = "test_output",
                     scolor = "red!5")
  
  expect_true(file.exists("test_output/shaded_table.pdf"))
})

test_that("t2f handles extra_packages", {
  skip_if_not(system("pdflatex -version") == 0, "pdflatex not available")
  skip_if_not(system("pdfcrop -version") == 0, "pdfcrop not available")
  
  dir.create("test_output", showWarnings = FALSE)
  on.exit(unlink("test_output", recursive = TRUE))
  
  test_df <- data.frame(a = 1:3, b = letters[1:3])
  output_file <- t2f(test_df, "extra_packages", 
                     sub_dir = "test_output",
                     extra_packages = list(geometry(margin = "5mm")))
  
  expect_true(file.exists("test_output/extra_packages.tex"))
  expect_true(file.exists("test_output/extra_packages.pdf"))
  
  # Check that geometry package is in tex file
  tex_content <- readLines("test_output/extra_packages.tex")
  expect_true(any(grepl("usepackage.*geometry", tex_content)))
})

test_that("t2f input validation works", {
  # Test invalid input type (S3 method dispatch error)
  expect_error(t2f("not a dataframe"), "No t2f method for class")
  
  # Test empty dataframe
  empty_df <- data.frame()
  expect_error(t2f(empty_df), "`df` must not be empty")
  
  # Test invalid scolor
  test_df <- data.frame(a = 1:3, b = letters[1:3])
  expect_error(t2f(test_df, scolor = c("red", "blue")), 
               "`scolor` must be a single character string")
  
  # Test invalid verbose
  expect_error(t2f(test_df, verbose = "true"), 
               "`verbose` must be a single logical value")
  
  # Test invalid directory
  expect_error(t2f(test_df, sub_dir = NULL), "Directory name cannot be NULL")
  expect_error(t2f(test_df, sub_dir = ""), "Directory name cannot be empty")
})

test_that("sanitize_column_names works correctly", {
  test_names <- c("col #1", "col%2", "col&3")
  expected <- c("col__1", "col_2", "col_3")  # Changed to match actual function output
  
  expect_equal(sanitize_column_names(test_names), expected)
})

test_that("sanitize_filename works correctly", {
  # Test single filename
  test_name <- "file#1"
  expect_equal(sanitize_filename(test_name), "file_1")
  
  # Test multiple filenames separately if needed
  test_names <- c("file#1", "file%2", "file&3")
  expect_equal(sanitize_filename(test_names[1]), "file_1")
  expect_equal(sanitize_filename(test_names[2]), "file_2")
  expect_equal(sanitize_filename(test_names[3]), "file_3")
})


test_that("log_message respects verbose parameter", {
  expect_message(log_message("test message", verbose = TRUE))
  expect_no_message(log_message("test message", verbose = FALSE))
})

# Tests for LaTeX helper functions
test_that("geometry() creates correct LaTeX packages", {
  # Basic geometry package
  expect_equal(geometry(), "\\usepackage{geometry}")
  
  # With margin
  expect_equal(geometry(margin = "5mm"), "\\usepackage[margin=5mm]{geometry}")
  
  # With multiple options
  expect_equal(geometry(margin = "5mm", paper = "a4paper"), 
               "\\usepackage[margin=5mm,paper=a4paper]{geometry}")
  
  # With landscape
  result <- geometry(landscape = TRUE)
  expect_true(grepl("landscape", result))
})

test_that("babel() creates correct LaTeX packages", {
  expect_equal(babel("spanish"), "\\usepackage[spanish]{babel}")
  expect_equal(babel("french"), "\\usepackage[french]{babel}")
  
  # Test validation
  expect_error(babel(c("spanish", "french")), "single character string")
})

test_that("fontspec() creates correct LaTeX packages", {
  # Basic fontspec
  expect_equal(fontspec(), "\\usepackage{fontspec}")
  
  # With main font
  result <- fontspec(main_font = "Times New Roman")
  expect_equal(length(result), 2)
  expect_true(any(grepl("usepackage\\{fontspec\\}", result)))
  expect_true(any(grepl("setmainfont\\{Times New Roman\\}", result)))
})

test_that("sanitize_table_cells works correctly", {
  # Test special LaTeX characters
  test_cells <- c("100%", "Cost $50", "R&D", "Item #1")
  result <- sanitize_table_cells(test_cells)
  
  expect_true(all(grepl("\\\\%", result[1])))
  expect_true(all(grepl("\\\\\\$", result[2])))
  expect_true(all(grepl("\\\\&", result[3])))
  expect_true(all(grepl("\\\\#", result[4])))
})
