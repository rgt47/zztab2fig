# Documentation Index: zztab2fig Package

## Document Collection Overview

This repository contains comprehensive documentation for the `zztab2fig` R
package (v0.2.0), covering technical specifications, architectural design,
API reference, and user guidance. All documents follow academic standards
with scholarly tone and precise technical language.

## Package Overview

The `zztab2fig` package provides:

- S3 generic dispatch for 20+ object types (lm, glm, coxph, etc.)
- Five built-in journal themes (minimal, apa, nature, nejm, lancet)
- Inline tables for R Markdown with frame/background styling
- Model comparison tables via `t2f_regression()`
- Batch processing with consistent styling
- Caching layer for performance optimization
- Multiple output formats (PDF, PNG, SVG)

## Document Catalog

### Primary Documentation

#### 1. User's Guide

- **File**: `USERS_GUIDE.md`
- **Purpose**: Complete user guide for package usage
- **Scope**: Quick start, features, S3 methods, themes, inline tables
- **Audience**: End users, data scientists, researchers
- **Content Areas**:
  - Installation and quick start
  - S3 method dispatch for statistical models
  - Theme system with journal presets
  - Inline tables for R Markdown
  - Model comparison tables
  - Advanced features (alignment, footnotes, batch processing)

#### 2. API Reference

- **File**: `API_REFERENCE.md`
- **Purpose**: Detailed function documentation and programming interface
- **Scope**: Function signatures, parameters, return values, examples
- **Audience**: Package developers, advanced users, integration specialists
- **Content Areas**:
  - Core functions (t2f, t2f_inline, t2f_regression, t2f_batch)
  - Theme system functions
  - Formatting helpers
  - LaTeX package helpers
  - Utility functions

#### 3. Technical Specifications

- **File**: `TECHNICAL_SPECIFICATIONS.md`
- **Purpose**: Comprehensive technical analysis of package implementation
- **Scope**: Architecture, performance, security, extensibility
- **Audience**: Technical developers, system administrators
- **Content Areas**:
  - S3 dispatch architecture
  - Theme system implementation
  - Caching layer design
  - Performance benchmarks
  - Security considerations

#### 4. Architecture Overview

- **File**: `ARCHITECTURE_OVERVIEW.md`
- **Purpose**: System design and architectural analysis
- **Scope**: Component design, data flow, extensibility framework
- **Audience**: Software architects, package maintainers, contributors
- **Content Areas**:
  - S3 dispatch architecture
  - Processing pipeline stages
  - Theme registry design
  - Caching architecture
  - Integration patterns

#### 5. Comprehensive README

- **File**: `README_COMPREHENSIVE.md`
- **Purpose**: Complete package overview with all features
- **Scope**: Installation, features, examples, troubleshooting
- **Audience**: All users
- **Content Areas**:
  - System requirements
  - Feature overview
  - Comparison with alternatives
  - Performance considerations
  - Troubleshooting guide

### Supporting Documentation

#### Package-Specific Files

- **DESCRIPTION**: Package metadata, dependencies, version 0.2.0
- **README.md**: Package README with feature overview
- **CLAUDE.md**: Development session history and enhancements
- **NAMESPACE**: Exported functions and S3 method registrations

#### Generated Documentation

