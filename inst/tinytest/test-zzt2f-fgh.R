# Tests for zzt2f Batches F (stat), G (preamble), H (siunitx).

has_typst <- nzchar(Sys.which("typst"))
has_tt <- requireNamespace("tinytable", quietly = TRUE)
has_broom <- requireNamespace("broom", quietly = TRUE)

# --------------------------------------------------------------------
# Batch F: stat helpers
# --------------------------------------------------------------------

if (has_broom && has_typst && has_tt) {
  tmp <- file.path(tempdir(), "zzt2f_stat_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)

  m <- lm(mpg ~ cyl + hp, data = mtcars)

  out <- zzt2f_tidy(
    m, filename = "lm_tidy", sub_dir = tmp, digits = 2
  )
  expect_true(file.exists(out))

  out2 <- zzt2f_coef(
    m, filename = "lm_coef", sub_dir = tmp, format = "pdf"
  )
  expect_true(file.exists(out2))
}

# zzt2f_rms_compare requires rms or, lacking it, errors cleanly.
if (requireNamespace("rms", quietly = TRUE)) {
  expect_error(zzt2f_rms_compare(), "At least one model")
} else {
  expect_error(zzt2f_rms_compare(), "Package 'rms' is required")
}

# --------------------------------------------------------------------
# Batch G: preamble emitters
# --------------------------------------------------------------------

expect_equal(zzt2f_textlang("de"), '#set text(lang: "de")')
expect_error(zzt2f_textlang(""), "non-empty")
expect_error(zzt2f_textlang(c("a", "b")), "single non-empty")

# zzt2f_font
out <- zzt2f_font(main_font = "New Computer Modern")
expect_equal(out, '#set text(font: "New Computer Modern")')

out2 <- zzt2f_font(main_font = "Source Serif",
                    mono_font = "Fira Code")
expect_equal(length(out2), 2L)
expect_true(any(grepl("show raw: set text", out2)))

# No arguments yields an empty character with a message
msg <- capture.output(empty <- zzt2f_font(), type = "message")
expect_equal(length(empty), 0L)

# zzt2f_page
expect_equal(zzt2f_page(), "#set page()")
expect_equal(
  zzt2f_page(paper = "a4"),
  '#set page(paper: "a4")'
)
expect_equal(
  zzt2f_page(paper = "us-letter", landscape = TRUE),
  '#set page(paper: "us-letter", flipped: true)'
)
expect_equal(
  zzt2f_page(margin = "2cm"),
  "#set page(margin: 2cm)"
)
expect_equal(
  zzt2f_page(margin = list(x = "2cm", y = "1.5cm")),
  "#set page(margin: (x: 2cm, y: 1.5cm))"
)
expect_equal(
  zzt2f_page(width = "auto", height = "auto"),
  "#set page(width: auto, height: auto)"
)
expect_error(
  zzt2f_page(margin = list("2cm", "1cm")),
  "fully named"
)

# --- Preamble emitters compose into a valid Typst document ---

if (has_typst) {
  tmp <- file.path(tempdir(), "zzt2f_preamble_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
  src <- c(
    zzt2f_page(paper = "a4",
               margin = list(x = "2cm", y = "2cm")),
    zzt2f_textlang("en"),
    zzt2f_font(main_font = "Libertinus Serif"),
    "= Preamble smoke test",
    "Lorem ipsum dolor sit amet."
  )
  writeLines(src, file.path(tmp, "p.typ"))
  status <- system2(
    "typst",
    c("compile", file.path(tmp, "p.typ"),
      file.path(tmp, "p.pdf")),
    stdout = TRUE, stderr = TRUE
  )
  # Libertinus may not be installed; tolerate compile failure but
  # require that bad Typst syntax is not the cause. A Typst syntax
  # error would report an "error:" line; a missing font yields a
  # warning. Check that no "error:" line appears.
  expect_false(any(grepl("^error:", status)))
}

# --------------------------------------------------------------------
# Batch H: siunitx / metro adapter
# --------------------------------------------------------------------

spec <- zzt2f_siunitx(table_format = "3.2")
expect_inherits(spec, "zzt2f_siunitx")
expect_true(any(grepl("@preview/metro", unclass(spec))))

spec2 <- zzt2f_siunitx(
  table_format = "2.3",
  round_mode = "places",
  round_precision = 3,
  group_separator = ","
)
expect_true(any(grepl("group-separator", unclass(spec2))))
expect_true(any(grepl("round-mode", unclass(spec2))))

# Input validation
expect_error(
  zzt2f_siunitx(table_format = "3"),
  "<int>\\.<dec>"
)
expect_error(
  zzt2f_siunitx(round_mode = "figures"),
  "requires `round_precision`"
)

# Print method runs without error
out <- capture.output(print(spec2))
expect_true(any(grepl("zzt2f_siunitx", out)))
expect_true(any(grepl("group_separator", out)))
