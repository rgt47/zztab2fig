# Architecture Overview: zztab2fig Package

## Abstract

This document presents a comprehensive architectural analysis of the
`zztab2fig` R package (v0.2.0), examining its design patterns, component
interactions, data flow, and system integration points. The architecture
implements S3 generic dispatch with a pipeline-based processing model,
theme system, caching layer, and multiple output format support.

## System Architecture

### Architectural Pattern

The `zztab2fig` package implements a **Pipeline Architecture** with
**S3 Dispatch** and **Layered Components**:

- S3 generic dispatch for type-specific table generation
- Sequential processing stages with clear transformation points
- Theme system for consistent styling across tables
- Caching layer for performance optimization
- Modular components for independent testing and maintenance

### Component Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Interface Layer                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│  │ t2f()       │  │ t2f_inline()│  │ t2f_batch() │  │t2f_reg- │ │
│  │ S3 Generic  │  │ R Markdown  │  │ Batch Proc  │  │ression()│ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    S3 Dispatch Layer                             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ t2f.lm │ t2f.glm │ t2f.coxph │ t2f.data.frame │ ...     │   │
│  └──────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│                    Theme System Layer                            │
│  ┌───────────────┐  ┌──────────────┐  ┌───────────────────────┐ │
│  │ Theme Objects │  │ Theme        │  │ Theme                 │ │
│  │ (t2f_theme)   │  │ Registry     │  │ Resolution            │ │
│  └───────────────┘  └──────────────┘  └───────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    Processing Layer                              │
│  ┌───────────────┐  ┌──────────────┐  ┌───────────────────────┐ │
│  │ Validation    │  │ Sanitization │  │ LaTeX Generation      │ │
│  │ Components    │  │ Components   │  │ Components            │ │
│  └───────────────┘  └──────────────┘  └───────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    System Integration Layer                      │
│  ┌───────────────┐  ┌──────────────┐  ┌───────────────────────┐ │
│  │ File System   │  │ LaTeX Engine │  │ Output Format         │ │
│  │ Management    │  │ Interface    │  │ Converters            │ │
│  └───────────────┘  └──────────────┘  └───────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    Caching Layer                                 │
│  ┌───────────────┐  ┌──────────────┐  ┌───────────────────────┐ │
│  │ Hash          │  │ Cache        │  │ Cache                 │ │
│  │ Computation   │  │ Storage      │  │ Retrieval             │ │
│  └───────────────┘  └──────────────┘  └───────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    External Dependencies                         │
│  ┌───────────────┐  ┌──────────────┐  ┌───────────────────────┐ │
│  │ R Environment │  │ kableExtra   │  │ LaTeX Distribution    │ │
│  │ broom/stats   │  │ Package      │  │ (pdflatex/pdfcrop)    │ │
│  └───────────────┘  └──────────────┘  └───────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## S3 Dispatch Architecture

### Generic Function Design

The `t2f()` function implements S3 method dispatch:

```r
t2f <- function(x, ...) UseMethod("t2f")
```

### Method Resolution

```
Input Object
    │
    ▼
┌─────────────────────────────────────┐
│ Class Detection                      │
│ class(x) = c("lm", "lmList", ...)   │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│ Method Lookup                        │
│ 1. t2f.lm() - Exact match           │
│ 2. t2f.lmList() - Parent class      │
│ 3. t2f.default() - Fallback         │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│ Method Execution                     │
│ - Object-specific extraction        │
│ - Common pipeline invocation        │
└─────────────────────────────────────┘
```

### Method Categories

```
S3 Methods:
├── Base R Types
│   ├── t2f.data.frame()  → Direct table conversion
│   ├── t2f.matrix()      → Convert to data.frame first
│   └── t2f.table()       → Contingency table formatting
│
├── Statistical Models
│   ├── t2f.lm()          → Coefficient extraction via broom
│   ├── t2f.glm()         → With exponentiate option
│   ├── t2f.anova()       → ANOVA table formatting
│   ├── t2f.aov()         → AOV summary
│   └── t2f.htest()       → Hypothesis test results
│
├── Survival Models
│   ├── t2f.coxph()       → Hazard ratios
│   ├── t2f.survreg()     → Parametric survival
│   ├── t2f.survfit()     → Survival curves summary
│   └── t2f.survdiff()    → Log-rank test
│
├── Mixed Effects Models
│   ├── t2f.lmerMod()     → lme4 linear mixed
│   ├── t2f.glmerMod()    → lme4 generalized mixed
│   └── t2f.lme()         → nlme mixed effects
│
└── Other Models
    ├── t2f.nls()         → Nonlinear least squares
    ├── t2f.Arima()       → Time series
    ├── t2f.polr()        → Ordinal regression
    ├── t2f.multinom()    → Multinomial regression
    ├── t2f.prcomp()      → PCA results
    └── t2f.kmeans()      → Clustering results
```

