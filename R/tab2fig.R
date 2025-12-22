#' Internal implementation for t2f
#'
#' @description Internal function that performs the actual table generation.
#'   This is called by the S3 methods defined in s3-methods.R.
#'
#' @param df A dataframe to be converted to a LaTeX table.
#' @param filename A character string. The base name of the output files
#'   (without extensions).
#' @param sub_dir A character string. The subdirectory where output files will
#'   be stored. Defaults to "output".
#' @param scolor A LaTeX color name for alternating row shading in the table
#'   (e.g., "blue!10"). Overrides theme setting if provided.
#' @param verbose Logical. If TRUE, prints progress messages.
#' @param extra_packages A list of LaTeX package specifications. Can include
#'   helper functions like geometry(), babel(), fontspec() or raw LaTeX
#'   strings. Combined with theme packages if a theme is active.
#' @param document_class LaTeX document class to use. Defaults to "article".
#'   Overrides theme setting if provided.
#' @param caption A character string. LaTeX caption for the table. Defaults to
#'   NULL (no caption).
#' @param label A character string. LaTeX label for cross-referencing (e.g.,
#'   "tab:mytable"). Defaults to NULL (no label).
#' @param align Column alignment specification. Can be NULL (auto-detect),
#'   a single character ("l", "c", "r") applied to all columns, or a character
#'   vector with one alignment per column.
#' @param longtable Logical. If TRUE, uses longtable package for tables
#'   spanning multiple pages. Defaults to FALSE.
#' @param crop Logical. If TRUE (default), crops the PDF to remove margins.
#' @param crop_margin Numeric. Margin size in points for cropped PDF. Can be a
#'   single value (applied to all sides) or a vector of 4 values (left, top,
#'   right, bottom). Defaults to 10.
#' @param theme A t2f_theme object or character string naming a built-in theme
#'   ("minimal", "apa", "nature", "nejm"). Theme settings are used as defaults
#'   but can be overridden by explicit arguments.
#'
#' @return Invisibly returns the path to the cropped PDF file (or full PDF if
#'   crop=FALSE).
#'
#' @importFrom kableExtra kable row_spec kable_styling column_spec
#' @keywords internal
t2f_internal <- function(df, filename = NULL,
                sub_dir = "output",
                scolor = NULL, verbose = FALSE,
                extra_packages = NULL,
                document_class = NULL,
                caption = NULL,
                label = NULL,
                align = NULL,
                longtable = FALSE,
                crop = TRUE,
                crop_margin = 10,
                theme = NULL) {

  # Validate inputs
  if (is.null(filename)) filename <- deparse(substitute(df))
  if (!is.data.frame(df)) stop("`df` must be a dataframe.", call. = FALSE)
  if (nrow(df) == 0) stop("`df` must not be empty.", call. = FALSE)
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("`verbose` must be a single logical value.", call. = FALSE)
  }
  if (!is.logical(crop) || length(crop) != 1) {
    stop("`crop` must be a single logical value.", call. = FALSE)
  }
  if (!is.logical(longtable) || length(longtable) != 1) {
    stop("`longtable` must be a single logical value.", call. = FALSE)
  }

  # Validate crop_margin
  if (!is.numeric(crop_margin) || !(length(crop_margin) %in% c(1, 4))) {
    stop("`crop_margin` must be numeric of length 1 or 4.", call. = FALSE)
  }

  # Validate caption and label
  if (!is.null(caption) && (!is.character(caption) || length(caption) != 1)) {
    stop("`caption` must be a single character string or NULL.", call. = FALSE)
  }
  if (!is.null(label) && (!is.character(label) || length(label) != 1)) {
    stop("`label` must be a single character string or NULL.", call. = FALSE)
  }

  # Validate alignment
  if (!is.null(align)) {
    if (!is.character(align)) {
      stop("`align` must be a character vector or NULL.", call. = FALSE)
    }
    valid_aligns <- c("l", "c", "r")
    if (!all(align %in% valid_aligns)) {
      stop("`align` must contain only 'l', 'c', or 'r'.", call. = FALSE)
    }
    if (length(align) != 1 && length(align) != ncol(df)) {
      stop("`align` must be length 1 or match number of columns.", call. = FALSE)
    }
  }

  # Resolve theme and apply settings
  resolved_theme <- resolve_theme(theme)
  theme_settings <- apply_theme_settings(
    resolved_theme,
    scolor = scolor,
    document_class = document_class,
    extra_packages = extra_packages
  )

  # Use resolved values (explicit args override theme)
  scolor <- theme_settings$scolor
  document_class <- theme_settings$document_class
  extra_packages <- theme_settings$extra_packages
  striped <- theme_settings$striped

  # Validate resolved values
  if (!is.character(scolor) || length(scolor) != 1) {
    stop("`scolor` must be a single character string.", call. = FALSE)
  }
  if (!is.character(document_class) || length(document_class) != 1) {
    stop("`document_class` must be a single character string.", call. = FALSE)
  }

  # Validate directory path
  if (is.null(sub_dir)) stop("Directory name cannot be NULL", call. = FALSE)
  if (sub_dir == "") stop("Directory name cannot be empty", call. = FALSE)
  if (!is.character(sub_dir) || length(sub_dir) != 1) {
    stop("`sub_dir` must be a single character string.", call. = FALSE)
  }

  # Try to create directory and check if we can write to it
  if (!dir.exists(sub_dir)) {
    tryCatch(
      {
        dir.create(sub_dir, recursive = TRUE)
      },
      error = function(e) {
        stop("Cannot create directory: ", sub_dir, "\nError: ", e$message, call. = FALSE)
      }
    )
  }

  # Check if directory is writable
  if (file.access(sub_dir, mode = 2) != 0) {
    stop("Directory is not writable: ", sub_dir, call. = FALSE)
  }

  # Sanitize column names
  colnames(df) <- sanitize_column_names(names(df))

  # Generate sanitized filename
  filename <- sanitize_filename(filename)

  # Paths for output files
  tex_file <- file.path(sub_dir, paste0(filename, ".tex"))
  pdf_file <- file.path(sub_dir, paste0(filename, ".pdf"))
  cropped_pdf_file <- file.path(sub_dir, paste0(filename, "_cropped.pdf"))

  # Auto-detect alignment if not specified
  if (is.null(align)) {
    align <- auto_align(df)
  } else if (length(align) == 1) {
    align <- rep(align, ncol(df))
  }

  # Create LaTeX table
  log_message("Generating LaTeX table...", verbose)
  create_latex_table(
    df = df,
    tex_file = tex_file,
    scolor = scolor,
    extra_packages = extra_packages,
    document_class = document_class,
    caption = caption,
    label = label,
    align = align,
    longtable = longtable,
    striped = striped
  )

  # Compile LaTeX to PDF
  log_message("Compiling LaTeX to PDF...", verbose)
  compile_latex(tex_file, sub_dir)

  # Determine output file
  if (crop) {
    log_message("Cropping PDF...", verbose)
    crop_pdf(pdf_file, cropped_pdf_file, margin = crop_margin)
    output_file <- cropped_pdf_file
  } else {
    output_file <- pdf_file
  }

  log_message(paste("PDF generated at:", output_file), verbose)

  invisible(output_file)
}

