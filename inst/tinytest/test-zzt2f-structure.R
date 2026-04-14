# Tests for zzt2f Batch B structural helpers.

# --- zzt2f_header_above delegates to t2f_header_above ---

h <- zzt2f_header_above(" " = 1, "Treatment" = 2, "Control" = 2)
expect_inherits(h, "t2f_header")
expect_equal(sum(h$header), 5)

# --- zzt2f_collapse_rows constructor ---

cs <- zzt2f_collapse_rows("Group")
expect_inherits(cs, "zzt2f_collapse")
expect_equal(cs$columns, "Group")
expect_equal(cs$hline, "major")

expect_error(
  zzt2f_collapse_rows(columns = TRUE),
  "must be NULL, numeric, or character"
)
expect_error(
  zzt2f_collapse_rows(hline = "bogus"),
  "should be one of"
)

# --- apply_zzt2f_collapse visual merging ---

df <- data.frame(
  Group = rep(c("A", "B"), each = 3),
  Sub   = rep(c("x", "y", "z"), 2),
  Val   = 1:6,
  stringsAsFactors = FALSE
)

res <- zztab2fig:::apply_zzt2f_collapse(
  df, zzt2f_collapse_rows("Group")
)
expect_equal(res$data$Group, c("A", "", "", "B", "", ""))
expect_equal(res$boundaries, 4L)

# Full hline mode across multiple columns
res_full <- zztab2fig:::apply_zzt2f_collapse(
  df,
  zzt2f_collapse_rows(c("Group", "Sub"), hline = "full")
)
expect_equal(res_full$data$Group, c("A", "", "", "B", "", ""))
expect_equal(res_full$data$Sub, c("x", "y", "z", "x", "y", "z"))

# NULL spec passes through
passthrough <- zztab2fig:::apply_zzt2f_collapse(df, NULL)
expect_identical(passthrough$data, df)
expect_equal(passthrough$boundaries, integer(0))

# Invalid input
expect_error(
  zztab2fig:::apply_zzt2f_collapse(df, list("not a spec")),
  "zzt2f_collapse"
)

# --- pp_separator_hline accepts vector of rows ---

lines <- c(
  "#table(", " columns: 3,",
  " // tinytable lines before",
  " [a], [b], [c],",
  " [d], [e], [f]",
  ")"
)
out <- zztab2fig:::pp_separator_hline(lines, c(1L, 2L), 3L)
hline_rows <- grep("table.hline", out, value = TRUE)
expect_equal(length(hline_rows), 2L)
expect_true(any(grepl("y: 2", hline_rows)))
expect_true(any(grepl("y: 3", hline_rows)))

# --- End-to-end with Typst ---

has_typst <- nzchar(Sys.which("typst"))
has_tt <- requireNamespace("tinytable", quietly = TRUE)

if (has_typst && has_tt) {
  tmp <- file.path(tempdir(), "zzt2f_struct_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)

  out <- zzt2f(
    df,
    filename = "collapse_demo",
    sub_dir = tmp,
    collapse_rows = zzt2f_collapse_rows("Group")
  )
  expect_true(file.exists(out))

  # header_above end-to-end
  wide <- data.frame(
    name = c("a", "b"),
    t1 = 1:2, t2 = 3:4, c1 = 5:6, c2 = 7:8
  )
  out2 <- zzt2f(
    wide,
    filename = "header_demo",
    sub_dir = tmp,
    header_above = zzt2f_header_above(
      " " = 1, "Treatment" = 2, "Control" = 2
    )
  )
  expect_true(file.exists(out2))
}
