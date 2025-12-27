# zztab2fig: LaTeX Table Generation and PDF Export for R

## Abstract

The `zztab2fig` package (v0.2.0) provides a comprehensive solution for
converting R data frames and statistical model objects into publication-quality
LaTeX tables with automated PDF generation and cropping capabilities. The
package features S3 dispatch for 20+ object types, journal-specific themes,
inline tables for R Markdown, model comparison tables, and batch processing.

## Table of Contents

1. [Installation](#installation)
2. [System Requirements](#system-requirements)
3. [Quick Start](#quick-start)
4. [Core Features](#core-features)
5. [S3 Method Dispatch](#s3-method-dispatch)
6. [Theme System](#theme-system)
7. [Inline Tables](#inline-tables)
8. [Model Comparison](#model-comparison)
9. [Advanced Features](#advanced-features)
10. [Comparison with Alternatives](#comparison-with-alternatives)
11. [Performance Considerations](#performance-considerations)
12. [Troubleshooting](#troubleshooting)
13. [Contributing](#contributing)
14. [License](#license)

## Installation

### From GitHub

```r
# Install from GitHub
devtools::install_github("rgt47/zztab2fig")
```

### Verification

```r
library(zztab2fig)
packageVersion("zztab2fig")
# [1] '0.2.0'

# Verify LaTeX dependencies
check_latex_deps()
```

## System Requirements

### R Environment

- **R Version**: >= 4.1.0 (for native pipe operator)
- **Required Packages**: `kableExtra`, `stats`, `utils`
- **Suggested Packages**: `broom`, `broom.mixed`, `tinytex`, `digest`

### LaTeX Distribution

The package requires a functional LaTeX installation with `pdflatex` and
`pdfcrop` utilities:

**Ubuntu/Debian:**

```bash
sudo apt-get install texlive texlive-extra-utils texlive-fonts-recommended
```

**macOS:**

```bash
# Via Homebrew
brew install --cask mactex

# Or install TinyTeX from R
tinytex::install_tinytex()
```

**Windows:**

Install MiKTeX from [https://miktex.org/](https://miktex.org/) or TinyTeX:

```r
tinytex::install_tinytex()
```

**Verification:**

```r
check_latex_deps()
# ✓ pdflatex found
# ✓ pdfcrop found
```

## Quick Start

### Basic Data Frame Table

```r
library(zztab2fig)

# Generate table from data frame
t2f(mtcars[1:6, 1:4], filename = "basic_table")

# Output files in ./figures/:
#   basic_table.tex         (LaTeX source)
#   basic_table.pdf         (full PDF)
#   basic_table_cropped.pdf (cropped for inclusion)
```

### Statistical Model Table

```r
# Linear regression coefficients
model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
t2f(model, filename = "regression")

# Logistic regression with odds ratios
logit <- glm(am ~ hp + wt, data = mtcars, family = binomial)
t2f(logit, filename = "logistic", exponentiate = TRUE)
```

### With Journal Theme

```r
# Apply NEJM styling
t2f(mtcars[1:6, 1:4], theme = "nejm", filename = "nejm_table")
```

## Core Features

### 1. S3 Generic Dispatch

The `t2f()` function automatically detects object types and generates
appropriate tables:

```r
# Data frames
t2f(df)

# Linear models
t2f(lm_model)

# ANOVA tables
t2f(aov_result)

# Survival models
t2f(coxph_model)
```

### 2. Theme System

Five built-in journal themes plus custom theme support:

```r
# Apply theme by name
t2f(df, theme = "nejm")

# Set session-wide theme
t2f_theme_set("lancet")
```

### 3. Inline Tables for R Markdown

Generate tables inline without floats:

```r
t2f_inline(model, width = "3in", caption = "Results")
```

### 4. Model Comparison Tables

Side-by-side regression comparison:

```r
t2f_regression(
  Model1 = m1,
  Model2 = m2,
  Model3 = m3,
  stars = TRUE
)
```

### 5. Batch Processing

Process multiple tables with consistent styling:

```r
t2f_batch(
  list(table1 = df1, table2 = df2),
  theme = "apa",
  sub_dir = "manuscript/tables"
)
```

## S3 Method Dispatch

### Supported Object Types

| Category | Classes | Method |
|----------|---------|--------|
| **Base R** | data.frame, matrix, table | Direct conversion |
| **Linear Models** | lm, glm, anova, aov | Coefficient tables |
| **Tests** | htest | Test statistics |
| **Survival** | coxph, survreg, survfit, survdiff | Hazard ratios |
| **Mixed Models** | lmerMod, glmerMod, lme | Fixed/random effects |
| **Other** | nls, Arima, polr, multinom, prcomp, kmeans | Model-specific |

### Linear Model Options

```r
model <- lm(mpg ~ cyl + hp + wt, data = mtcars)

# Basic coefficient table
t2f(model)

# With confidence intervals
t2f(model, conf.int = TRUE)

# Select specific terms
t2f(model, include = c("estimate", "std.error", "p.value"))

# With significance stars
t2f(model, stars = TRUE)
```

### GLM with Exponentiation

```r
logit <- glm(am ~ hp + wt, data = mtcars, family = binomial)

# Odds ratios
t2f(logit, exponentiate = TRUE)
```

### Survival Models

```r
library(survival)
cox <- coxph(Surv(time, status) ~ age + sex, data = lung)

# Hazard ratios
t2f(cox, exponentiate = TRUE)
```

## Theme System

### Built-in Themes

| Theme | Description | Font | Shading |
|-------|-------------|------|---------|
| `minimal` | Clean, simple | Helvetica | blue!10 |
| `apa` | APA 7th edition | Times | gray!8 |
| `nature` | Nature journals | Helvetica | white |
| `nejm` | NEJM style | Helvetica | #FEF8EA |
| `lancet` | Lancet clean | Helvetica | white |

### Using Themes

```r
# By name
t2f(df, theme = "nejm")

# By function
t2f(df, theme = t2f_theme_lancet())

# Session-wide
t2f_theme_set("apa")
t2f(df1)  # Uses APA
t2f(df2)  # Uses APA
t2f_theme_set(NULL)  # Clear
```

### Custom Themes

```r
my_theme <- t2f_theme(
  name = "corporate",
  scolor = "companyblue!10",
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
t2f(df, theme = "corporate")

# Unregister when done
t2f_theme_unregister("corporate")
```

## Inline Tables

### Basic Usage

```r
# In R Markdown chunk with results='asis'
model <- lm(mpg ~ cyl + hp, data = mtcars)
t2f_inline(model, width = "3in")
```

### With Caption and Label

```r
t2f_inline(
  model,
  width = "4in",
  caption = "Regression coefficients for fuel efficiency",
  label = "tab:regression",
  caption_position = "above"
)
```

### Visual Styling

```r
# With frame border
t2f_inline(df,
  frame = TRUE,
  frame_color = "gray",
  frame_width = "0.5pt"
)

# With background color
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

### Quick Coefficient Table

```r
t2f_coef(model, caption = "Model Coefficients")
```

## Model Comparison

### Side-by-Side Regression

```r
m1 <- lm(mpg ~ cyl, data = mtcars)
m2 <- lm(mpg ~ cyl + hp, data = mtcars)
m3 <- lm(mpg ~ cyl + hp + wt, data = mtcars)

t2f_regression(
  "Base" = m1,
  "+ Horsepower" = m2,
  "+ Weight" = m3,
  stars = TRUE,
  digits = 3,
  se_in_parens = TRUE,
  filename = "model_comparison"
)
```

### Options

| Parameter | Default | Description |
|-----------|---------|-------------|
| `include` | estimate, std.error | Statistics to show |
| `stars` | c(0.05, 0.01, 0.001) | Significance thresholds |
| `digits` | 3 | Decimal places |
| `se_in_parens` | TRUE | SE in parentheses below estimate |

## Advanced Features

### Column Alignment

```r
# Auto-detect (numeric=right, character=left)
t2f(df, align = NULL)

# Explicit per-column
t2f(df, align = c("l", "r", "c", "r"))

# Decimal alignment with siunitx
t2f(df, align = list(
  "l",
  t2f_siunitx(table_format = "3.2"),
  t2f_decimal(4, 3)
))
```

### Captions and Labels

```r
t2f(df,
  caption = "Summary Statistics by Group",
  label = "tab:summary",
  filename = "summary_table"
)

# In LaTeX: Table~\ref{tab:summary}
```

### Multi-Page Tables

```r
t2f(large_data,
  longtable = TRUE,
  caption = "Complete Dataset",
  filename = "long_table"
)
```

### Footnotes

```r
fn <- t2f_footnote(
  general = "Data collected 2024",
  symbol = c("p < 0.05", "p < 0.01")
)

t2f(df, footnote = fn)
```

### Spanning Headers

```r
hdr <- t2f_header_above(" " = 1, "Group A" = 2, "Group B" = 2)
t2f(df, header_above = hdr)
```

### Row Collapsing

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

### Batch Processing

```r
# Basic batch
data_list <- list(
  summary = summary_df,
  results = results_df,
  appendix = appendix_df
)

t2f_batch(data_list, sub_dir = "tables", theme = "apa")

# Advanced batch with individual specs
specs <- list(
  t2f_batch_spec(summary_df, "summary", theme = "nejm"),
  t2f_batch_spec(results_df, "results", theme = "lancet"),
  t2f_batch_spec(appendix_df, "appendix", longtable = TRUE)
)

t2f_batch_advanced(specs, sub_dir = "tables")
```

### Output Formats

```r
# Default: PDF
t2f(df, filename = "table")
# Creates: table.tex, table.pdf, table_cropped.pdf

# PNG output (via t2f_inline)
t2f_inline(df, format = "png", dpi = 300)

# Direct conversion
convert_pdf_to_png("figures/table_cropped.pdf", "figures/table.png")
convert_pdf_to_svg("figures/table_cropped.pdf", "figures/table.svg")
```

### Caching

```r
# Enable caching
t2f(df, cache = TRUE, filename = "cached_table")

# Force regeneration
t2f(df, cache = TRUE, force = TRUE, filename = "cached_table")

# Cache management
t2f_cache_info()
t2f_cache_clear(older_than = 7)  # Days
```

### knitr Engine

````markdown
```{t2f, t2f.caption="My Table", t2f.theme="nejm"}
mtcars[1:5, 1:4]
```
````

## Comparison with Alternatives

### zztab2fig vs. flextable

| Feature | zztab2fig | flextable |
|---------|-----------|-----------|
| **Primary Use** | LaTeX PDF tables | Multi-format export |
| **Output Quality** | Professional LaTeX | R graphics |
| **File Types** | PDF, PNG, SVG, TEX | PDF, DOCX, PPTX, HTML |
| **S3 Dispatch** | 20+ model types | Manual conversion |
| **Journal Themes** | 5 built-in | Manual styling |
| **Model Comparison** | Built-in | Manual |
| **Learning Curve** | Minimal | Moderate |
| **Dependencies** | LaTeX required | Self-contained |

### When to Choose zztab2fig

**Ideal for:**

- Academic papers requiring LaTeX typography
- Regression and survival model tables
- Multi-model comparison tables
- Batch processing with consistent styling
- Integration with existing LaTeX workflows

**Consider alternatives for:**

- Microsoft Office integration
- Interactive HTML tables
- No LaTeX available

## Performance Considerations

### Benchmarks

| Table Size | Total Time | LaTeX Gen | PDF Compile |
|------------|------------|-----------|-------------|
| 10x5 | 1.2s | 0.1s | 1.0s |
| 100x10 | 1.8s | 0.2s | 1.4s |
| 1000x20 | 4.5s | 0.8s | 3.2s |

### Optimization Strategies

```r
# Enable caching for repeated runs
t2f(df, cache = TRUE)

# Use batch processing
t2f_batch(table_list, theme = "minimal")

# Minimal document class for large tables
t2f(large_df,
  document_class = "minimal",
  extra_packages = list(geometry(margin = "2mm"))
)
```

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
| Directory not writable | Check permissions |
| Special characters | Data is auto-sanitized |
| Table too wide | Use `geometry(landscape = TRUE)` |
| Memory issues | Process in batches |

## Contributing

### Development Setup

```bash
git clone https://github.com/rgt47/zztab2fig.git
cd zztab2fig

R -e "devtools::install_dev_deps()"
R -e "devtools::test()"
R -e "devtools::document()"
R -e "devtools::check()"
```

### Code Quality Standards

- Follow tidyverse style guidelines
- Maintain >95% test coverage
- Document all exported functions
- Include working examples
- Validate all inputs

## License

GNU General Public License (GPL) version 3 or later.

## Citation

```
Thomas, R.G. (2025). zztab2fig: Generate LaTeX Tables and PDF Outputs.
R package version 0.2.0. https://github.com/rgt47/zztab2fig
```

## Contact

**Author:** Ronald G. Thomas
**Email:** rgthomas@ucsd.edu
**ORCID:** 0000-0003-1686-4965
**GitHub:** https://github.com/rgt47/zztab2fig
**Issues:** https://github.com/rgt47/zztab2fig/issues

## Acknowledgments

- The `kableExtra` package for LaTeX table generation
- The `broom` package for model tidying
- The R Core Team for the R statistical computing environment
- The LaTeX Project for the typesetting system