# LaTeX Package Helper Functions

#' Create a geometry package specification
#' @param margin Page margin specification (e.g., "5mm")
#' @param paper Paper size specification (e.g., "a4paper")
#' @param landscape Logical. If TRUE, sets landscape orientation.
#' @param ... Additional geometry options
#' @return Character string with LaTeX geometry package specification
#' @export
geometry <- function(margin = NULL, paper = NULL, landscape = FALSE, ...) {
  opts <- list(margin = margin, paper = paper, ...)
  if (landscape) opts$landscape <- TRUE

  opts <- opts[!sapply(opts, is.null)]

  if (length(opts) == 0) {
    return("\\usepackage{geometry}")
  }

  # Handle logical values
  opt_strs <- sapply(names(opts), function(name) {
    value <- opts[[name]]
    if (is.logical(value) && value) {
      name
    } else {
      paste0(name, "=", value)
    }
  })

  opt_str <- paste(opt_strs, collapse = ",")
  paste0("\\usepackage[", opt_str, "]{geometry}")
}

#' Create a babel package specification for language support
#' @param language Language code (e.g., "spanish", "french", "german")
#' @return Character string with LaTeX babel package specification
#' @export
babel <- function(language) {
  if (!is.character(language) || length(language) != 1) {
    stop("`language` must be a single character string", call. = FALSE)
  }
  paste0("\\usepackage[", language, "]{babel}")
}

