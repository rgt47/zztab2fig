# Test helper functions

#' Skip test if LaTeX (pdflatex) is not available or not working
#' @description Checks if pdflatex can compile a minimal document
skip_if_no_latex <- function() {
  has_pdflatex <- suppressWarnings(
    system("pdflatex --version", ignore.stdout = TRUE, ignore.stderr = TRUE)
  ) == 0

  if (!has_pdflatex) {
    testthat::skip("pdflatex not available")
  }

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

  if (result != 0) {
    testthat::skip("pdflatex cannot compile documents")
  }
}
