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
      filename = "01_basic", sub_dir = typst_dir, format = "pdf")

# Table 2: NEJM theme
cat("--- Table 2: nejm_table ---\n")
t2f(mtcars[1:6, 1:4], theme = "nejm",
    filename = "02_nejm", sub_dir = latex_dir)
zzt2f(mtcars[1:6, 1:4], theme = "nejm",
      filename = "02_nejm", sub_dir = typst_dir, format = "pdf")

# Table 3: regression (lm object)
cat("--- Table 3: regression ---\n")
model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
t2f(model,
    filename = "03_regression", sub_dir = latex_dir,
    include = c("estimate", "std.error", "p.value"))
coef_df <- broom::tidy(model)
coef_df <- coef_df[, c("term", "estimate", "std.error", "p.value")]
coef_df$p.value <- format_pvalue(coef_df$p.value)
zzt2f(coef_df,
      filename = "03_regression", sub_dir = typst_dir, format = "pdf")

# Table 4: small mtcars with NEJM (wrap_demo equivalent)
cat("--- Table 4: wrap_demo ---\n")
t2f(mtcars[1:4, 1:3], theme = "nejm",
    filename = "04_wrap_demo", sub_dir = latex_dir)
zzt2f(mtcars[1:4, 1:3], theme = "nejm",
      filename = "04_wrap_demo", sub_dir = typst_dir, format = "pdf")

# Table 5: model comparison (t2f_regression)
cat("--- Table 5: model_comparison ---\n")
m1 <- lm(mpg ~ cyl, data = mtcars)
m2 <- lm(mpg ~ cyl + hp, data = mtcars)
m3 <- lm(mpg ~ cyl + hp + wt, data = mtcars)
t2f_regression(
  Model1 = m1, Model2 = m2, Model3 = m3,
  stars = TRUE,
  filename = "05_comparison", sub_dir = latex_dir
)

# For Typst: build the comparison df manually
tidy_model <- function(mod, name) {
  cf <- broom::tidy(mod)
  out <- data.frame(term = cf$term, stringsAsFactors = FALSE)
  est <- sprintf("%.3f", cf$estimate)
  se <- sprintf("(%.3f)", cf$std.error)
  stars <- ifelse(cf$p.value < 0.001, "***",
           ifelse(cf$p.value < 0.01, "**",
           ifelse(cf$p.value < 0.05, "*", "")))
  out[[name]] <- paste0(est, stars, "\n", se)
  out
}
t1 <- tidy_model(m1, "Model1")
t2 <- tidy_model(m2, "Model2")
t3 <- tidy_model(m3, "Model3")
comp_df <- merge(t1, t2, by = "term", all = TRUE)
comp_df <- merge(comp_df, t3, by = "term", all = TRUE)
comp_df[is.na(comp_df)] <- ""

zzt2f(comp_df,
      filename = "05_comparison", sub_dir = typst_dir, format = "pdf")

cat("\nDone. Files in:\n")
cat("  LaTeX: ", latex_dir, "\n")
cat("  Typst: ", typst_dir, "\n")
cat("\nOpen both directories to compare PDFs side by side.\n")
