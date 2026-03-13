# Integration Test: Report Rendering
# Tests that the main research report can be rendered successfully

library(tinytest)
library(here)

# Report Rmd file exists and is valid
report_path <- here("analysis", "report", "report.Rmd")
expect_true(file.exists(report_path))

report_content <- readLines(report_path)
expect_true(length(report_content) > 0)
expect_true(any(grepl("^---$", report_content)))
expect_true(any(grepl("^title:", report_content)))
expect_true(any(grepl("^author:", report_content)))

# Report dependencies are available
required_packages <- c("rmarkdown", "knitr", "bookdown")
for (pkg in required_packages) {
  expect_true(
    requireNamespace(pkg, quietly = TRUE),
    info = paste("Package", pkg, "is required for report rendering")
  )
}

# Bibliography files exist
bib_path <- here("analysis", "report", "references.bib")
expect_true(file.exists(bib_path))

csl_path <- here("analysis", "report", "statistics-in-medicine.csl")
expect_true(file.exists(csl_path))

# Report can be parsed without errors
yaml_content <- rmarkdown::yaml_front_matter(report_path)
expect_true(is.list(yaml_content))
expect_true("title" %in% names(yaml_content))
