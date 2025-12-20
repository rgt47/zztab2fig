# API Reference: zztab2fig Package

## Overview

This document provides comprehensive API documentation for the `zztab2fig` package, including function signatures, parameter specifications, return values, and usage examples. The package follows standard R documentation conventions and provides both high-level interface functions and lower-level utility functions.

## Package Information

- **Version**: 0.1.3
- **Namespace**: zztab2fig
- **Dependencies**: kableExtra, glue
- **System Requirements**: LaTeX (pdflatex, pdfcrop)

## Exported Functions

### Primary Interface

#### `t2f()`

Convert a data frame to a LaTeX table and generate a cropped PDF.

**Signature:**
```r
t2f(df, filename = NULL, sub_dir = "output", scolor = "blue!10",
    verbose = FALSE, extra_packages = NULL, document_class = "article")
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `df` | data.frame | Required | Data frame to be converted to LaTeX table |
| `filename` | character | NULL | Base name for output files (without extensions). If NULL, uses variable name |
| `sub_dir` | character | "output" | Subdirectory for storing output files |
| `scolor` | character | "blue!10" | LaTeX color specification for alternating row shading |
| `verbose` | logical | FALSE | Enable progress message output |
| `extra_packages` | list | NULL | List of LaTeX package specifications or helper function results |
| `document_class` | character | "article" | LaTeX document class for template generation |

**Return Value:**
- **Type**: character (invisibly returned)
- **Value**: File path to the generated cropped PDF

**Validation:**
- `df` must be a non-empty data frame
- `filename` must be a valid character string or NULL
- `sub_dir` must be a non-empty character string with write permissions
- `scolor` must be a single character string in LaTeX color format
- `verbose` must be a single logical value
- `document_class` must be a valid LaTeX document class name

**Side Effects:**
- Creates output directory if it does not exist
- Generates three files: .tex, .pdf, and _cropped.pdf
- May generate auxiliary files (.log, .aux) during LaTeX compilation

**Examples:**
```r
# Basic usage
result <- t2f(mtcars, filename = "cars_table")

# With custom styling
t2f(iris[1:10, ],
    filename = "iris_sample",
    scolor = "green!15",
    verbose = TRUE)

# Advanced configuration
t2f(economics_data,
    filename = "econ_analysis",
    sub_dir = "reports",
    extra_packages = list(
      geometry(margin = "5mm", landscape = TRUE),
      babel("english")
    ),
    document_class = "article")
```

**Error Conditions:**
- Throws error if `df` is not a data frame or is empty
- Throws error if output directory cannot be created or is not writable
- Throws error if LaTeX compilation fails
- Throws error if PDF cropping fails

---

### LaTeX Package Helper Functions

#### `geometry()`

Create geometry package specification for page layout configuration.

**Signature:**
```r
geometry(margin = NULL, paper = NULL, landscape = FALSE, ...)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `margin` | character | NULL | Page margin specification (e.g., "5mm", "0.75in") |
| `paper` | character | NULL | Paper size (e.g., "a4paper", "letterpaper") |
| `landscape` | logical | FALSE | Enable landscape orientation |
| `...` | any | - | Additional geometry package options |

**Return Value:**
- **Type**: character
- **Format**: LaTeX package specification string

**Examples:**
```r
geometry()
# Returns: "\\usepackage{geometry}"

geometry(margin = "5mm")
# Returns: "\\usepackage[margin=5mm]{geometry}"

geometry(margin = "10mm", paper = "a4paper", landscape = TRUE)
# Returns: "\\usepackage[margin=10mm,paper=a4paper,landscape]{geometry}"

geometry(top = "2cm", bottom = "2cm", left = "1cm", right = "1cm")
# Returns: "\\usepackage[top=2cm,bottom=2cm,left=1cm,right=1cm]{geometry}"
```

---

#### `babel()`

Create babel package specification for language support.

**Signature:**
```r
babel(language)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `language` | character | Required | Language code (e.g., "spanish", "french", "german") |

**Return Value:**
- **Type**: character
- **Format**: LaTeX babel package specification

**Validation:**
- `language` must be a single character string

**Examples:**
```r
babel("spanish")
# Returns: "\\usepackage[spanish]{babel}"

