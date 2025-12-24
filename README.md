# zztab2fig

[![CRAN status](https://www.r-pkg.org/badges/version/zztab2fig)](https://CRAN.R-project.org/package=zztab2fig)
[![License](https://img.shields.io/badge/license-GPL3-blue.svg)](LICENSE)
[![R-CMD-check](https://github.com/rgt47/zztab2fig/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rgt47/zztab2fig/actions)

## Overview

**zztab2fig** is an R package for creating LaTeX tables from data frames and
statistical objects, generating cropped PDF outputs suitable for direct
inclusion in publications. The package provides journal-specific themes (APA,
Nature, NEJM), S3 methods for common statistical objects, and R Markdown
integration.

## Installation

### From GitHub

```r
# install.packages("devtools")
devtools::install_github("rgt47/zztab2fig")
```

### System Requirements

- R >= 4.0
- LaTeX distribution (TeX Live, MiKTeX, TinyTeX, or MacTeX)
- `pdflatex` and `pdfcrop` executables
- Optional: ImageMagick (for PNG output), pdf2svg (for SVG output)

Check your setup:

```r
library(zztab2fig)
check_latex_deps()
```

## Quick Start

```r
library(zztab2fig)

# Basic usage: data frame to cropped PDF
t2f(mtcars[1:6, 1:4], filename = "my_table")

# With journal theme
t2f(mtcars[1:6, 1:4], theme = "nejm", filename = "nejm_table")

# Statistical objects (lm, glm, anova, etc.)
model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
t2f(model, filename = "regression_table")

# Model comparison
m1 <- lm(mpg ~ cyl, data = mtcars)
m2 <- lm(mpg ~ cyl + hp, data = mtcars)
t2f_regression(Model1 = m1, Model2 = m2, stars = TRUE)
```

Output files generated:

- `my_table.tex` - LaTeX source
- `my_table.pdf` - Full PDF
- `my_table_cropped.pdf` - Cropped PDF for document inclusion

## Key Features

### Journal Themes

Built-in themes for common publication styles:

```r
t2f(data, theme = "nejm")     # New England Journal of Medicine
t2f(data, theme = "apa")      # American Psychological Association
t2f(data, theme = "nature")   # Nature journals
t2f(data, theme = "minimal")  # Clean, minimal style

# Set global theme
t2f_theme_set("nejm")
```

### Statistical Object Support

Direct conversion of statistical objects to formatted tables:

| Object Type | Method |
|:------------|:-------|
| `data.frame` | `t2f.data.frame()` |
| `matrix` | `t2f.matrix()` |
| `lm` | `t2f.lm()` |
| `glm` | `t2f.glm()` |
| `anova` / `aov` | `t2f.anova()` / `t2f.aov()` |
| `htest` | `t2f.htest()` |

Additional types via broom integration: `coxph`, `survreg`, `nls`, `polr`,
`prcomp`, `kmeans`, `lmerMod`, `glmerMod`, `lme`, `Arima`.

### R Markdown Integration

Inline tables without LaTeX float positioning issues:

```r
# In R Markdown
t2f_inline(model, width = "3in", caption = "Model Results")

# Quick coefficient table
t2f_coef(model, caption = "Coefficients")
```

### Decimal Alignment

Use siunitx for decimal-aligned numeric columns:

```r
t2f(df, align = list("l", t2f_siunitx(table_format = "3.3")))
```

### Multi-Page Tables

For large tables spanning multiple pages:
```r
t2f(large_data, longtable = TRUE, caption = "Complete Dataset")
```

## Function Reference

| Function | Purpose |
|:---------|:--------|
| `t2f()` | Convert object to PDF table |
| `t2f_inline()` | Inline tables for R Markdown |
| `t2f_coef()` | Quick coefficient tables |
| `t2f_regression()` | Compare regression models |
| `t2f_theme_set()` | Set global theme |
| `t2f_theme_get()` | Get current theme |
| `check_latex_deps()` | Check LaTeX dependencies |
| `ensure_pdfcrop()` | Install pdfcrop via TinyTeX |

## Key Parameters

| Parameter | Description | Default |
|:----------|:------------|:--------|
| `caption` | LaTeX table caption | NULL |
| `label` | LaTeX label for cross-refs | NULL |
| `align` | Column alignment (l/c/r) | NULL (auto) |
| `longtable` | Multi-page table support | FALSE |
| `crop` | Crop PDF margins | TRUE |
| `crop_margin` | Margin size (pts) | 10 |
| `theme` | Theme name or object | NULL |

## Why zztab2fig vs. flextable?

Both packages export tables as standalone PDF files, but serve different use
cases:

### Choose zztab2fig when you want:

- **LaTeX-native approach**: Creates actual LaTeX code using `pdflatex` and
  `pdfcrop` for professional LaTeX typography
- **Simplicity**: Single function `t2f()` with minimal parameters
- **LaTeX ecosystem integration**: Generated `.tex` files can be manually
  edited and work within existing LaTeX workflows
- **kableExtra styling**: Uses familiar kableExtra formatting
- **Lightweight solution**: Minimal dependencies focused on one specific task

### Choose flextable when you want:

- **Multi-format output**: Tables for Word, PowerPoint, HTML, and PDF
- **Mixed content**: Combine text and images within table cells
- **Extensive formatting**: More styling options and conditional formatting
- **R graphics system**: Uses R's native graphics system rather than external
  LaTeX tools

## Documentation

- `vignette("quickstart")` - Quick start guide
- `vignette("object-types-and-themes")` - Supported objects and themes
- `vignette("advanced-features")` - Advanced customization

## Reproducibility

This package is developed using the zzcollab framework for reproducible
research. To reproduce the development environment:

```bash
git clone https://github.com/rgt47/zztab2fig.git
cd zztab2fig
make r  # Enter Docker container with all dependencies
```

## License

GPL (>= 3)

## Author

RG Thomas (rgthomas@ucsd.edu)
