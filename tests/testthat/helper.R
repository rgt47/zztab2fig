# Test helper functions

#' Skip test if LaTeX (xelatex) is not available or not working
#' @description Checks if xelatex can compile a minimal fontspec document
skip_if_no_latex <- function() {
  # Check if xelatex command exists
  has_xelatex <- suppressWarnings(
    system("xelatex --version", ignore.stdout = TRUE, ignore.stderr = TRUE)
  ) == 0

  if (!has_xelatex) {
    testthat::skip("xelatex not available")
  }

  # Try compiling a minimal fontspec document
  temp_dir <- tempdir()
  tex_file <- file.path(temp_dir, "test_latex.tex")
  writeLines(c(
    "\\documentclass{article}",
    "\\usepackage{fontspec}",
    "\\begin{document}",
    "test",
    "\\end{document}"
  ), tex_file)

  old_wd <- setwd(temp_dir)
  on.exit(setwd(old_wd))

  result <- suppressWarnings(
    system("xelatex -interaction=batchmode test_latex.tex",
      ignore.stdout = TRUE, ignore.stderr = TRUE
    )
  )

  if (result != 0) {
    testthat::skip("xelatex cannot compile fontspec documents (missing fonts?)")
  }
}
