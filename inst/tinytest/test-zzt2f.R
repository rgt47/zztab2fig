# --- Color translation ---

# hex passes through unchanged
expect_equal(
  zztab2fig:::translate_latex_color("#FF0000"),
  "#FF0000"
)
expect_equal(
  zztab2fig:::translate_latex_color("#aabbcc"),
  "#AABBCC"
)

# named LaTeX colors
expect_equal(zztab2fig:::translate_latex_color("red"), "#FF0000")
expect_equal(zztab2fig:::translate_latex_color("blue"), "#0000FF")
expect_equal(zztab2fig:::translate_latex_color("white"), "#FFFFFF")
expect_equal(zztab2fig:::translate_latex_color("black"), "#000000")

# color!N mixing syntax
result <- zztab2fig:::translate_latex_color("blue!10")
expect_true(grepl("^#[0-9A-F]{6}$", result))
rgb_vals <- grDevices::col2rgb(result)[, 1]
expect_true(rgb_vals[3] > rgb_vals[1])

pure_white <- zztab2fig:::translate_latex_color("blue!0")
expect_equal(pure_white, "#FFFFFF")

pure_blue <- zztab2fig:::translate_latex_color("blue!100")
expect_equal(pure_blue, "#0000FF")

# gray!5
result <- zztab2fig:::translate_latex_color("gray!5")
expect_true(grepl("^#[0-9A-F]{6}$", result))
rgb_vals <- grDevices::col2rgb(result)[, 1]
expect_true(all(rgb_vals > 240))

# nejmshade
expect_equal(
  zztab2fig:::translate_latex_color("nejmshade"),
  "#FEF8EA"
)

# NULL input
expect_null(zztab2fig:::translate_latex_color(NULL))

# unknown colors warn
expect_warning(
  result <- zztab2fig:::translate_latex_color("xyzcolor"),
  "Unrecognized color"
)
expect_true(grepl("^#[0-9A-F]{6}$", result))

# unknown base in mix syntax warns
expect_warning(
  zztab2fig:::translate_latex_color("xyzcolor!50"),
  "Unknown LaTeX color"
)


# --- Font size translation ---

expect_equal(zztab2fig:::translate_font_size("footnotesize"), 8)
expect_equal(zztab2fig:::translate_font_size("small"), 9)
expect_equal(zztab2fig:::translate_font_size("normalsize"), 10)
expect_equal(zztab2fig:::translate_font_size("tiny"), 5)
expect_equal(zztab2fig:::translate_font_size("large"), 12)

expect_null(zztab2fig:::translate_font_size(NULL))

expect_equal(zztab2fig:::translate_font_size("11"), 11)
expect_equal(zztab2fig:::translate_font_size("8.5"), 8.5)

expect_warning(
  result <- zztab2fig:::translate_font_size("notasize"),
  "Unknown LaTeX font size"
)
expect_equal(result, 10)


# --- Footnote translation ---

expect_null(zztab2fig:::translate_footnote(NULL))

expect_error(
  zztab2fig:::translate_footnote("plain string"),
  "must be a t2f_footnote"
)

# general notes
fn <- t2f_footnote(general = c("Note 1.", "Note 2."))
result <- zztab2fig:::translate_footnote(fn)
expect_equal(result, c("Note 1.", "Note 2."))

# numbered notes
fn <- t2f_footnote(number = c("First", "Second"))
result <- zztab2fig:::translate_footnote(fn)
expect_equal(result, c("1. First", "2. Second"))

# alphabetic notes
fn <- t2f_footnote(alphabet = c("Alpha", "Beta"))
result <- zztab2fig:::translate_footnote(fn)
expect_equal(result, c("a. Alpha", "b. Beta"))

# symbol notes
fn <- t2f_footnote(symbol = c("p < 0.05", "p < 0.01"))
result <- zztab2fig:::translate_footnote(fn)
expect_equal(length(result), 2)
expect_true(grepl("p", result[1], fixed = TRUE))
expect_true(grepl("0.05", result[1], fixed = TRUE))
expect_true(grepl("p", result[2], fixed = TRUE))
expect_true(grepl("0.01", result[2], fixed = TRUE))

# all note types combined
fn <- t2f_footnote(
  general = "General note.",
  number = "Numbered note.",
  alphabet = "Lettered note.",
  symbol = "Symbol note."
)
result <- zztab2fig:::translate_footnote(fn)
expect_equal(length(result), 4)

# empty footnote
fn <- t2f_footnote()
result <- zztab2fig:::translate_footnote(fn)
expect_null(result)


# --- Header translation ---

expect_null(zztab2fig:::translate_header_above(NULL))

# single header
hdr <- t2f_header_above(" " = 1, "Treatment" = 2, "Control" = 2)
result <- zztab2fig:::translate_header_above(hdr)
expect_equal(typeof(result), "list")
expect_true("Treatment" %in% names(result))
expect_true("Control" %in% names(result))
expect_equal(result$Treatment, 2:3)
expect_equal(result$Control, 4:5)

# skips blank labels
hdr <- t2f_header_above(" " = 2, "Group" = 3)
result <- zztab2fig:::translate_header_above(hdr)
expect_false(" " %in% names(result))
expect_true("Group" %in% names(result))
expect_equal(result$Group, 3:5)

# list of headers
hdr1 <- t2f_header_above(" " = 1, "A" = 2)
hdr2 <- t2f_header_above(" " = 1, "B" = 2)
result <- zztab2fig:::translate_header_above(list(hdr1, hdr2))
expect_equal(typeof(result), "list")
expect_equal(length(result), 2)


# --- resolve_typst_theme ---