#' Create fontspec package specification for custom fonts
#' @param main_font Main font family name
#' @param sans_font Sans-serif font family name
#' @param mono_font Monospace font family name
#' @return Character vector with LaTeX fontspec package specifications
#' @export
fontspec <- function(main_font = NULL, sans_font = NULL, mono_font = NULL) {
  packages <- "\\usepackage{fontspec}"

  if (!is.null(main_font)) {
    packages <- c(packages, paste0("\\setmainfont{", main_font, "}"))
  }
  if (!is.null(sans_font)) {
    packages <- c(packages, paste0("\\setsansfont{", sans_font, "}"))
  }
  if (!is.null(mono_font)) {
    packages <- c(packages, paste0("\\setmonofont{", mono_font, "}"))
  }

  packages
}

#' Create LaTeX document template with specified packages
#' @param document_class LaTeX document class
#' @param extra_packages List of package specifications or character strings
#' @param longtable Logical. Include longtable package if TRUE.
#' @return Character string with complete LaTeX document preamble
create_latex_template <- function(document_class = "article",
                                  extra_packages = NULL, longtable = FALSE) {
  # Basic required packages
  base_packages <- c(
    "\\usepackage[table]{xcolor}",
    "\\usepackage{booktabs}"
  )

  # Add longtable package if needed
  if (longtable) {
    base_packages <- c(base_packages, "\\usepackage{longtable}")
  }

  # Process extra packages
  processed_packages <- character(0)
  if (!is.null(extra_packages)) {
    for (pkg in extra_packages) {
      if (is.character(pkg)) {
        processed_packages <- c(processed_packages, pkg)
      } else if (is.list(pkg)) {
        processed_packages <- c(processed_packages, unlist(pkg))
      }
    }
  }

  # Combine all packages
  all_packages <- c(base_packages, processed_packages)

  # Create template
  template_parts <- c(
    paste0("\\documentclass{", document_class, "}"),
    all_packages,
    "\\begin{document}",
    "\\thispagestyle{empty}",
    ""
  )

  paste(template_parts, collapse = "\n")
}

# Helper Functions

#' Sanitize column names to be valid in both R and LaTeX
#' @param colnames A character vector of column names.
#' @return A sanitized character vector of column names.
sanitize_column_names <- function(colnames) {
  gsub("[^a-zA-Z0-9_]", "_", make.names(colnames))
}

#' Sanitize table cells to be LaTeX-safe
#' @param cells A character vector of table cell values.
#' @return A sanitized character vector of table cell values.
sanitize_table_cells <- function(cells) {
  if (!is.character(cells)) cells <- as.character(cells)
  gsub("([#%&$])", "\\\\\\1", cells)
}

#' Sanitize filenames to be file-system safe
#' @param filename A character string.
#' @return A sanitized character string.
sanitize_filename <- function(filename) {
  gsub("[^a-zA-Z0-9_]", "_", filename)
}

#' Auto-detect column alignment based on data types
#' @param df A dataframe.
#' @return A character vector of alignments ("l", "c", or "r").
#' @keywords internal
auto_align <- function(df) {
  vapply(df, function(col) {
    if (is.numeric(col)) {
      "r"
    } else {
      "l"
    }
  }, character(1))
}

