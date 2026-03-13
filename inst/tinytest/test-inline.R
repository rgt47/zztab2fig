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

if (!has_latex()) exit_file("pdflatex not available")

output_dir <- tempdir()

# t2f_inline generates PDF output
result <- t2f_inline(
  mtcars[1:5, 1:3],
  format = "pdf",
  filename = "inline_test_pdf",
  sub_dir = output_dir
)
expect_true(file.exists(result))
expect_true(grepl("\\.pdf$", result))

# t2f_inline generates PNG output
if (nzchar(Sys.which("convert"))) {
  result <- t2f_inline(
    mtcars[1:5, 1:3],
    format = "png",
    filename = "inline_test_png",
    sub_dir = output_dir
  )
  expect_true(file.exists(result))
  expect_true(grepl("\\.png$", result))
}

# t2f_inline accepts width parameter
result <- t2f_inline(
  mtcars[1:3, 1:2],
  width = "3in",
  format = "pdf",
  filename = "inline_width",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_inline accepts align parameter
result_left <- t2f_inline(
  mtcars[1:3, 1:2],
  align = "left",
  format = "pdf",
  filename = "inline_align_left",
  sub_dir = output_dir
)
result_right <- t2f_inline(
  mtcars[1:3, 1:2],
  align = "right",
  format = "pdf",
  filename = "inline_align_right",
  sub_dir = output_dir
)
expect_true(file.exists(result_left))
expect_true(file.exists(result_right))

# t2f_inline works with lm objects
model <- lm(mpg ~ cyl + hp, data = mtcars)
result <- t2f_inline(
  model,
  format = "pdf",
  filename = "inline_lm",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_coef generates coefficient table
model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
result <- t2f_coef(
  model,
  filename = "coef_test",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_coef uses default width
model <- lm(mpg ~ cyl, data = mtcars)
result <- t2f_coef(
  model,
  filename = "coef_default_width",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_inline auto-generates filename if NULL
result <- t2f_inline(
  mtcars[1:3, 1:2],
  filename = NULL,
  format = "pdf",
  sub_dir = output_dir
)
expect_true(file.exists(result))
expect_true(grepl("^t2f_inline_", basename(result)))

# t2f_inline accepts caption and label
result <- t2f_inline(
  mtcars[1:3, 1:2],
  caption = "Test caption",
  label = "tab:test",
  format = "pdf",
  filename = "inline_caption_label",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_coef accepts caption and label
model <- lm(mpg ~ cyl, data = mtcars)
result <- t2f_coef(
  model,
  caption = "Model coefficients",
  label = "tab:coef",
  filename = "coef_caption_label",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# build_inline_latex: caption above
result <- zztab2fig:::build_inline_latex(
  path = "test.pdf",
  width = "3in",
  height = NULL,
  align = "center",
  caption = "Test caption",
  caption_short = NULL,
  label = "tab:test",
  caption_position = "above"
)
expect_true(grepl("\\\\begin\\{center\\}", result))
expect_true(grepl(
  "\\\\captionof\\{table\\}\\{Test caption\\}", result
))
expect_true(grepl("\\\\label\\{tab:test\\}", result))
expect_true(grepl(
  "\\\\includegraphics\\[width=3in\\]\\{test.pdf\\}", result
))
lines <- strsplit(result, "\n")[[1]]
caption_line <- grep("captionof", lines)
include_line <- grep("includegraphics", lines)
expect_true(caption_line < include_line)

# build_inline_latex: caption below
result <- zztab2fig:::build_inline_latex(
  path = "test.pdf",
  width = "2in",
  height = NULL,
  align = "left",
  caption = "Below caption",
  caption_short = NULL,
  label = NULL,
  caption_position = "below"
)
expect_true(grepl("\\\\begin\\{flushleft\\}", result))
expect_true(grepl(
  "\\\\captionof\\{table\\}\\{Below caption\\}", result
))
expect_true(grepl(
  "\\\\includegraphics\\[width=2in\\]\\{test.pdf\\}", result
))
lines <- strsplit(result, "\n")[[1]]
caption_line <- grep("captionof", lines)
include_line <- grep("includegraphics", lines)
expect_true(caption_line > include_line)

# build_inline_latex: short caption
result <- zztab2fig:::build_inline_latex(
  path = "test.pdf",
  width = NULL,
  height = NULL,
  align = "center",
  caption = "A very long caption for the table",
  caption_short = "Short caption",
  label = "tab:short",
  caption_position = "above"
)
expect_true(grepl(
  "\\\\captionof\\{table\\}\\[Short caption\\]\\{A very long caption",
  result
))

# build_inline_latex: no caption
result <- zztab2fig:::build_inline_latex(
  path = "test.pdf",
  width = "4in",
  height = NULL,
  align = "right",
  caption = NULL,
  caption_short = NULL,
  label = NULL,
  caption_position = "above"
)
expect_true(grepl("\\\\begin\\{flushright\\}", result))
expect_true(grepl(
  "\\\\includegraphics\\[width=4in\\]\\{test.pdf\\}", result
))
expect_false(grepl("captionof", result))

# t2f_inline accepts caption_position
result <- t2f_inline(
  mtcars[1:3, 1:2],
  caption = "Test",
  caption_position = "below",
  format = "pdf",
  filename = "inline_caption_below",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# build_inline_latex: frame with fcolorbox
result <- zztab2fig:::build_inline_latex(
  path = "test.pdf",
  width = "3in",
  height = NULL,
  align = "center",
  caption = NULL,
  caption_short = NULL,
  label = NULL,
  caption_position = "above",
  frame = TRUE,
  frame_color = "black",
  frame_width = "0.4pt",
  background = NULL,
  inner_sep = "2pt"
)
expect_true(grepl("\\\\fcolorbox\\{black\\}\\{white\\}", result))
expect_true(grepl(
  "\\\\setlength\\{\\\\fboxsep\\}\\{2pt\\}", result
))
expect_true(grepl(
  "\\\\setlength\\{\\\\fboxrule\\}\\{0.4pt\\}", result
))

# build_inline_latex: background with colorbox
result <- zztab2fig:::build_inline_latex(
  path = "test.pdf",
  width = "3in",
  height = NULL,
  align = "center",
  caption = NULL,
  caption_short = NULL,
  label = NULL,
  caption_position = "above",
  frame = FALSE,
  frame_color = "black",
  frame_width = "0.4pt",
  background = "gray!10",
  inner_sep = "4pt"
)
expect_true(grepl("\\\\colorbox\\{gray!10\\}", result))
expect_true(grepl(
  "\\\\setlength\\{\\\\fboxsep\\}\\{4pt\\}", result
))
expect_false(grepl("fcolorbox", result))

# build_inline_latex: frame + background
result <- zztab2fig:::build_inline_latex(
  path = "test.pdf",
  width = "3in",
  height = NULL,
  align = "center",
  caption = NULL,
  caption_short = NULL,
  label = NULL,
  caption_position = "above",
  frame = TRUE,
  frame_color = "blue!50",
  frame_width = "1pt",
  background = "blue!5",
  inner_sep = "3pt"
)
expect_true(grepl(
  "\\\\fcolorbox\\{blue!50\\}\\{blue!5\\}", result
))
expect_true(grepl(
  "\\\\setlength\\{\\\\fboxsep\\}\\{3pt\\}", result
))
expect_true(grepl(
  "\\\\setlength\\{\\\\fboxrule\\}\\{1pt\\}", result
))

# build_inline_latex: no frame or background
result <- zztab2fig:::build_inline_latex(
  path = "test.pdf",
  width = "3in",
  height = NULL,
  align = "center",
  caption = NULL,
  caption_short = NULL,
  label = NULL,
  caption_position = "above",
  frame = FALSE,
  frame_color = "black",
  frame_width = "0.4pt",
  background = NULL,
  inner_sep = "2pt"
)
expect_false(grepl("fcolorbox", result))
expect_false(grepl("colorbox", result))
expect_false(grepl("fboxsep", result))

# t2f_inline accepts frame parameters
result <- t2f_inline(
  mtcars[1:3, 1:2],
  frame = TRUE,
  frame_color = "gray",
  frame_width = "0.5pt",
  format = "pdf",
  filename = "inline_frame",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_inline accepts background parameter
result <- t2f_inline(
  mtcars[1:3, 1:2],
  background = "yellow!10",
  format = "pdf",
  filename = "inline_background",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_inline accepts frame and background together
result <- t2f_inline(
  mtcars[1:3, 1:2],
  frame = TRUE,
  frame_color = "blue!50",
  background = "blue!5",
  inner_sep = "4pt",
  format = "pdf",
  filename = "inline_frame_bg",
  sub_dir = output_dir
)
expect_true(file.exists(result))

# t2f_coef accepts frame parameters
model <- lm(mpg ~ cyl, data = mtcars)
result <- t2f_coef(
  model,
  frame = TRUE,
  background = "gray!5",
  filename = "coef_frame",
  sub_dir = output_dir
)
expect_true(file.exists(result))
