# zztab2fig User Guide

## Overview

The `zztab2fig` package (v0.2.0) converts R data frames and statistical
objects into publication-quality LaTeX tables with automatic PDF generation.
The package supports S3 dispatch for common model objects, journal-specific
themes, inline tables for R Markdown, and advanced formatting features.

## Installation

```r
# From GitHub
devtools::install_github("rgt47/zztab2fig")

# Load the package
library(zztab2fig)

# Verify LaTeX dependencies
check_latex_deps()
```

## Quick Start

### Basic Table Generation

```r
# Simple data frame to PDF table
t2f(mtcars[1:6, 1:4], filename = "basic_table")

# Output files created in ./figures/:
#   basic_table.tex         (LaTeX source)
#   basic_table.pdf         (full PDF)
#   basic_table_cropped.pdf (cropped for inclusion)
```

### Statistical Model Tables

```r
# Linear model coefficient table
model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
t2f(model, filename = "regression")

# GLM with odds ratios
logit <- glm(am ~ hp + wt, data = mtcars, family = binomial)
t2f(logit, filename = "logistic", exponentiate = TRUE)
```

### Journal Themes

```r
# Apply NEJM styling
t2f(mtcars[1:6, 1:4], theme = "nejm", filename = "nejm_table")

# Set global theme for session
t2f_theme_set("lancet")
t2f(mtcars[1:6, 1:4], filename = "lancet_table")
```

## Core Function: t2f()

The `t2f()` function is an S3 generic that dispatches to type-specific
methods based on the input object class.

### Function Signature

```r
t2f(x, filename = NULL, sub_dir = "figures", scolor = NULL,
    verbose = FALSE, extra_packages = NULL, document_class = NULL,
    caption = NULL, label = NULL, align = NULL, longtable = FALSE,
    crop = TRUE, crop_margin = 10, theme = NULL, ...)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | object | required | Data frame, matrix, or model object |
| `filename` | character | NULL | Base name for output files |
| `sub_dir` | character | "figures" | Output directory |
| `scolor` | character | NULL | Row shading color (LaTeX format) |
| `theme` | character/theme | NULL | Theme name or t2f_theme object |
| `caption` | character | NULL | LaTeX table caption |
| `label` | character | NULL | LaTeX cross-reference label |
| `align` | vector/list | NULL | Column alignment specification |
| `longtable` | logical | FALSE | Multi-page table support |
| `crop` | logical | TRUE | Crop PDF margins |
| `crop_margin` | numeric | 10 | Crop margin in points |
| `verbose` | logical | FALSE | Print progress messages |

### Supported Object Types

#### Base R Objects

| Class | Method | Description |
|-------|--------|-------------|
| `data.frame` | `t2f.data.frame()` | Direct table conversion |
| `matrix` | `t2f.matrix()` | Matrix with optional row names |
| `table` | `t2f.table()` | Contingency table conversion |

#### Statistical Models

| Class | Method | Key Options |
|-------|--------|-------------|
| `lm` | `t2f.lm()` | `include`, `conf.int`, `stars` |
| `glm` | `t2f.glm()` | `exponentiate` for odds ratios |
| `anova` | `t2f.anova()` | ANOVA table formatting |
| `aov` | `t2f.aov()` | AOV summary table |
| `htest` | `t2f.htest()` | Hypothesis test results |

#### Survival Models (via broom)

| Class | Method | Package |
|-------|--------|---------|
| `coxph` | `t2f.coxph()` | survival |
| `survreg` | `t2f.survreg()` | survival |
| `survfit` | `t2f.survfit()` | survival |
| `survdiff` | `t2f.survdiff()` | survival |

#### Additional Models (via broom)

| Class | Method | Package |
|-------|--------|---------|
| `nls` | `t2f.nls()` | stats |
| `Arima` | `t2f.Arima()` | stats |
| `polr` | `t2f.polr()` | MASS |
| `multinom` | `t2f.multinom()` | nnet |
| `prcomp` | `t2f.prcomp()` | stats |
| `kmeans` | `t2f.kmeans()` | stats |

#### Mixed Effects Models (via broom.mixed)

| Class | Method | Package |
|-------|--------|---------|
| `lmerMod` | `t2f.lmerMod()` | lme4 |
| `glmerMod` | `t2f.glmerMod()` | lme4 |
| `lme` | `t2f.lme()` | nlme |

## Theme System

### Built-in Themes

```r
# List available themes
t2f_list_themes()
# [1] "minimal" "apa" "nature" "nejm" "lancet"