- **man/*.Rd**: Auto-generated R documentation files
- **vignettes/**: Package vignettes with examples
- **tests/testthat/**: Test suite with comprehensive coverage

## Document Relationships

### Hierarchical Structure

```
Documentation Hierarchy:
├── User-Facing Documentation
│   ├── USERS_GUIDE.md (Primary user guide)
│   ├── README_COMPREHENSIVE.md (Complete overview)
│   └── Package vignettes (Usage examples)
├── Technical Documentation
│   ├── API_REFERENCE.md (Programming interface)
│   ├── TECHNICAL_SPECIFICATIONS.md (Implementation details)
│   └── ARCHITECTURE_OVERVIEW.md (System design)
└── Development Documentation
    ├── CLAUDE.md (Enhancement history)
    ├── Test suite (Quality assurance)
    └── Generated docs (Auto-documentation)
```

### Cross-References

#### Technical Depth Progression

1. **USERS_GUIDE.md** - Getting started and basic usage
2. **API_REFERENCE.md** - Detailed function specifications
3. **TECHNICAL_SPECIFICATIONS.md** - Implementation analysis
4. **ARCHITECTURE_OVERVIEW.md** - System design principles

#### Usage Flow Documentation

| Task | Primary Document | Supporting Documents |
|------|------------------|----------------------|
| Installation | USERS_GUIDE.md | README_COMPREHENSIVE.md |
| Quick start | USERS_GUIDE.md | Package vignettes |
| S3 methods | USERS_GUIDE.md | API_REFERENCE.md |
| Themes | USERS_GUIDE.md | API_REFERENCE.md |
| Inline tables | USERS_GUIDE.md | API_REFERENCE.md |
| Advanced features | API_REFERENCE.md | TECHNICAL_SPECIFICATIONS.md |
| Extension | ARCHITECTURE_OVERVIEW.md | API_REFERENCE.md |

## Key Features by Document

### USERS_GUIDE.md Coverage

| Feature | Section |
|---------|---------|
| Basic table generation | Quick Start |
| Statistical model tables | S3 Method Dispatch |
| Journal themes | Theme System |
| Inline R Markdown tables | Inline Tables |
| Model comparison | Model Comparison Tables |
| Decimal alignment | Column Alignment |
| Batch processing | Batch Processing |
| Caching | Caching |

### API_REFERENCE.md Coverage

| Function Category | Functions |
|-------------------|-----------|
| Core | t2f, t2f_inline, t2f_coef, t2f_regression |
| Batch | t2f_batch, t2f_batch_advanced, t2f_batch_spec |
| Themes | t2f_theme, t2f_theme_set/get, t2f_theme_register |
| Built-in themes | t2f_theme_minimal/apa/nature/nejm/lancet |
| Formatting | t2f_siunitx, t2f_decimal, t2f_footnote, t2f_header_above |
| Cell formatting | t2f_bold_col, t2f_italic_col, t2f_highlight |
| LaTeX helpers | geometry, babel, fontspec |
| Utilities | check_latex_deps, convert_pdf_to_png/svg |
| Cache | t2f_cache_info, t2f_cache_clear |

### TECHNICAL_SPECIFICATIONS.md Coverage

| Topic | Content |
|-------|---------|
| S3 architecture | Method resolution, supported classes |
| Pipeline stages | 10-stage processing flow |
| Theme system | Layered configuration, registry |
| Caching | Hash computation, storage structure |
| Performance | Complexity analysis, benchmarks |
| Security | Validation layers, trust boundaries |

### ARCHITECTURE_OVERVIEW.md Coverage

| Topic | Content |
|-------|---------|
| Component hierarchy | Layered architecture diagram |
| S3 dispatch | Method categories, resolution flow |
| Data flow | 10-stage pipeline |
| Theme registry | Package environment design |
| Caching flow | Hit/miss processing |
| Integration | R Markdown, knitr engine |

## Document Standards

### Academic Style Guidelines

All documentation follows consistent academic standards:

#### Language and Tone

- Scholarly, measured terminology
- Precise technical language without hyperbole
- Objective, analytical presentation
- Formal academic voice

#### Structure and Format

- Clear hierarchical organization
- Consistent section numbering
- Comprehensive cross-referencing
- Code examples with expected output

#### Technical Standards

- Complete parameter documentation
- Detailed error condition specifications
- Performance metrics with benchmarking data
- Security considerations analysis

### Documentation Quality Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Function coverage | 100% | Complete |
| Parameter documentation | All parameters | Complete |
| Working examples | All major use cases | Complete |
| S3 method documentation | All 20+ methods | Complete |
| Theme documentation | All 5 themes | Complete |

## Usage Guidelines

### For End Users

#### Getting Started Sequence

1. **Installation**: USERS_GUIDE.md Installation section
2. **Quick Start**: USERS_GUIDE.md Quick Start section
3. **Features**: USERS_GUIDE.md feature sections
4. **Troubleshooting**: README_COMPREHENSIVE.md Troubleshooting

#### Feature Learning Path

1. Basic data frame tables
2. Statistical model tables (lm, glm)
3. Journal themes
4. Inline tables for R Markdown
5. Model comparison tables
6. Batch processing

### For Developers

#### Understanding the System

1. ARCHITECTURE_OVERVIEW.md - System design
2. TECHNICAL_SPECIFICATIONS.md - Implementation
3. API_REFERENCE.md - Function interface
4. Test suite - Quality patterns

#### Extension Points

| Extension | Document | Section |
|-----------|----------|---------|
| Custom S3 methods | ARCHITECTURE_OVERVIEW.md | S3 Extension Points |
| Custom themes | USERS_GUIDE.md | Custom Themes |
| Custom formatters | API_REFERENCE.md | Formatting Functions |

### For Researchers

#### Academic Use Cases

- **Publication workflows**: Theme system for journal requirements
- **Regression tables**: t2f_regression for model comparison
- **Reproducible research**: Caching for consistent output
- **Collaboration**: Batch processing for consistent styling

#### Citation

```
Thomas, R.G. (2025). zztab2fig: Generate LaTeX Tables and PDF Outputs.
R package version 0.2.0. https://github.com/rgt47/zztab2fig
```

## Maintenance Guidelines

### Document Update Procedures

#### Version Synchronization

- All documents updated with package versions
- Cross-reference validation after updates
- Consistency checking across files

#### Quality Assurance

- Technical accuracy review
- Code example validation
- Cross-platform testing

### Future Enhancements

- Additional S3 method documentation
- Video tutorials
- Interactive examples
- Extended troubleshooting database

## Access and Distribution

### Repository Access

- All documents in `docs/` directory
- Version-controlled history
- Issue tracking for improvements

### Support Channels

- **Issues**: GitHub repository
- **Email**: rgthomas@ucsd.edu
- **Documentation**: This index and linked documents

## Conclusion

This documentation collection provides complete coverage of the `zztab2fig`
package v0.2.0 from multiple perspectives: user guidance, API reference,
technical specifications, and architectural design. The structured approach
supports users at all technical levels while maintaining scholarly standards
appropriate for academic and professional environments.