ts <- zztab2fig:::resolve_typst_theme(NULL)
expect_equal(typeof(ts), "list")
expect_true("stripe_color" %in% names(ts))
expect_true("header_bold" %in% names(ts))
expect_true("font_size" %in% names(ts))
expect_true("striped" %in% names(ts))

# nejm theme
ts <- zztab2fig:::resolve_typst_theme("nejm")
expect_equal(ts$stripe_color, "#FEF8EA")
expect_true(ts$header_bold)
expect_equal(ts$font_size, 8)
expect_true(ts$striped)

# apa theme
ts <- zztab2fig:::resolve_typst_theme("apa")
expect_null(ts$stripe_color)
expect_false(ts$striped)

# scolor override
ts <- zztab2fig:::resolve_typst_theme("apa", scolor = "red!20")
expect_true(grepl("^#[0-9A-F]{6}$", ts$stripe_color))


# --- Input validation ---

if (!requireNamespace("tinytable", quietly = TRUE)) {
  exit_file("tinytable not installed")
}

expect_error(zzt2f("not a df"), "data.frame")
expect_error(zzt2f(data.frame()), "must not be empty")
expect_error(
  zzt2f(mtcars[1:3, 1:3], align = c("x", "y", "z")),
  "must contain only"
)
expect_error(
  zzt2f(mtcars[1:3, 1:3], dpi = -1),
  "must be a positive"
)
expect_error(
  zzt2f(mtcars[1:3, 1:3], footnote = "not a footnote"),
  "must be a t2f_footnote"
)


# --- check_typst_deps ---

result <- suppressMessages(check_typst_deps())
expect_equal(typeof(result), "list")
expect_true("tinytable" %in% names(result))
expect_true("typst" %in% names(result))
expect_true("ready" %in% names(result))


# --- Integration tests (require tinytable + typst) ---

if (!nzchar(Sys.which("typst"))) {
  exit_file("Typst CLI not available")
}

# zzt2f produces PDF
tmp <- tempdir()
out_dir <- file.path(tmp, "zzt2f_test_pdf")
dir.create(out_dir, showWarnings = FALSE)
result <- zzt2f(
  mtcars[1:5, 1:4],
  filename = "test_pdf",
  sub_dir = out_dir,
  format = "pdf"
)
expect_true(file.exists(result))
expect_true(grepl("\\.pdf$", result))
unlink(out_dir, recursive = TRUE)

# zzt2f produces PNG
out_dir <- file.path(tmp, "zzt2f_test_png")
dir.create(out_dir, showWarnings = FALSE)
result <- zzt2f(
  mtcars[1:5, 1:4],
  filename = "test_png",
  sub_dir = out_dir,
  format = "png",
  dpi = 150L
)
expect_true(file.exists(result))
expect_true(grepl("\\.png$", result))
unlink(out_dir, recursive = TRUE)

# zzt2f produces SVG
out_dir <- file.path(tmp, "zzt2f_test_svg")
dir.create(out_dir, showWarnings = FALSE)
result <- zzt2f(
  mtcars[1:5, 1:4],
  filename = "test_svg",
  sub_dir = out_dir,
  format = "svg"
)
expect_true(file.exists(result))
expect_true(grepl("\\.svg$", result))
unlink(out_dir, recursive = TRUE)

# zzt2f applies nejm theme
out_dir <- file.path(tmp, "zzt2f_test_nejm")
dir.create(out_dir, showWarnings = FALSE)
result <- zzt2f(
  mtcars[1:5, 1:4],
  filename = "test_nejm",
  sub_dir = out_dir,
  theme = "nejm",
  format = "pdf"
)
expect_true(file.exists(result))
unlink(out_dir, recursive = TRUE)

# zzt2f applies apa theme
out_dir <- file.path(tmp, "zzt2f_test_apa")
dir.create(out_dir, showWarnings = FALSE)
result <- zzt2f(
  mtcars[1:5, 1:4],
  filename = "test_apa",
  sub_dir = out_dir,
  theme = "apa",
  format = "pdf"
)
expect_true(file.exists(result))
unlink(out_dir, recursive = TRUE)

# zzt2f handles caption and footnotes
out_dir <- file.path(tmp, "zzt2f_test_caption")
dir.create(out_dir, showWarnings = FALSE)
fn <- t2f_footnote(
  general = "Data from mtcars.",
  symbol = c("p < 0.05")
)
result <- zzt2f(
  mtcars[1:5, 1:4],
  filename = "test_caption",
  sub_dir = out_dir,
  caption = "Motor Trend Cars",
  footnote = fn,
  format = "pdf"
)
expect_true(file.exists(result))
unlink(out_dir, recursive = TRUE)

# zzt2f handles matrix input
out_dir <- file.path(tmp, "zzt2f_test_matrix")
dir.create(out_dir, showWarnings = FALSE)
m <- matrix(
  1:12, nrow = 3,
  dimnames = list(NULL, c("A", "B", "C", "D"))
)
result <- zzt2f(m, filename = "test_matrix", sub_dir = out_dir)
expect_true(file.exists(result))
unlink(out_dir, recursive = TRUE)

# zzt2f handles spanning headers
out_dir <- file.path(tmp, "zzt2f_test_header")
dir.create(out_dir, showWarnings = FALSE)
hdr <- t2f_header_above(" " = 1, "Group A" = 2, "Group B" = 1)
result <- zzt2f(
  mtcars[1:5, 1:4],
  filename = "test_header",
  sub_dir = out_dir,
  header_above = hdr,
  format = "pdf"
)
expect_true(file.exists(result))
unlink(out_dir, recursive = TRUE)