# Apply theme by name
t2f(df, theme = "nejm")

# Or use theme function directly
t2f(df, theme = t2f_theme_lancet())
```

| Theme | Font | Shading | Style |
|-------|------|---------|-------|
| `minimal` | Helvetica | blue!10 | Clean, simple |
| `apa` | Times | gray!8 | APA 7th edition |
| `nature` | Helvetica | white | Nature journals |
| `nejm` | Helvetica | #FEF8EA | NEJM warm shade |
| `lancet` | Helvetica | white | Lancet clean |

### Global Theme

```r
# Set theme for entire session
t2f_theme_set("nejm")

# Get current theme
current <- t2f_theme_get()

# Clear global theme
t2f_theme_set(NULL)
```

### Custom Themes

```r
# Create custom theme
my_theme <- t2f_theme(
  name = "custom_journal",
  scolor = "gray!5",
  header_bold = TRUE,
  font_size = "small",
  booktabs = TRUE,
  striped = TRUE,
  extra_packages = list(
    geometry(margin = "15mm"),
    "\\usepackage{helvet}",
    "\\renewcommand{\\familydefault}{\\sfdefault}"
  )
)

# Register for use by name
t2f_theme_register(my_theme)
t2f(df, theme = "custom_journal")

# Unregister when done
t2f_theme_unregister("custom_journal")
```

## Model Comparison Tables

### t2f_regression()

Generate side-by-side comparison of multiple regression models:

```r
m1 <- lm(mpg ~ cyl, data = mtcars)
m2 <- lm(mpg ~ cyl + hp, data = mtcars)
m3 <- lm(mpg ~ cyl + hp + wt, data = mtcars)

t2f_regression(
  Model1 = m1,
  Model2 = m2,
  Model3 = m3,
  stars = TRUE,
  filename = "model_comparison"
)
```

### Options

| Parameter | Default | Description |
|-----------|---------|-------------|
| `include` | c("estimate", "std.error") | Statistics to include |
| `stars` | c(0.05, 0.01, 0.001) | Significance thresholds |
| `digits` | 3 | Decimal places |
| `se_in_parens` | TRUE | Show SE in parentheses |

## Inline Tables for R Markdown

### t2f_inline()

Insert tables directly in R Markdown without LaTeX floats:

```r
t2f_inline(
  model,
  width = "3in",
  align = "center",
  caption = "Model Results",
  label = "tab:model",
  caption_position = "above"
)
```

### Visual Styling

```r
# Add frame border
t2f_inline(df,
  frame = TRUE,
  frame_color = "gray",
  frame_width = "0.5pt"
)

# Add background color
t2f_inline(df,
  background = "gray!5",
  inner_sep = "4pt"
)

# Both frame and background
t2f_inline(df,
  frame = TRUE,
  frame_color = "blue!50",
  background = "blue!5"
)
```

### t2f_coef()

Convenience function for coefficient tables:

```r
model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
t2f_coef(model, caption = "Regression Coefficients")
```

## Column Alignment

### Basic Alignment

```r
# Auto-detect: numeric=right, character=left
t2f(df, align = NULL)

# Explicit per-column
t2f(df, align = c("l", "r", "c", "r"))

# Single value for all columns
t2f(df, align = "c")
```

### Decimal Alignment with siunitx

```r
# Create decimal-aligned column specification
t2f(df, align = list(
  "l",                              # Left-aligned text
  t2f_siunitx(table_format = "3.2"), # 3 integer, 2 decimal digits
  t2f_decimal(4, 3)                  # Convenience: 4 integer, 3 decimal
))
```

## Captions and Labels

```r
t2f(df,
    caption = "Summary Statistics by Group",
    label = "tab:summary",
    filename = "summary_table")

# In LaTeX document:
# Table~\ref{tab:summary} shows the results...
```

## Multi-Page Tables

```r
# Large tables spanning multiple pages
t2f(large_data,
    longtable = TRUE,
    caption = "Complete Dataset",
    filename = "long_table")
```

## Advanced Features

### Footnotes

```r
fn <- t2f_footnote(
  general = "Data collected 2024",
  symbol = c("p < 0.05", "p < 0.01")
)

