devtools::load_all(".")

out <- file.path("inst", "backend_compare")
dir.create(out, showWarnings = FALSE)

latex_dir <- file.path(out, "latex")
typst_dir <- file.path(out, "typst")
dir.create(latex_dir, showWarnings = FALSE)
dir.create(typst_dir, showWarnings = FALSE)

cat("Output directory:", out, "\n\n")

# Table 1: basic mtcars (no theme)
cat("--- Table 1: basic_table ---\n")
t2f(mtcars[1:6, 1:4],
    filename = "01_basic", sub_dir = latex_dir)
zzt2f(mtcars[1:6, 1:4],
      filename = "01_basic", sub_dir = typst_dir)

# Table 2: NEJM theme
cat("--- Table 2: nejm_table ---\n")
t2f(mtcars[1:6, 1:4], theme = "nejm",
    filename = "02_nejm", sub_dir = latex_dir)
zzt2f(mtcars[1:6, 1:4], theme = "nejm",
      filename = "02_nejm", sub_dir = typst_dir)

# Table 3: regression (lm S3 dispatch)
cat("--- Table 3: regression ---\n")
model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
t2f(model,
    filename = "03_regression", sub_dir = latex_dir,
    include = c("estimate", "std.error", "p.value"))
zzt2f(model,
      filename = "03_regression", sub_dir = typst_dir,
      include = c("estimate", "std.error", "p.value"))

# Table 4: small mtcars with NEJM
cat("--- Table 4: wrap_demo ---\n")
t2f(mtcars[1:4, 1:3], theme = "nejm",
    filename = "04_wrap_demo", sub_dir = latex_dir)
zzt2f(mtcars[1:4, 1:3], theme = "nejm",
      filename = "04_wrap_demo", sub_dir = typst_dir)

# Table 5: model comparison
cat("--- Table 5: model_comparison ---\n")
m1 <- lm(mpg ~ cyl, data = mtcars)
m2 <- lm(mpg ~ cyl + hp, data = mtcars)
m3 <- lm(mpg ~ cyl + hp + wt, data = mtcars)
t2f_regression(
  Model1 = m1, Model2 = m2, Model3 = m3,
  stars = TRUE,
  filename = "05_comparison", sub_dir = latex_dir
)
zzt2f_regression(
  Model1 = m1, Model2 = m2, Model3 = m3,
  stars = TRUE,
  filename = "05_comparison", sub_dir = typst_dir
)

cat("\nDone. Files in:\n")
cat("  LaTeX: ", latex_dir, "\n")
cat("  Typst: ", typst_dir, "\n")
