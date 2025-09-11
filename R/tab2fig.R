#' Convert a dataframe to a LaTeX table and generate a cropped PDF
#' @author Ronald G. Thomas
#' @description: A package to create LaTeX tables from dataframes with optional styling and generate cropped PDF outputs.
#'
#' @param df A dataframe to be converted to a LaTeX table.
#' @param filename A character string. The base name of the output files (without extensions).
#' @param sub_dir A character string. The subdirectory where output files will be stored. Defaults to "output".
#' @param scolor A LaTeX color name for alternating row shading in the table (e.g., "blue!10").
#' @param verbose Logical. If TRUE, prints progress messages.
#' @param extra_packages A list of LaTeX package specifications. Can include helper functions like geometry(), babel(), fontspec() or raw LaTeX strings.
#' @param document_class LaTeX document class to use. Defaults to "article".
#' @return Invisibly returns the path to the cropped PDF file.
#' @examples
#' \dontrun{
#' t2f(mtcars,
#'         filename = "mtcars_table", sub_dir = "tables",
#'         scolor = "blue!10", verbose = TRUE
#' )
#' 
#' # With custom LaTeX packages
#' t2f(mtcars,
#'     extra_packages = list(
#'       geometry(margin = "5mm", paper = "a4paper"),
#'       babel("spanish")
#'     )
#' )
#' }
#' @importFrom kableExtra kable row_spec kable_styling
#' @importFrom glue glue
#' @export
t2f <- function(df, filename = NULL,
               sub_dir = "output",
               scolor = "blue!10", verbose = FALSE,
               extra_packages = NULL,
               document_class = "article") {
       # Validate inputs
       if (is.null(filename)) filename <- deparse(substitute(df))
       if (!is.data.frame(df)) stop("`df` must be a dataframe.", call. = FALSE)
       if (nrow(df) == 0) stop("`df` must not be empty.", call. = FALSE)
       if (!is.character(scolor) || length(scolor) != 1) {
         stop("`scolor` must be a single character string.", call. = FALSE)
       }
       if (!is.character(document_class) || length(document_class) != 1) {
         stop("`document_class` must be a single character string.", call. = FALSE)
       }
       if (!is.logical(verbose) || length(verbose) != 1) {
         stop("`verbose` must be a single logical value.", call. = FALSE)
       }
       
       # Validate directory path
       if (is.null(sub_dir)) stop("Directory name cannot be NULL", call. = FALSE)
       if (sub_dir == "") stop("Directory name cannot be empty", call. = FALSE)
       if (!is.character(sub_dir) || length(sub_dir) != 1) {
         stop("`sub_dir` must be a single character string.", call. = FALSE)
       }
       
       # Try to create directory and check if we can write to it
       if (!dir.exists(sub_dir)) {
         tryCatch({
           dir.create(sub_dir, recursive = TRUE)
         }, error = function(e) {
           stop("Cannot create directory: ", sub_dir, "\nError: ", e$message, call. = FALSE)
         })
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

       # Create LaTeX table
       log_message("Generating LaTeX table...", verbose)
       create_latex_table(df, tex_file, scolor, extra_packages, document_class)

       # Compile LaTeX to PDF
       log_message("Compiling LaTeX to PDF...", verbose)
       compile_latex(tex_file, sub_dir)

       # Crop PDF
       log_message("Cropping PDF...", verbose)
       crop_pdf(pdf_file, cropped_pdf_file)

       log_message(paste("PDF generated at:", cropped_pdf_file), verbose)

       # Return cropped PDF path invisibly
       invisible(cropped_pdf_file)
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
#' @return Character string with complete LaTeX document preamble
create_latex_template <- function(document_class = "article", extra_packages = NULL) {
  # Basic required packages
  base_packages <- c(
    "\\usepackage[table]{xcolor}",
    "\\usepackage{booktabs}"
  )
  
  # Process extra packages
  processed_packages <- character(0)
  if (!is.null(extra_packages)) {
    for (pkg in extra_packages) {
      if (is.character(pkg)) {
        processed_packages <- c(processed_packages, pkg)
      } else if (is.list(pkg)) {
        # Handle case where package functions return multiple lines
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

#' Create a LaTeX table with alternating row colors using kableExtra
#' @param df A dataframe to convert to a LaTeX table.
#' @param tex_file Path to the output LaTeX file.
#' @param scolor A LaTeX color name for alternating row shading.
#' @param extra_packages A list of LaTeX package specifications.
#' @param document_class LaTeX document class to use.
create_latex_table <- function(df, tex_file, scolor, extra_packages = NULL, document_class = "article") {
        # Install kableExtra if not installed
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
        
        # Generate LaTeX table
        latex_table <- kableExtra::kable(df, format = "latex", booktabs = TRUE) |>
                kableExtra::row_spec(0, bold = TRUE) |>
                kableExtra::kable_styling(
                        latex_options = c("striped"),
                        stripe_color = scolor
                )

        # Create LaTeX document with template
        template <- create_latex_template(document_class, extra_packages)
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
                   call. = FALSE)
            }
          }
          stop("LaTeX compilation failed with exit code: ", result, call. = FALSE)
        }
}

#' Crop a PDF file
#' @param input_pdf Path to the input PDF file.
#' @param output_pdf Path to the output cropped PDF file.
crop_pdf <- function(input_pdf, output_pdf) {
        cmd <- paste("pdfcrop -margins 10", shQuote(input_pdf), shQuote(output_pdf))
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
#' @param verbose Logical indicating whether to display the message.
log_message <- function(msg, verbose = FALSE) {
        if (isTRUE(verbose)) message(msg)
}
