# zztab2fig 0.2.1

## New Features

### RMS Package Integration

Full support for Frank Harrell's rms (Regression Modeling Strategies) package,
commonly used in biostatistics and clinical trials:

* `t2f.ols()` - Ordinary least squares models
* `t2f.lrm()` - Logistic regression with odds ratio support
* `t2f.cph()` - Cox proportional hazards with hazard ratio support
* `t2f.orm()` - Ordinal regression models
* `t2f.Glm()` - Generalized linear models (rms version)
* `t2f.psm()` - Parametric survival models
* `t2f_rms_compare()` - Side-by-side comparison of rms models

All rms methods support:

- `output = "coef"` for coefficient tables (default)
- `output = "anova"` for ANOVA-style chunk tests (useful for spline terms)
- `exponentiate = TRUE` for odds ratios / hazard ratios

### Documentation Improvements

* Added `t2f_tidy()` documentation for extensibility via broom
* Updated pander comparison vignette with accurate feature counts
* Clarified that pander supports 50+ object types natively

## Bug Fixes

* Fixed missing brace in `t2f.cph()` example documentation

---

# zztab2fig 0.2.0

## New Features

* Added LaTeX package helper functions for R-friendly syntax:
  - `geometry()` for page layout configuration
  - `babel()` for multilingual document support
  - `fontspec()` for font configuration
* Parameterized LaTeX templates with `create_latex_template()`
* New `document_class` and `extra_packages` parameters in `t2f()`
* Enhanced input validation for all function parameters
* Implemented `sanitize_table_cells()` for LaTeX special character escaping

## Improvements

* Expanded test coverage from 11 to 38 tests
* Enhanced documentation with comprehensive examples
* Better error messages with specific failure reasons
* Improved file handling and cross-platform compatibility

## Bug Fixes

* Fixed `crop_pdf()` function to create separate cropped versions
* Fixed verbose parameter handling in `log_message()`
* Added proper error handling for pdflatex and pdfcrop failures

# zztab2fig 0.1.0

## Initial Release

* Core `t2f()` function for dataframe to LaTeX/PDF conversion
* Support for multiple output formats (PDF, PNG, SVG)
* Journal styling themes (APA, Nature, NEJM)
* S3 methods for lm/glm objects via broom integration
* R Markdown integration with custom knitr engine
* Cropped PDF output support
