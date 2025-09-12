# zztab2fig Users Guide

## Overview

The `zztab2fig` package converts R dataframes into professional LaTeX tables and generates cropped PDF files. This guide covers all parameters, options, and provides comprehensive examples for different use cases.

## Basic Syntax

```r
t2f(df, filename = NULL, sub_dir = "output", scolor = "blue!10", 
    verbose = FALSE, extra_packages = NULL, document_class = "article")
```

## Parameters Guide

### `df` (Required)
**Type:** `data.frame`  
**Description:** The dataframe to convert to a LaTeX table.

**Requirements:**
- Must be a valid dataframe
- Cannot be empty (must have at least 1 row)
- Column names will be automatically sanitized for LaTeX compatibility

**Examples:**
```r
# Basic dataframes
t2f(mtcars)
t2f(iris)

# Subset dataframes  
t2f(head(mtcars, 10))
t2f(mtcars[, c("mpg", "cyl", "hp")])

# Processed dataframes
library(dplyr)
summary_data <- mtcars %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg), .groups = "drop")
t2f(summary_data)
```

### `filename` (Optional)
**Type:** `character`  
**Default:** Uses dataframe variable name  
**Description:** Base name for output files (without extensions).

**Naming Rules:**
- Special characters are automatically replaced with underscores
- Extensions are added automatically (.tex, .pdf, _cropped.pdf)

**Examples:**
```r
# Default filename (uses dataframe name)
t2f(mtcars)  # Creates: mtcars.tex, mtcars.pdf, mtcars_cropped.pdf

# Custom filename
t2f(mtcars, filename = "car_data")  # Creates: car_data.*

# Special characters are sanitized
t2f(mtcars, filename = "my-table#1")  # Creates: my_table_1.*
```

### `sub_dir` (Optional)
**Type:** `character`  
**Default:** `"output"`  
**Description:** Directory where output files will be stored.

**Behavior:**
- Directory is created automatically if it doesn't exist
- Must be writable
- Can be nested paths

**Examples:**
```r
# Default directory
t2f(mtcars)  # Files go to: output/

# Custom directory  
t2f(mtcars, sub_dir = "tables")  # Files go to: tables/

# Nested directories
t2f(mtcars, sub_dir = "reports/chapter1/tables")

# Project organization
t2f(quarterly_data, sub_dir = "2024/Q1/tables")
```

### `scolor` (Optional)
**Type:** `character`  
**Default:** `"blue!10"`  
**Description:** LaTeX color for alternating row shading.

**Color Format:** `"color!intensity"`
- **color**: LaTeX color name (blue, red, green, gray, etc.)
- **intensity**: Number 1-100 (lower = lighter, higher = darker)

**Available Colors:**
- `blue!10` - Light blue (default)
- `red!15` - Light red
- `green!20` - Light green  
- `gray!25` - Light gray
- `purple!12` - Light purple
- `orange!18` - Light orange
- `yellow!30` - Light yellow

**Examples:**
```r
# Default blue shading
t2f(mtcars)  # Uses blue!10

# Different colors
t2f(mtcars, scolor = "green!15")     # Light green
t2f(mtcars, scolor = "red!20")       # Medium red
t2f(mtcars, scolor = "gray!8")       # Very light gray

# Corporate colors
t2f(sales_data, scolor = "blue!8")   # Subtle corporate blue
t2f(financial_data, scolor = "green!12")  # Money green

# High contrast for presentations
t2f(presentation_data, scolor = "blue!25")  # Darker blue
```

### `verbose` (Optional)
**Type:** `logical`  
**Default:** `FALSE`  
**Description:** Whether to print progress messages during table generation.

**Output Messages:**
- "Generating LaTeX table..."
- "Compiling LaTeX to PDF..."  
- "Cropping PDF..."
- "PDF generated at: [path]"

**Examples:**
```r
# Silent operation (default)
t2f(mtcars)

# Verbose output
t2f(mtcars, verbose = TRUE)

# Useful for debugging
t2f(problematic_data, verbose = TRUE)  # See where process fails
```

### `extra_packages` (Optional)
**Type:** `list`  
**Default:** `NULL`  
**Description:** Additional LaTeX packages and configuration.

**Input Types:**
- LaTeX helper functions: `geometry()`, `babel()`, `fontspec()`
- Raw LaTeX strings: `"\\usepackage{package}"`
- Mixed list of both

**Examples:**
```r
# Using helper functions
t2f(mtcars, 
    extra_packages = list(
      geometry(margin = "5mm"),
      babel("spanish")
    ))

# Raw LaTeX strings
t2f(mtcars,
    extra_packages = list(
      "\\usepackage{microtype}",
      "\\usepackage{array}"
    ))

# Mixed approach
t2f(mtcars,
    extra_packages = list(
      geometry(margin = "10mm", landscape = TRUE),
      "\\usepackage{booktabs}",
      babel("french")
    ))
```

### `document_class` (Optional)
**Type:** `character`  
**Default:** `"article"`  
**Description:** LaTeX document class to use.