## Data Flow Architecture

### Primary Processing Pipeline

```
Input Object
    │
    ▼
[1] S3 Dispatch
    │
    ▼
[2] Object Tidying (broom/custom)
    │
    ▼
[3] Theme Resolution
    │
    ▼
[4] Cache Check
    │    │
    │    └── Cache Hit → Return cached result
    │
    ▼
[5] Data Sanitization
    │
    ▼
[6] LaTeX Generation
    │
    ▼
[7] PDF Compilation
    │
    ▼
[8] PDF Cropping
    │
    ▼
[9] Format Conversion (optional)
    │
    ▼
[10] Cache Storage
    │
    ▼
Output: {.tex, .pdf, _cropped.pdf, .png, .svg}
```

### Stage Details

#### Stage 1: S3 Dispatch

```
User Input → Class Detection → Method Selection → Parameter Merging
    ↓             ↓                  ↓                  ↓
Object x   → class(x)        → t2f.{class}()   → ... arguments
```

#### Stage 2: Object Tidying

```
Model Object → Tidying Function → Formatted Data Frame
    ↓                ↓                    ↓
lm(y ~ x)    → broom::tidy()     → term|estimate|std.error|...
    ↓                ↓                    ↓
coxph(...)   → broom::tidy()     → term|estimate|conf.low|conf.high|...
```

#### Stage 3: Theme Resolution

```
┌─────────────────────────────────────────────┐
│ Priority Order:                              │
│ 1. Explicit theme= parameter                 │
│ 2. Global theme (t2f_theme_get())           │
│ 3. Built-in defaults                         │
└─────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────┐
│ Parameter Extraction:                        │
│ - scolor from theme                          │
│ - extra_packages from theme                  │
│ - font_size, booktabs, striped               │
└─────────────────────────────────────────────┘
```

#### Stage 4: Cache Check

```
Input + Parameters → Hash Computation → Cache Lookup → Hit/Miss
        ↓                   ↓               ↓            ↓
digest(list(x,     → SHA256 hash     → cache_dir    → Return/
       theme,                                           Continue
       ...))
```

## Theme System Architecture

### Theme Object Structure

```r
t2f_theme <- list(
  name = "theme_name",           # Identifier
  scolor = "blue!10",            # Row shading color
  header_bold = TRUE,            # Bold headers
  font_size = "small",           # LaTeX font size
  booktabs = TRUE,               # Use booktabs rules
  striped = TRUE,                # Alternating colors
  extra_packages = list(...)     # Additional LaTeX
)
```

### Theme Registry

```
Package Environment (.t2f_env):
├── current_theme     → Currently active global theme
├── theme_registry    → Named list of registered themes
│   ├── "minimal"     → t2f_theme_minimal()
│   ├── "apa"         → t2f_theme_apa()
│   ├── "nature"      → t2f_theme_nature()
│   ├── "nejm"        → t2f_theme_nejm()
│   ├── "lancet"      → t2f_theme_lancet()
│   └── {user themes} → Custom registered themes
└── cache_dir         → Cache directory location
```

### Theme Application Flow

```
t2f() Call
    │
    ▼
┌─────────────────────────────────────┐
│ Resolve Theme                        │
│ theme = theme %||% t2f_theme_get()  │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│ Extract Parameters                   │
│ if (is.character(theme))            │
│   theme = get_theme(theme)          │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│ Merge with Explicit Parameters       │
│ scolor = scolor %||% theme$scolor   │
│ extra = c(extra, theme$extra)       │
└─────────────────────────────────────┘
```

## Caching Architecture

### Cache Key Computation

```r
compute_cache_key <- function(x, params) {
  digest::digest(
    list(
      data = x,
      theme = params$theme,
      scolor = params$scolor,
      align = params$align,
      caption = params$caption,
      ...
    ),
    algo = "sha256"
  )
}
```

### Cache Storage Structure

