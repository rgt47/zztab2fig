# Tests for zzt2f Batch D figure-inclusion helpers.

# --- Path resolution ---

expect_equal(
  zztab2fig:::resolve_typst_path("figures/demo"),
  "figures/demo.pdf"
)
expect_equal(
  zztab2fig:::resolve_typst_path("figures/demo.pdf"),
  "figures/demo.pdf"
)
expect_equal(
  zztab2fig:::resolve_typst_path("out/x.png"),
  "out/x.pdf"
)

# --- Width translation ---

expect_equal(zztab2fig:::translate_width("\\textwidth"), "100%")
expect_equal(zztab2fig:::translate_width("0.8\\textwidth"), "80%")
expect_equal(zztab2fig:::translate_width("0.48\\textwidth"), "48%")
expect_equal(zztab2fig:::translate_width("5cm"), "5cm")
expect_equal(zztab2fig:::translate_width("80%"), "80%")
expect_equal(zztab2fig:::translate_width(NULL), "100%")

# --- zzt2f_include ---

out <- zzt2f_include(
  "fig/demo", caption = "Demo caption.", label = "tab-demo",
  cat = FALSE
)
expect_true(grepl('image\\("fig/demo.pdf"', out))
expect_true(grepl("caption: \\[Demo caption\\.\\]", out))
expect_true(grepl("<tab-demo>", out))
expect_true(grepl("align\\(center\\)", out))

# Bare, no caption, no center
out2 <- zzt2f_include("fig/demo", center = FALSE, cat = FALSE)
expect_false(grepl("align\\(center\\)", out2))
expect_false(grepl("caption:", out2))

# --- zzt2f_include_inline ---

out <- zzt2f_include_inline(
  "fig/demo", width = "0.9\\textwidth",
  vspace = "1em", cat = FALSE
)
expect_true(grepl("#v\\(1em\\)", out))
expect_true(grepl("width: 90%", out))
expect_true(grepl("align\\(center\\)", out))

# --- zzt2f_include_wrap ---

out <- zzt2f_include_wrap(
  "fig/demo", placement = "l", wrap_width = "0.4\\textwidth",
  caption = "Wrap me.", label = "tab-wrap", cat = FALSE
)
expect_true(grepl("place\\(left, float: true", out))
expect_true(grepl("caption: \\[Wrap me\\.\\]", out))
expect_true(grepl("<tab-wrap>", out))

# --- zzt2f_include_sidebyside ---

out <- zzt2f_include_sidebyside(
  "fig/a", "fig/b",
  caption1 = "A", caption2 = "B",
  main_caption = "Side by side",
  cat = FALSE
)
expect_true(grepl("grid\\(columns:", out))
expect_true(grepl('"fig/a.pdf"', out))
expect_true(grepl('"fig/b.pdf"', out))
expect_true(grepl("caption: \\[Side by side\\]", out))

# --- zzt2f_include_margin ---

out <- zzt2f_include_margin(
  "fig/demo", caption = "Marginal.", label = "tab-m",
  width = "4cm", offset = "100%", cat = FALSE
)
expect_true(grepl("place\\(right, dx: 100%", out))
expect_true(grepl("caption: \\[Marginal\\.\\]", out))
expect_true(grepl("<tab-m>", out))

# --- zzt2f_margin_packages returns NULL with a message ---

msg <- capture.output(
  res <- zzt2f_margin_packages("sidenotes"),
  type = "message"
)
expect_null(res)
expect_true(any(grepl("Typst requires no margin packages", msg)))

# --- End-to-end: embed a zzt2f-rendered table in a host Typst doc ---

has_typst <- nzchar(Sys.which("typst"))
has_tt <- requireNamespace("tinytable", quietly = TRUE)

if (has_typst && has_tt) {
  tmp <- file.path(tempdir(), "zzt2f_include_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)

  # First, render a table with zzt2f
  tab <- zzt2f(
    mtcars[1:3, 1:3],
    filename = "inner",
    sub_dir = tmp,
    format = "pdf"
  )
  expect_true(file.exists(tab))

  # Build a host .typ file that embeds the rendered table.
  # Typst rejects paths outside the project root, so we write the
  # host .typ beside the rendered PDF and reference it by basename.
  host_src <- c(
    "#set page(width: auto, height: auto, margin: 10pt)",
    zzt2f_include(
      "inner",
      caption = "Inner demo.",
      label = "tab-inner",
      cat = FALSE
    )
  )
  host_typ <- file.path(tmp, "host.typ")
  writeLines(host_src, host_typ)

  host_pdf <- file.path(tmp, "host.pdf")
  status <- system2(
    "typst", c("compile", host_typ, host_pdf),
    stdout = TRUE, stderr = TRUE
  )
  expect_true(file.exists(host_pdf))
}
