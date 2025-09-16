# Create a table with custom margins and language support
t2f(
  df = mtcars,
  filename = "mtcars_custom",
  sub_dir = "tables", 
  extra_packages = list(
    geometry(margin = "5mm", paper = "a4paper"),
    babel("spanish")
  ),
  verbose = TRUE
)

# Wide table with landscape orientation
t2f(
  df = mtcars,
  filename = "mtcars_wide",
  extra_packages = list(
    geometry(margin = "3mm", landscape = TRUE)
  )
)