```
~/.zztab2fig_cache/
├── a1b2c3d4.pdf           # Full PDF
├── a1b2c3d4_cropped.pdf   # Cropped PDF
├── a1b2c3d4.meta          # Metadata (JSON)
├── e5f6g7h8.pdf
├── e5f6g7h8_cropped.pdf
└── e5f6g7h8.meta
```

### Cache Flow

```
                    ┌─────────────────┐
Input + Params ────→│ Compute Hash    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Cache Lookup    │
                    └────────┬────────┘
                             │
            ┌────────────────┴────────────────┐
            │                                 │
            ▼                                 ▼
    ┌───────────────┐                ┌───────────────┐
    │ Cache Hit     │                │ Cache Miss    │
    └───────┬───────┘                └───────┬───────┘
            │                                │
            ▼                                ▼
    ┌───────────────┐                ┌───────────────┐
    │ Return Cached │                │ Generate New  │
    │ PDF Path      │                │ → Store Cache │
    └───────────────┘                └───────────────┘
```

## Component Design

### Core Components

#### 1. S3 Generic Interface

**Pattern:** Template Method + Strategy

```r
t2f.lm <- function(x, include, conf.int, stars, ...) {
  # Strategy: Model-specific extraction
  tidy_data <- t2f_tidy(x, conf.int = conf.int, ...)

  # Template: Common formatting
  if (stars) {
    tidy_data <- add_significance_stars(tidy_data)
  }

  # Delegation: Common processing
  t2f.data.frame(tidy_data, ...)
}
```

#### 2. Theme System Component

**Pattern:** Registry + Factory

```r
# Registry
.t2f_env$theme_registry <- list()

# Factory
t2f_theme <- function(name, scolor, ...) {
  structure(
    list(name = name, scolor = scolor, ...),
    class = "t2f_theme"
  )
}

# Registration
t2f_theme_register <- function(theme) {
  .t2f_env$theme_registry[[theme$name]] <- theme
}
```

#### 3. Inline Table Component

**Pattern:** Adapter

```r
t2f_inline <- function(x, width, caption, frame, ...) {
  # Generate table via standard pipeline
  pdf_path <- t2f(x, ...)

  # Adapt for R Markdown context
  if (knitr_in_progress()) {
    latex_code <- build_inline_latex(pdf_path, width, caption, frame)
    knitr::asis_output(latex_code)
  } else {
    pdf_path
  }
}
```

#### 4. Batch Processing Component

**Pattern:** Iterator + Decorator

```r
t2f_batch <- function(data_list, theme, sub_dir, ...) {
  # Iterator over named list
  paths <- lapply(names(data_list), function(name) {
    # Decorator: Apply common settings
    t2f(
      data_list[[name]],
      filename = name,
      theme = theme,
      sub_dir = sub_dir,
      ...
    )
  })
  names(paths) <- names(data_list)
  paths
}
```

### Formatting System

```
Formatting Pipeline:
├── t2f_siunitx()       → Decimal alignment specification
├── t2f_decimal()       → Convenience wrapper
├── t2f_footnote()      → Table footnotes
├── t2f_header_above()  → Spanning column headers
├── t2f_collapse_rows() → Row grouping
├── t2f_bold_col()      → Column bold formatting
├── t2f_italic_col()    → Column italic formatting
└── t2f_highlight()     → Conditional cell highlighting
```

## Error Handling Architecture

### Error Classification

```
Error Hierarchy:
├── Input Validation Errors
│   ├── Invalid object class
│   ├── Missing required parameters
│   └── Invalid parameter values
│
├── Theme Errors
│   ├── Unknown theme name
│   ├── Invalid theme structure
│   └── Theme registration conflicts
│
├── Processing Errors
│   ├── Model tidying failures
│   ├── Data sanitization issues
│   └── Formatting conflicts
│
├── System Errors
│   ├── LaTeX compilation failures
│   ├── PDF cropping errors
│   ├── Format conversion failures
│   └── File system errors
│
└── Cache Errors
    ├── Cache corruption
    ├── Storage failures
    └── Hash computation errors
```

### Error Handling Strategy

```r
# Tier 1: Immediate validation
if (!inherits(x, supported_classes)) {
  stop("Unsupported object class", call. = FALSE)
}

# Tier 2: Graceful degradation
tryCatch(
  broom::tidy(x),
  error = function(e) {
    warning("broom::tidy failed, using fallback")
    fallback_tidy(x)
  }
)

# Tier 3: Resource cleanup
on.exit(setwd(old_wd), add = TRUE)
```

## Integration Architecture

### R Markdown Integration

