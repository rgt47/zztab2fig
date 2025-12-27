# API Reference: zztab2fig Package

## Package Information

- **Version**: 0.2.0
- **License**: GPL (>= 3)
- **Imports**: kableExtra, stats, utils
- **Suggests**: broom, broom.mixed, survival, lme4, nlme, tinytex
- **System Requirements**: LaTeX (pdflatex, pdfcrop)

## Primary Interface

### t2f()

S3 generic for converting objects to LaTeX tables with PDF output.

```r
t2f(x, ...)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | any | required | Object to convert (dispatches to S3 methods) |
| `...` | various | - | Arguments passed to methods |

**Returns:** Character string (invisible) with path to cropped PDF file.

### t2f.default()

Default method for data frame conversion.

```r
t2f.default(x, filename = NULL, sub_dir = "figures", scolor = NULL,
            verbose = FALSE, extra_packages = NULL, document_class = NULL,
            caption = NULL, caption_short = NULL, label = NULL, align = NULL,
            longtable = FALSE, crop = TRUE, crop_margin = 10,
            striped = NULL, footnote = NULL, header_above = NULL,
            collapse_rows = NULL, theme = NULL, cache = FALSE, force = FALSE,
            ...)
```

**Core Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | data.frame | required | Data frame to convert |
| `filename` | character | NULL | Output filename (auto-generated if NULL) |
| `sub_dir` | character | "figures" | Output directory |
| `scolor` | character | NULL | Row shading color |
| `verbose` | logical | FALSE | Print progress messages |

**Document Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `extra_packages` | list | NULL | Additional LaTeX packages |
| `document_class` | character | NULL | LaTeX document class |
| `caption` | character | NULL | Table caption |
| `caption_short` | character | NULL | Short caption for LoT |
| `label` | character | NULL | LaTeX label for cross-refs |

**Table Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `align` | vector/list | NULL | Column alignment specification |
| `longtable` | logical | FALSE | Multi-page table support |
| `striped` | logical | NULL | Alternating row colors |
| `footnote` | t2f_footnote | NULL | Table footnotes |
| `header_above` | t2f_header | NULL | Spanning headers |
| `collapse_rows` | t2f_collapse | NULL | Row merging specification |

**Output Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `crop` | logical | TRUE | Crop PDF margins |
| `crop_margin` | numeric | 10 | Margin size in points |
| `theme` | char/theme | NULL | Theme name or object |
| `cache` | logical | FALSE | Enable caching |
| `force` | logical | FALSE | Force regeneration |

## S3 Methods: Base Types

### t2f.data.frame()

```r
t2f.data.frame(x, ...)
```

Dispatches directly to `t2f.default()`.

### t2f.matrix()

```r
t2f.matrix(x, rownames = TRUE, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `rownames` | logical | TRUE | Include row names as column |

### t2f.table()

```r
t2f.table(x, ...)
```

Converts contingency table to data frame with row names preserved.

## S3 Methods: Statistical Models

### t2f.lm()

```r
t2f.lm(x, digits = 3, include = c("estimate", "std.error", "statistic",
       "p.value"), conf.int = FALSE, conf.level = 0.95, stars = FALSE, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `digits` | integer | 3 | Decimal places |
| `include` | character | see above | Statistics to include |
| `conf.int` | logical | FALSE | Include confidence intervals |
| `conf.level` | numeric | 0.95 | Confidence level |
| `stars` | logical | FALSE | Significance stars |

### t2f.glm()

```r
t2f.glm(x, digits = 3, include = c("estimate", "std.error", "statistic",
        "p.value"), conf.int = FALSE, conf.level = 0.95, exponentiate = FALSE,
        stars = FALSE, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `exponentiate` | logical | FALSE | Exponentiate coefficients (odds ratios) |

### t2f.anova()

```r
t2f.anova(x, digits = 3, ...)
```

### t2f.aov()

```r
t2f.aov(x, digits = 3, ...)
```

### t2f.htest()
```r
t2f.htest(x, digits = 3, ...)
```

Formats hypothesis test results (t.test, chisq.test, etc.).

## S3 Methods: Survival Models

Require `broom` and `survival` packages.

### t2f.coxph()

```r
t2f.coxph(x, digits = 3, exponentiate = TRUE, conf.int = TRUE,
          conf.level = 0.95, ...)
```

### t2f.survreg()

```r
t2f.survreg(x, digits = 3, conf.int = TRUE, conf.level = 0.95, ...)
```

### t2f.survfit()

```r
t2f.survfit(x, digits = 3, times = NULL, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `times` | numeric | NULL | Specific times to report |

### t2f.survdiff()

```r
t2f.survdiff(x, digits = 3, ...)
```

## S3 Methods: Additional Models

### t2f.nls()

```r
t2f.nls(x, digits = 3, conf.int = TRUE, conf.level = 0.95, ...)
```

### t2f.Arima()

```r
t2f.Arima(x, digits = 3, conf.int = TRUE, conf.level = 0.95, ...)
```

### t2f.polr()

```r
t2f.polr(x, digits = 3, exponentiate = FALSE, conf.int = TRUE, ...)
```

### t2f.multinom()

```r
t2f.multinom(x, digits = 3, exponentiate = FALSE, conf.int = TRUE, ...)
```

### t2f.prcomp()

```r
t2f.prcomp(x, matrix = "rotation", digits = 3, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `matrix` | character | "rotation" | "rotation" or "x" (scores) |

### t2f.kmeans()

```r
t2f.kmeans(x, matrix = "centers", digits = 3, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `matrix` | character | "centers" | "centers" or "cluster" |

## S3 Methods: Mixed Effects Models

Require `broom.mixed` package.

### t2f.lmerMod()

```r
t2f.lmerMod(x, effects = "fixed", digits = 3, conf.int = TRUE,
            conf.level = 0.95, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `effects` | character | "fixed" | "fixed", "random", or "all" |

### t2f.glmerMod()

```r
t2f.glmerMod(x, effects = "fixed", digits = 3, exponentiate = FALSE,
             conf.int = TRUE, conf.level = 0.95, ...)
```

### t2f.lme()

```r
t2f.lme(x, effects = "fixed", digits = 3, conf.int = TRUE,
        conf.level = 0.95, ...)
```

## Model Comparison

### t2f_regression()

```r
t2f_regression(..., include = c("estimate", "std.error"),
               stars = c(0.05, 0.01, 0.001), digits = 3,
               se_in_parens = TRUE, filename = "regression_table",
               sub_dir = "figures", theme = NULL)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `...` | models | required | Named model objects |
| `include` | character | see above | Statistics to include |
| `stars` | numeric | c(0.05, 0.01, 0.001) | Significance thresholds |
| `se_in_parens` | logical | TRUE | SE in parentheses below estimate |

**Example:**
```r
t2f_regression(
  Model1 = lm(mpg ~ cyl, mtcars),
  Model2 = lm(mpg ~ cyl + hp, mtcars),
  stars = TRUE
)
```

## Theme System

### t2f_theme()

```r
t2f_theme(name = "custom", scolor = "blue!10", header_bold = TRUE,
          header_color = NULL, font_size = NULL,
          document_class = "article", extra_packages = NULL,
          booktabs = TRUE, striped = TRUE)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | character | "custom" | Theme identifier |
| `scolor` | character | "blue!10" | Row shading color |
| `header_bold` | logical | TRUE | Bold column headers |
| `header_color` | character | NULL | Header background color |
| `font_size` | character | NULL | LaTeX font size command |
| `booktabs` | logical | TRUE | Use booktabs rules |
| `striped` | logical | TRUE | Alternating row colors |

### t2f_theme_set() / t2f_theme_get()

```r
t2f_theme_set(theme)
t2f_theme_get()
```

Set or retrieve the global theme. Pass NULL to clear.

### t2f_theme_register() / t2f_theme_unregister()

```r
t2f_theme_register(theme, name = NULL, overwrite = FALSE)
t2f_theme_unregister(name)
```

Register custom themes for use by name.

### t2f_theme_clear()

```r
t2f_theme_clear()
```

Remove all registered custom themes.

### t2f_list_themes()

```r
t2f_list_themes(builtin_only = FALSE)
```

List available theme names.

### Built-in Theme Functions

```r
t2f_theme_minimal()   # Clean, Helvetica, blue!10 shading
t2f_theme_apa()       # APA style, Times, gray!8 shading
t2f_theme_nature()    # Nature journals, Helvetica, no shading
t2f_theme_nejm()      # NEJM, Helvetica, #FEF8EA warm shading
t2f_theme_lancet()    # Lancet, Helvetica, no shading
```

## Inline Tables

### t2f_inline()

```r
t2f_inline(x, width = NULL, height = NULL,
           align = c("center", "left", "right"), filename = NULL,
           format = c("auto", "pdf", "png"), dpi = 150, sub_dir = NULL,
           caption = NULL, caption_short = NULL, label = NULL,
           caption_position = c("above", "below"),
           frame = FALSE, frame_color = "black", frame_width = "0.4pt",
           background = NULL, inner_sep = "2pt", ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | character | NULL | Figure width (e.g., "3in") |
| `height` | character | NULL | Figure height |
| `align` | character | "center" | Horizontal alignment |
| `format` | character | "auto" | Output format |
| `dpi` | integer | 150 | PNG resolution |
| `caption_position` | character | "above" | Caption placement |
| `frame` | logical | FALSE | Draw border |
| `frame_color` | character | "black" | Border color |
| `background` | character | NULL | Background color |
| `inner_sep` | character | "2pt" | Padding |

### t2f_coef()

```r
t2f_coef(model, width = "3in", align = "left", digits = 3,
         stars = TRUE, theme = "minimal", caption = NULL, ...)
```

Convenience function for inline coefficient tables.

## Advanced Features

### t2f_footnote()

```r
t2f_footnote(general = NULL, number = NULL, alphabet = NULL,
             symbol = NULL, threeparttable = TRUE)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `general` | character | NULL | General notes |
| `number` | character | NULL | Numbered footnotes |
| `symbol` | character | NULL | Symbol footnotes (*, †, ‡) |
| `threeparttable` | logical | TRUE | Use threeparttable package |

### t2f_mark()

```r
t2f_mark(text, mark, type = c("symbol", "number", "alphabet"))
```

Add footnote marker to cell text.

### t2f_header_above()

```r
t2f_header_above(..., bold = TRUE, italic = FALSE, line = TRUE)
```

Create spanning column headers. Arguments are named with column spans.

**Example:**
```r
t2f_header_above(" " = 1, "Group A" = 2, "Group B" = 2)
```

### t2f_collapse_rows()

```r
t2f_collapse_rows(columns = NULL, valign = c("middle", "top", "bottom"),
                  latex_hline = c("major", "none", "full"))
```

Merge repeated values in columns into multi-row cells.

### t2f_siunitx()

```r
t2f_siunitx(table_format = "3.2", detect_weight = TRUE, mode = "text")
```

Create decimal-aligned column specification using siunitx package.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `table_format` | character | "3.2" | Integer.decimal format |
| `detect_weight` | logical | TRUE | Detect bold/italic |
| `mode` | character | "text" | siunitx mode |

### t2f_decimal()

```r
t2f_decimal(integers = 3, decimals = 2)
```

Convenience wrapper for `t2f_siunitx()`.

## Cell Formatting

### t2f_format()

```r
t2f_format(rows = NULL, cols = NULL, bold = FALSE, italic = FALSE,
           color = NULL, background = NULL, condition = NULL)
```

Create formatting specification for cells.

### t2f_highlight()

```r
t2f_highlight(condition, color = "yellow")
```

Conditional cell highlighting.

### t2f_bold_col() / t2f_italic_col()

```r
t2f_bold_col(cols)
t2f_italic_col(cols)
```

Bold or italicize entire columns.

### t2f_color_row()

```r
t2f_color_row(rows, background)
```

Apply background color to rows.

## Batch Processing

### t2f_batch()

```r
t2f_batch(data_list, sub_dir = "figures", theme = NULL,
          parallel = FALSE, verbose = FALSE, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `data_list` | named list | required | Data frames to process |
| `parallel` | logical | FALSE | Use parallel processing |

### t2f_batch_spec()

```r
t2f_batch_spec(df, filename, ...)
```

Create specification for advanced batch processing.

### t2f_batch_advanced()

```r
t2f_batch_advanced(specs, sub_dir = "figures", theme = NULL,
                   parallel = FALSE, verbose = FALSE, ...)
```

Process multiple tables with per-table specifications.

## Caching

### t2f_cache_dir()

```r
t2f_cache_dir(create = TRUE)
```

Get or create cache directory path.

### t2f_cache_set_dir()

```r
t2f_cache_set_dir(path)
```

Set custom cache directory.

### t2f_cache_clear()

```r
t2f_cache_clear(older_than = NULL)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `older_than` | numeric | NULL | Clear files older than N days |

### t2f_cache_info()

```r
t2f_cache_info()
```

Display cache statistics.

## Output Conversion

### convert_pdf_to_png()

```r
convert_pdf_to_png(pdf_path, png_path = NULL, dpi = 150)
```

Requires ImageMagick.

### convert_pdf_to_svg()

```r
convert_pdf_to_svg(pdf_path, svg_path = NULL)
```

Requires pdf2svg.

## LaTeX Package Helpers

### geometry()

```r
geometry(margin = NULL, paper = NULL, landscape = FALSE, ...)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `margin` | character | NULL | Page margins |
| `paper` | character | NULL | Paper size |
| `landscape` | logical | FALSE | Landscape orientation |

### babel()

```r
babel(language)
```

### fontspec()

```r
fontspec(main_font = NULL, sans_font = NULL, mono_font = NULL)
```

## Utility Functions

### check_latex_deps()

```r
check_latex_deps()
```

Check and report LaTeX dependency status.

### ensure_pdfcrop()

```r
ensure_pdfcrop(auto_install = TRUE, verbose = TRUE)
```

Attempt to install pdfcrop via TinyTeX.

### register_t2f_engine()

```r
register_t2f_engine()
```

Register custom knitr engine for R Markdown.

## Internal Functions

These functions are not exported but documented for advanced use.

| Function | Description |
|----------|-------------|
| `t2f_internal()` | Core table generation logic |
| `create_latex_table()` | Generate LaTeX table content |
| `create_latex_template()` | Build document preamble |
| `compile_latex()` | Run pdflatex |
| `crop_pdf()` | Run pdfcrop |
| `auto_align()` | Detect column alignment |
| `sanitize_column_names()` | Clean column names |
| `sanitize_table_cells()` | Escape special characters |
| `sanitize_filename()` | Clean filenames |
| `detect_siunitx_columns()` | Find S columns |
| `protect_siunitx_headers()` | Wrap headers in braces |
| `process_alignment()` | Process alignment specs |
| `apply_theme()` | Resolve theme settings |
| `get_builtin_theme()` | Retrieve theme by name |
| `build_inline_latex()` | Generate inline LaTeX |

## Error Handling

### Input Validation Errors

| Condition | Message |
|-----------|---------|
| Non-data.frame input | "`x` must be a data frame" |
| Empty data frame | "`x` cannot be empty" |
| Invalid theme name | "Unknown theme: {name}" |
| Invalid alignment | "align must be character vector or list" |

### System Errors

| Condition | Message |
|-----------|---------|
| Directory creation failure | "Cannot create directory: {path}" |
| LaTeX compilation failure | "LaTeX compilation failed" |
| PDF cropping failure | "pdfcrop failed with exit code: {code}" |
| Missing pdflatex | "pdflatex not found" |
| Missing broom | "Package 'broom' required for this object type" |

## Version History

### Version 0.2.0 (2024-12)

- S3 generic refactor with methods for 20+ object types
- Theme system with 5 built-in journal themes
- Custom theme registration
- Inline tables with frame/background styling
- Model comparison tables (t2f_regression)
- siunitx decimal alignment with header protection
- Batch processing API
- Caching system
- PNG/SVG output conversion
- knitr engine integration
- Default sub_dir changed to "figures"

### Version 0.1.3 (2025-02)

- LaTeX package helper functions
- Enhanced error handling
- Improved documentation

## See Also

- [User Guide](USERS_GUIDE.md)
- [Technical Specifications](TECHNICAL_SPECIFICATIONS.md)
- [Architecture Overview](ARCHITECTURE_OVERVIEW.md)