#' Create a LaTeX table with alternating row colors using kableExtra
#' @param df A dataframe to convert to a LaTeX table.
#' @param tex_file Path to the output LaTeX file.
#' @param scolor A LaTeX color name for alternating row shading.
#' @param extra_packages A list of LaTeX package specifications. Defaults to
#'   NULL.
#' @param document_class LaTeX document class to use. Defaults to "article".
#' @param caption Table caption. Defaults to NULL.
#' @param label LaTeX label for cross-referencing. Defaults to NULL.
#' @param align Column alignment vector. Defaults to NULL (auto).
#' @param longtable Logical. Use longtable for multi-page tables.
#' @param striped Logical. Apply alternating row colors.
#' @keywords internal
create_latex_table <- function(df, tex_file, scolor, extra_packages = NULL,
                               document_class = "article", caption = NULL,
                               label = NULL, align = NULL, longtable = FALSE,
                               striped = TRUE) {
  if (!requireNamespace("kableExtra", quietly = TRUE)) {
    stop("The 'kableExtra' package is required but not installed.")
  }

  # Sanitize table cells
  df[] <- lapply(df, function(col) {
    if (is.character(col)) {
      sanitize_table_cells(col)
    } else {
      col
    }
  })

  # Build alignment string
  align_str <- if (!is.null(align)) paste(align, collapse = "") else NULL

  # Generate LaTeX table
  latex_table <- kableExtra::kable(
    df,
    format = "latex",
    booktabs = TRUE,
    longtable = longtable,
    caption = caption,
    label = label,
    align = align_str
  )

  # Apply header styling
  latex_table <- kableExtra::row_spec(latex_table, 0, bold = TRUE)

  # Apply row styling based on striped setting
  if (striped) {
    latex_table <- kableExtra::kable_styling(
      latex_table,
      latex_options = c("striped", if (longtable) "repeat_header" else NULL),
      stripe_color = scolor
    )
  } else if (longtable) {
    latex_table <- kableExtra::kable_styling(
      latex_table,
      latex_options = "repeat_header"
    )
  }

  # Create LaTeX document with template
  template <- create_latex_template(document_class, extra_packages, longtable)
  ending <- "\\end{document}"

  writeLines(c(template, latex_table, ending), con = tex_file)
}

#' Compile a LaTeX file to PDF
#' @param tex_file Path to the LaTeX file.
#' @param sub_dir Directory where the PDF will be generated.
compile_latex <- function(tex_file, sub_dir) {
  old_wd <- setwd(sub_dir)
  on.exit(setwd(old_wd))

  cmd <- paste("pdflatex -interaction=batchmode", shQuote(basename(tex_file)))
  result <- system(cmd)

  if (result != 0) {
    log_file <- file.path(sub_dir, paste0(tools::file_path_sans_ext(basename(tex_file)), ".log"))
    if (file.exists(log_file)) {
      log_content <- readLines(log_file, n = 20)
      error_lines <- log_content[grepl("!", log_content)]
      if (length(error_lines) > 0) {
        stop("LaTeX compilation failed. Errors found:\n",
          paste(error_lines[1:min(3, length(error_lines))], collapse = "\n"),
          call. = FALSE
        )
      }
    }
    stop("LaTeX compilation failed with exit code: ", result, call. = FALSE)
  }
}

#' Crop a PDF file
#' @param input_pdf Path to the input PDF file.
#' @param output_pdf Path to the output cropped PDF file.
#' @param margin Numeric. Margin size in points. Can be a single value (applied
#'   to all sides) or a vector of 4 values (left, top, right, bottom).
crop_pdf <- function(input_pdf, output_pdf, margin = 10) {
  # Format margin argument
  if (length(margin) == 1) {
    margin_str <- as.character(margin)
  } else if (length(margin) == 4) {
    margin_str <- paste(margin, collapse = " ")
  } else {
    stop("`margin` must be length 1 or 4.", call. = FALSE)
  }

  cmd <- paste("pdfcrop -margins", shQuote(margin_str),
    shQuote(input_pdf), shQuote(output_pdf)
  )
  result <- system(cmd)

  if (result != 0) {
    stop("PDF cropping failed with exit code: ", result, call. = FALSE)
  }

  if (!file.exists(output_pdf)) {
    stop("PDF cropping failed: output file was not created", call. = FALSE)
  }
}

#' Log messages if verbose is TRUE
#' @param msg A message to display.
#' @param verbose Logical indicating whether to display the message. Defaults
#'   to FALSE.
#' @keywords internal
log_message <- function(msg, verbose = FALSE) {
  if (isTRUE(verbose)) message(msg)
}