**Common Options:**
- `"article"` - Standard document (default)
- `"minimal"` - Minimal overhead
- `"report"` - For longer documents
- `"book"` - Book-style formatting

**Examples:**
```r
# Default article class
t2f(mtcars)

# Minimal for simple tables
t2f(simple_data, document_class = "minimal")

# Report class for formal documents
t2f(annual_report, document_class = "report")
```

## LaTeX Helper Functions

### `geometry()` - Page Layout
Controls page margins, paper size, and orientation.

**Parameters:**
- `margin` - Page margins (e.g., "5mm", "1in")
- `paper` - Paper size ("a4paper", "letterpaper", "a3paper")
- `landscape` - Logical, if TRUE sets landscape orientation
- `...` - Additional geometry options

**Examples:**
```r
# Minimal margins for wide tables
geometry(margin = "3mm")

# A4 paper with specific margins
geometry(margin = "15mm", paper = "a4paper")

# Landscape orientation
geometry(margin = "5mm", landscape = TRUE)

# Letter paper for US users
geometry(margin = "1in", paper = "letterpaper")

# Conference poster (large format)
geometry(paper = "a3paper", margin = "10mm", landscape = TRUE)
```

### `babel()` - Language Support
Adds language-specific formatting and hyphenation.

**Parameters:**
- `language` - Language code string

**Supported Languages:**
- `"spanish"`, `"french"`, `"german"`, `"italian"`, `"portuguese"`
- `"russian"`, `"chinese"`, `"japanese"`, `"arabic"`
- Many others supported by LaTeX babel package

**Examples:**
```r
# Spanish language support
babel("spanish")

# French language support  
babel("french")

# German language support
babel("german")
```

### `fontspec()` - Font Configuration
Configures custom fonts (requires XeLaTeX or LuaLaTeX).

**Parameters:**
- `main_font` - Main document font
- `sans_font` - Sans-serif font
- `mono_font` - Monospace font

**Examples:**
```r
# Times New Roman as main font
fontspec(main_font = "Times New Roman")

# Complete font configuration
fontspec(
  main_font = "Times New Roman",
  sans_font = "Arial", 
  mono_font = "Courier New"
)

# System fonts (macOS)
fontspec(main_font = "Helvetica Neue")
```

## Complete Examples

### Example 1: Basic Academic Paper Table
```r
library(zztab2fig)
library(dplyr)

# Prepare academic-style data
results <- data.frame(
  Model = c("Linear", "Quadratic", "Cubic"),
  R_squared = c(0.85, 0.92, 0.94),
  AIC = c(145.2, 138.7, 141.3),
  p_value = c("< 0.001", "< 0.001", "0.002")
)

# Generate academic table
t2f(results,
    filename = "model_comparison",
    sub_dir = "paper/tables",
    scolor = "gray!8",
    extra_packages = list(
      geometry(margin = "20mm", paper = "letterpaper")
    ))
```

### Example 2: Business Report Table
```r
# Quarterly sales data
sales_summary <- data.frame(
  Quarter = c("Q1 2024", "Q2 2024", "Q3 2024", "Q4 2024"),
  Revenue = c("$125K", "$143K", "$158K", "$171K"),
  Growth = c("—", "+14.4%", "+10.5%", "+8.2%"),
  Target_Met = c("Yes", "Yes", "Yes", "Yes")
)

# Corporate-styled table
t2f(sales_summary,
    filename = "quarterly_sales_2024",
    sub_dir = "reports/2024",
    scolor = "blue!10",
    verbose = TRUE,
    extra_packages = list(
      geometry(margin = "12mm", paper = "a4paper")
    ))
```

### Example 3: Multilingual Scientific Table
```r
# Data in Spanish
experimento <- data.frame(
  "Tratamiento" = c("Control", "Fertilizante A", "Fertilizante B"),
  "Rendimiento" = c(4.2, 5.8, 6.1),
  "Significancia" = c("—", "p < 0.05", "p < 0.01")
)

# Spanish language table
t2f(experimento,
    filename = "resultados_experimento",
    sub_dir = "publicacion/tablas",
    scolor = "green!12",
    extra_packages = list(
      babel("spanish"),
      geometry(margin = "15mm", paper = "a4paper")
    ))
```

### Example 4: Conference Presentation Table
```r
# Key findings for presentation
key_results <- head(mtcars[, c("mpg", "cyl", "hp", "wt")], 8)

# Large, readable presentation table
t2f(key_results,
    filename = "presentation_results",
    sub_dir = "conference2024",
    scolor = "blue!20",
    document_class = "minimal",
    extra_packages = list(
      geometry(
        margin = "8mm",
        paper = "a4paper", 
        landscape = TRUE
      )
    ))
```

### Example 5: Wide Table with Custom Formatting
```r
# Wide dataset
wide_data <- mtcars[1:10, ]

# Landscape table with minimal margins
t2f(wide_data,
    filename = "complete_car_data",
    sub_dir = "analysis/wide_tables",
    scolor = "gray!15",
    verbose = TRUE,
    extra_packages = list(
      geometry(margin = "3mm", landscape = TRUE),
      "\\usepackage{microtype}",  # Better typography
      "\\usepackage{array}"       # Enhanced table formatting
    ))
```