```
R Markdown Document
        │
        ▼
┌─────────────────────────────────────┐
│ Code Chunk                           │
│ ```{r, results='asis'}              │
│ t2f_inline(model, width = "3in")    │
│ ```                                  │
└─────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ knitr Processing                     │
│ - Detect latex output               │
│ - Generate PDF                       │
│ - Build \includegraphics            │
└─────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ LaTeX Document                       │
│ \begin{center}                      │
│ \captionof{table}{...}              │
│ \includegraphics[width=3in]{...}    │
│ \end{center}                        │
└─────────────────────────────────────┘
```

### knitr Engine Integration

```r
# Engine registration in .onLoad()
knitr::knit_engines$set(t2f = t2f_engine)

# Engine function
t2f_engine <- function(options) {
  code <- paste(options$code, collapse = "\n")
  result <- eval(parse(text = code))
  t2f_inline(
    result,
    width = options$t2f.width,
    caption = options$t2f.caption,
    theme = options$t2f.theme
  )
}
```

### Batch Processing Integration

```
Data Sources                      Output
    │                                │
    ├── data_list$table1 ──────────► tables/table1_cropped.pdf
    ├── data_list$table2 ──────────► tables/table2_cropped.pdf
    └── data_list$table3 ──────────► tables/table3_cropped.pdf
                                     │
                                     └── All with consistent theme
```

## Performance Architecture

### Complexity Analysis

| Operation | Time | Space |
|-----------|------|-------|
| S3 dispatch | O(1) | O(1) |
| Model tidying | O(n) | O(n) |
| Theme resolution | O(1) | O(1) |
| Cache lookup | O(1) | O(1) |
| Data sanitization | O(n*m) | O(n*m) |
| LaTeX generation | O(n*m) | O(n*m) |
| PDF compilation | O(n*m) | O(1) |
| PDF cropping | O(1) | O(1) |

### Optimization Strategies

#### Caching

```r
# Skip expensive operations on cache hit
if (cache_enabled && cache_exists(hash)) {
  return(get_cached_path(hash))
}
```

#### Batch Amortization

```r
# Amortize LaTeX startup cost across multiple tables
t2f_batch(data_list, ...)  # Single LaTeX format setup
```

#### Lazy Theme Loading

```r
# Themes loaded only when needed
get_theme <- function(name) {
  if (!exists(name, envir = .t2f_env$theme_registry)) {
    load_builtin_theme(name)
  }
  .t2f_env$theme_registry[[name]]
}
```

## Security Architecture

### Input Validation

```
Validation Layers:
├── Class validation     → Supported S3 classes only
├── Parameter validation → Type and range checking
├── Path validation      → Directory traversal prevention
├── LaTeX sanitization   → Special character escaping
└── Command validation   → Shell injection prevention
```

### Trust Boundaries

```
Trust Levels:
├── User Input          → Untrusted (full validation)
├── Model Objects       → Semi-trusted (class verification)
├── Theme Objects       → Trusted (internal or registered)
├── Generated LaTeX     → Trusted (internal generation)
└── System Commands     → Controlled (fixed command set)
```

## Extensibility Architecture

### S3 Extension Points

```r
# User-defined S3 method
t2f.my_custom_model <- function(x, ...) {
  # Extract data from custom model
  df <- extract_my_model_data(x)

  # Delegate to data.frame method
  t2f.data.frame(df, ...)
}
```

### Theme Extension Points

```r
# Custom theme registration
my_theme <- t2f_theme(
  name = "corporate",
  scolor = "companyblue!10",
  extra_packages = list(
    "\\usepackage{corporate-fonts}"
  )
)
t2f_theme_register(my_theme)
```

### Formatting Extension Points

```r
# Custom formatting function
t2f_custom_format <- function(...) {
  structure(
    list(...),
    class = c("t2f_custom_format", "t2f_format")
  )
}
```

## Conclusion

The `zztab2fig` v0.2.0 architecture implements a robust, extensible design
combining S3 method dispatch with a pipeline processing model. Key
architectural strengths include:

- **Polymorphic dispatch**: Support for 20+ object types via S3 generics
- **Theme system**: Consistent styling with journal-specific presets
- **Caching layer**: Performance optimization for repeated operations
- **R Markdown integration**: Seamless inline table generation
- **Batch processing**: Efficient multi-table workflows
- **Extensibility**: User-defined S3 methods, themes, and formatters

The architecture positions the package for continued evolution while
maintaining backward compatibility and operational reliability.