t2f(df, footnote = fn, filename = "with_notes")
```

### Spanning Headers

```r
hdr <- t2f_header_above(" " = 1, "Group A" = 2, "Group B" = 2)
t2f(df, header_above = hdr, filename = "with_header")
```

### Collapsed Rows

```r
collapse <- t2f_collapse_rows(columns = 1, valign = "top")
t2f(grouped_data, collapse_rows = collapse)
```

### Cell Formatting

```r
# Bold specific columns
fmt <- t2f_bold_col(c(1, 3))

# Conditional highlighting
fmt <- t2f_highlight(
  condition = function(x) x > 0.05,
  color = "red"
)

t2f(df, formatting = fmt)
```

## Batch Processing

### Basic Batch

```r
data_list <- list(
  summary = summary_df,
  results = results_df,
  appendix = appendix_df
)

t2f_batch(data_list, sub_dir = "tables", theme = "apa")
```

### Advanced Batch

```r
specs <- list(
  t2f_batch_spec(summary_df, "summary", theme = "nejm"),
  t2f_batch_spec(results_df, "results", theme = "lancet"),
  t2f_batch_spec(appendix_df, "appendix", longtable = TRUE)
)

t2f_batch_advanced(specs, sub_dir = "tables")
```

## Output Formats

### Default: PDF

```r
t2f(df, filename = "table")
# Creates: table.tex, table.pdf, table_cropped.pdf
```

### PNG Output

```r
# Via t2f_inline
t2f_inline(df, format = "png", dpi = 300)

# Direct conversion
convert_pdf_to_png("figures/table_cropped.pdf", "figures/table.png")
```

### SVG Output

```r
convert_pdf_to_svg("figures/table_cropped.pdf", "figures/table.svg")
```

### LaTeX Only

```r
t2f(df, crop = FALSE)
# Use the .tex file directly
```

## LaTeX Package Helpers

### geometry()

```r
geometry(margin = "5mm")
geometry(margin = "15mm", paper = "a4paper")
geometry(margin = "10mm", landscape = TRUE)
```

### babel()

```r
babel("spanish")
babel("french")
```

### fontspec()

```r
fontspec(main_font = "Times New Roman")
fontspec(main_font = "Helvetica", sans_font = "Arial")
```

## Caching

```r
# Enable caching for faster regeneration
t2f(df, cache = TRUE, filename = "cached_table")

# Force regeneration
t2f(df, cache = TRUE, force = TRUE, filename = "cached_table")

# Cache management
t2f_cache_info()
t2f_cache_clear(older_than = 7)  # Days
```

## knitr Engine

Register the custom t2f engine for R Markdown chunks:

````markdown
```{t2f, t2f.caption="My Table", t2f.theme="nejm"}
mtcars[1:5, 1:4]
```
````

## Troubleshooting

### Check Dependencies

```r
check_latex_deps()
```

### Missing pdfcrop

```r
# With TinyTeX
ensure_pdfcrop(auto_install = TRUE)

# Manual installation
# macOS:  brew install pdfcrop
# Ubuntu: sudo apt install texlive-extra-utils
```

### LaTeX Compilation Errors

```r
# Enable verbose mode
t2f(df, verbose = TRUE)

# Check log file
readLines("figures/table.log")
```

### Common Issues

| Issue | Solution |
|-------|----------|
| pdflatex not found | Install LaTeX distribution |
| Directory not writable | Check permissions or use different sub_dir |
| Special characters | Data is auto-sanitized; check for unusual symbols |
| Table too wide | Use `geometry(landscape = TRUE)` |

## Best Practices

### Data Preparation

```r
# Clean and format before table generation
clean_data <- df |>
  dplyr::mutate(dplyr::across(where(is.numeric), \(x) round(x, 2))) |>
  dplyr::mutate(dplyr::across(everything(), \(x) ifelse(is.na(x), "---", x)))
```
### Consistent Styling

```r
# Define project-wide settings
project_style <- list(
  theme = "nejm",
  sub_dir = "manuscript/tables"
)

# Apply consistently
t2f(table1, filename = "table1", !!!project_style)
t2f(table2, filename = "table2", !!!project_style)
```

### File Organization

```r
# Organize by project structure
t2f(df, filename = "results", sub_dir = "manuscript/tables")
t2f(df, filename = "appendix_a", sub_dir = "manuscript/supplementary")
```

## See Also

- `vignette("quickstart")` - Quick start guide
- `vignette("object-types-and-themes")` - Detailed theme and S3 documentation
- `vignette("advanced-features")` - Advanced formatting features
- `?t2f` - Function documentation