### Example 6: Professional Report with Custom Fonts
```r
# Executive summary data
exec_summary <- data.frame(
  Metric = c("Revenue", "Profit", "Growth", "Market Share"),
  "Current Year" = c("$2.1M", "$340K", "12.5%", "8.3%"),
  "Previous Year" = c("$1.8M", "$290K", "8.2%", "7.1%"),
  Change = c("+16.7%", "+17.2%", "+4.3pp", "+1.2pp")
)

# Professional table with custom fonts
t2f(exec_summary,
    filename = "executive_summary",
    sub_dir = "board_meeting/2024",
    scolor = "blue!8",
    document_class = "article",
    extra_packages = list(
      geometry(margin = "15mm", paper = "letterpaper"),
      fontspec(main_font = "Times New Roman"),
      "\\usepackage{microtype}"
    ))
```

## Workflow Examples

### Academic Workflow
```r
# 1. Prepare analysis data
analysis_results <- my_analysis_function(raw_data)

# 2. Generate table for paper  
t2f(analysis_results,
    filename = "main_results",
    sub_dir = "manuscript/tables",
    scolor = "gray!8",
    extra_packages = list(
      geometry(margin = "20mm", paper = "letterpaper")
    ))

# 3. Include in LaTeX document:
# \input{tables/main_results.tex}
```

### Business Reporting Workflow
```r
# 1. Monthly batch processing
months <- c("January", "February", "March")
for (month in months) {
  monthly_data <- get_monthly_data(month)
  
  t2f(monthly_data,
      filename = paste0(month, "_report"),
      sub_dir = paste0("reports/2024/", tolower(month)),
      scolor = "blue!10",
      verbose = TRUE)
}

# 2. Quarterly summary
quarterly_summary <- combine_monthly_data()
t2f(quarterly_summary, 
    filename = "Q1_summary",
    sub_dir = "reports/2024/quarterly")
```

### Presentation Workflow
```r
# 1. Create presentation-ready tables
presentation_tables <- list(
  intro = intro_data,
  methods = methods_summary,  
  results = key_results,
  conclusions = conclusion_points
)

# 2. Generate all tables with consistent formatting
lapply(names(presentation_tables), function(name) {
  t2f(presentation_tables[[name]],
      filename = paste0("slide_", name),
      sub_dir = "presentation/tables",
      scolor = "blue!15",
      extra_packages = list(
        geometry(margin = "5mm", landscape = TRUE)
      ))
})
```

## Troubleshooting

### Common Issues and Solutions

**Issue: "pdflatex not found"**
```r
# Solution: Install LaTeX
# macOS: Install MacTeX
# Windows: Install MiKTeX  
# Linux: sudo apt-get install texlive
```

**Issue: "Directory not writable"**
```r
# Solution: Check permissions or use different directory
t2f(data, sub_dir = "~/Documents/tables")  # Use home directory
```

**Issue: LaTeX compilation fails**
```r
# Solution: Use verbose mode to see errors
t2f(data, verbose = TRUE)
# Check generated .log file for specific LaTeX errors
```

**Issue: Special characters in data**
```r
# Solution: Characters are auto-sanitized, but check for unusual symbols
# Manually clean if needed:
clean_data <- data
clean_data$problematic_column <- gsub("[^[:alnum:][:space:]%$#&]", "", 
                                     clean_data$problematic_column)
t2f(clean_data)
```

**Issue: Table too wide for page**
```r
# Solution: Use landscape orientation
t2f(wide_data, 
    extra_packages = list(
      geometry(margin = "3mm", landscape = TRUE)
    ))
```

## Best Practices

### 1. Data Preparation
```r
# Clean and format data before table generation
clean_data <- raw_data %>%
  mutate(across(where(is.numeric), ~ round(.x, 2))) %>%
  mutate(across(everything(), ~ ifelse(is.na(.x), "—", as.character(.x))))
```

### 2. Consistent Styling
```r
# Define style presets
corporate_style <- list(
  scolor = "blue!8",
  extra_packages = list(geometry(margin = "15mm", paper = "a4paper"))
)

# Apply consistently
t2f(data1, filename = "table1", !!!corporate_style)
t2f(data2, filename = "table2", !!!corporate_style)
```

### 3. File Organization
```r
# Organize by project and date
project_dir <- "quarterly_analysis_2024"
t2f(data, 
    filename = "results",
    sub_dir = file.path(project_dir, "tables"))
```

### 4. Version Control
```r
# Include date/version in filename for important tables
today <- format(Sys.Date(), "%Y%m%d")
t2f(final_results, 
    filename = paste0("final_results_", today))
```

This guide covers all aspects of using the `zztab2fig` package effectively. For more examples and advanced usage, see the package vignette: `vignette("zztab2fig")`.