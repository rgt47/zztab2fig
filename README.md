# **zztab2fig**  

[![CRAN status](https://www.r-pkg.org/badges/version/zztab2fig)](https://CRAN.R-project.org/package=zztab2fig)  
[![License](https://img.shields.io/badge/license-GPL3-blue.svg)](LICENSE)  
[![R-CMD-check](https://github.com/YourUsername/zztab2fig/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/YourUsername/zztab2fig/actions)  

## **Overview**  

**zztab2fig** is an R package for creating LaTeX tables from data frames and generating cropped PDF outputs. With built-in functionality for row shading, column sanitization, and PDF cropping, the package streamlines the process of turning your data into polished, publication-ready tables.  

This package is ideal for data scientists, researchers, and statisticians who frequently present data in professional reports or academic papers.  

## **Key Features**  

- Converts data frames into LaTeX tables with customizable row shading.  
- Automatically sanitizes column names and table cells to ensure compatibility with LaTeX.  
- Generates cropped PDF files of the tables for direct use in publications.  
- Provides verbose output to track progress during table creation.  

## **Installation**  

### From CRAN  
To install the stable version:  
```R  
install.packages("zztab2fig")  
```

### From GitHub  
To install the development version:  
```R  
# install.packages("devtools")  
devtools::install_github("rgt47/zztab2fig")  
```

## **Why zztab2fig vs. flextable?**

Both `zztab2fig` and `flextable` can export tables as standalone PDF files, but they serve different use cases:

### **Choose zztab2fig when you want:**
- **LaTeX-native approach**: Creates actual LaTeX code using `pdflatex` and `pdfcrop` for professional LaTeX typography
- **Simplicity**: Single function `t2f()` with minimal parameters - focused specifically on the dataframe → cropped PDF workflow  
- **LaTeX ecosystem integration**: Generated `.tex` files can be manually edited and work within existing LaTeX workflows
- **kableExtra styling**: Uses familiar kableExtra formatting that LaTeX users already know
- **Lightweight solution**: Minimal dependencies focused on one specific task

### **Choose flextable when you want:**
- **Multi-format output**: Tables for Word, PowerPoint, HTML, and PDF in one package
- **Mixed content**: Combine text and images within table cells
- **Extensive formatting**: More styling options and conditional formatting capabilities
- **R graphics system**: Uses R's native graphics system rather than external LaTeX tools

### **The Table Placement Problem**
Both packages solve the common R Markdown issue where LaTeX treats tables as "floats" that move away from their intended position. However:
- **zztab2fig** bypasses this by creating standalone PDFs that can be included as images (no floating)  
- **flextable** uses R's graphics system to avoid LaTeX float behavior entirely

**Bottom line:** `zztab2fig` is a specialized, LaTeX-focused tool, while `flextable` is a general-purpose table package. Choose based on your workflow preferences and output requirements.