babel("french")
# Returns: "\\usepackage[french]{babel}"
```

**Error Conditions:**
- Throws error if `language` is not a single character string

---

#### `fontspec()`

Create fontspec package specification for custom font configuration.

**Signature:**
```r
fontspec(main_font = NULL, sans_font = NULL, mono_font = NULL)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `main_font` | character | NULL | Main (serif) font family name |
| `sans_font` | character | NULL | Sans-serif font family name |
| `mono_font` | character | NULL | Monospace font family name |

**Return Value:**
- **Type**: character vector
- **Format**: LaTeX fontspec package specifications

**Note:** Requires XeLaTeX or LuaLaTeX for compilation.

**Examples:**
```r
fontspec()
# Returns: "\\usepackage{fontspec}"

fontspec(main_font = "Times New Roman")
# Returns: c("\\usepackage{fontspec}", "\\setmainfont{Times New Roman}")

fontspec(main_font = "Times New Roman", sans_font = "Arial", mono_font = "Courier New")
# Returns: c("\\usepackage{fontspec}",
#           "\\setmainfont{Times New Roman}",
#           "\\setsansfont{Arial}",
#           "\\setmonofont{Courier New}")
```

---

## Internal Functions

### Data Sanitization

#### `sanitize_column_names()`

Sanitize column names for LaTeX compatibility.

**Signature:**
```r
sanitize_column_names(colnames)
```

**Parameters:**
- `colnames`: Character vector of column names

**Processing:**
1. Applies `make.names()` for R compatibility
2. Replaces non-alphanumeric characters with underscores
3. Preserves alphanumeric characters and underscores

**Return Value:**
- **Type**: character vector
- **Length**: Same as input

**Examples:**
```r
sanitize_column_names(c("col #1", "col%2", "col&3"))
# Returns: c("col__1", "col_2", "col_3")

sanitize_column_names(c("Sales $", "R&D Cost", "Profit %"))
# Returns: c("Sales__", "R_D_Cost", "Profit__")
```

---

#### `sanitize_table_cells()`

Escape LaTeX special characters in table cell content.

**Signature:**
```r
sanitize_table_cells(cells)
```

**Parameters:**
- `cells`: Character vector of table cell values

**Processing:**
Escapes the following LaTeX special characters:
- `#` → `\#`
- `%` → `\%`
- `&` → `\&`
- `$` → `\$`

**Return Value:**
- **Type**: character vector
- **Length**: Same as input

**Examples:**
```r
sanitize_table_cells(c("100%", "Cost $50", "R&D", "Item #1"))
# Returns: c("100\\%", "Cost \\$50", "R\\&D", "Item \\#1")
```

---

#### `sanitize_filename()`

Generate file system compatible filenames.

**Signature:**
```r
sanitize_filename(filename)
```

**Parameters:**
- `filename`: Character string representing desired filename

**Processing:**
Replaces non-alphanumeric characters with underscores, preserving only:
- Letters (a-z, A-Z)
- Numbers (0-9)
- Underscores (_)

**Return Value:**
- **Type**: character
- **Length**: 1

**Examples:**
```r
sanitize_filename("my-table.final")
# Returns: "my_table_final"

sanitize_filename("analysis #1 (revised)")
# Returns: "analysis__1__revised_"
```

---

### LaTeX Processing

#### `create_latex_table()`

Generate LaTeX table with specified styling options.

**Signature:**
```r
create_latex_table(df, tex_file, scolor, extra_packages = NULL, document_class = "article")
```

**Parameters:**
- `df`: Data frame containing table data
- `tex_file`: Output path for LaTeX file
- `scolor`: LaTeX color specification for row shading
- `extra_packages`: List of additional LaTeX packages
- `document_class`: LaTeX document class

**Processing:**
1. Applies cell sanitization to character columns
2. Generates kableExtra table with booktabs styling
3. Applies row specifications and stripe coloring
4. Embeds table in LaTeX document template

**Side Effects:**
- Writes complete LaTeX document to specified file path

---

#### `compile_latex()`

Compile LaTeX source file to PDF with error handling.

**Signature:**
```r
compile_latex(tex_file, sub_dir)
```

**Parameters:**
- `tex_file`: Path to LaTeX source file
- `sub_dir`: Directory containing LaTeX file

**Processing:**
1. Changes working directory to LaTeX file location
2. Executes `pdflatex` with batch mode interaction
3. Parses compilation log for error detection
4. Restores original working directory

**Error Handling:**
- Captures LaTeX compilation errors from log file
- Provides detailed error messages for debugging
- Ensures working directory restoration via `on.exit()`

---

#### `crop_pdf()`

Generate cropped PDF with minimal margins.

**Signature:**
```r
crop_pdf(input_pdf, output_pdf)
```

**Parameters:**
- `input_pdf`: Path to input PDF file
- `output_pdf`: Path for cropped output PDF

**Processing:**
1. Executes `pdfcrop` with 10-point margins
2. Validates successful file creation
3. Reports detailed error messages on failure

---

### Utility Functions

#### `log_message()`

Conditional message output for progress tracking.

**Signature:**
```r
log_message(msg, verbose = FALSE)
```

**Parameters:**
- `msg`: Character string message to display
- `verbose`: Logical flag controlling output

**Behavior:**
- Outputs message using `message()` when `verbose = TRUE`
- Silent operation when `verbose = FALSE`

---

#### `create_latex_template()`

Generate LaTeX document template with specified packages.

**Signature:**
```r
create_latex_template(document_class = "article", extra_packages = NULL)
```

**Parameters:**
- `document_class`: LaTeX document class specification
- `extra_packages`: List of package specifications

**Processing:**
1. Combines base required packages with user-specified packages
2. Handles both character strings and function-generated specifications
3. Constructs complete document preamble

**Return Value:**
- **Type**: character
- **Content**: Complete LaTeX document preamble

---

## Error Handling Specifications

### Input Validation Errors

| Condition | Error Message | Function |
|-----------|---------------|----------|
| Non-data.frame input | "`df` must be a dataframe." | `t2f()` |
| Empty data frame | "`df` must not be empty." | `t2f()` |
| Invalid color specification | "`scolor` must be a single character string." | `t2f()` |
| Invalid verbose parameter | "`verbose` must be a single logical value." | `t2f()` |
| NULL directory name | "Directory name cannot be NULL" | `t2f()` |
| Empty directory name | "Directory name cannot be empty" | `t2f()` |
| Invalid language parameter | "`language` must be a single character string" | `babel()` |

### System Errors

| Condition | Error Message Pattern | Function |
|-----------|----------------------|----------|
| Directory creation failure | "Cannot create directory: {path}\nError: {details}" | `t2f()` |
| Write permission failure | "Directory is not writable: {path}" | `t2f()` |
| LaTeX compilation failure | "LaTeX compilation failed. Errors found:\n{log_details}" | `compile_latex()` |
| PDF cropping failure | "PDF cropping failed with exit code: {code}" | `crop_pdf()` |
| Missing output file | "PDF cropping failed: output file was not created" | `crop_pdf()` |

### Dependency Errors

| Condition | Error Message | Function |
|-----------|---------------|----------|
| Missing kableExtra | "The 'kableExtra' package is required but not installed." | `create_latex_table()` |

## Usage Patterns

### Basic Workflow
```r
# 1. Prepare data
data <- clean_and_format_data(raw_data)

# 2. Generate table
result <- t2f(data, "analysis_table", verbose = TRUE)

# 3. Use output
include_graphics(result)  # In R Markdown
```

### Advanced Configuration
```r
# Professional academic formatting
academic_config <- list(
  scolor = "gray!8",
  extra_packages = list(
    geometry(margin = "20mm", paper = "letterpaper"),
    babel("english"),
    "\\usepackage{microtype}"
  ),
  document_class = "article"
)

result <- do.call(t2f, c(list(df = research_data, filename = "results"), academic_config))
```

### Batch Processing
```r
# Process multiple datasets consistently
process_table_batch <- function(data_list, config) {
  results <- list()
  for (name in names(data_list)) {
    results[[name]] <- do.call(t2f, c(
      list(df = data_list[[name]], filename = name),
      config
    ))
  }
  return(results)
}
```

## Version History

### Version 0.1.3 (2025-02-01)
- Added LaTeX package helper functions
- Enhanced error handling and validation
- Improved test coverage
- Updated documentation

### Future API Considerations
- Potential addition of `longtable` support for multi-page tables
- Consideration of additional document classes
- Possible integration with additional LaTeX packages

## See Also

- [Technical Specifications](TECHNICAL_SPECIFICATIONS.md)
- [Comprehensive README](README_COMPREHENSIVE.md)
- Package vignette: `vignette("zztab2fig")`
- kableExtra documentation: `help(package = "kableExtra")`