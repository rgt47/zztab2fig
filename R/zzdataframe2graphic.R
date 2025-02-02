#' Convert a dataframe to a LaTeX table and generate a cropped PDF
#' @author Ronald G. Thomas
#' @description: A package to create LaTeX tables from dataframes with optional styling and generate cropped PDF outputs.
#'
#' @param df A dataframe to be converted to a LaTeX table.
#' @param filename A character string. The base name of the output files (without extensions).
#' @param sub_dir A character string. The subdirectory where output files will be stored. Defaults to "output".
#' @param scolor A LaTeX color name for alternating row shading in the table (e.g., "blue!10").
#' @param verbose Logical. If TRUE, prints progress messages.
#' @return Invisibly returns the path to the cropped PDF file.
#' @examples
#' \dontrun{
#' d2g(mtcars,
#'         filename = "mtcars_table", sub_dir = "tables",
#'         scolor = "blue!10", verbose = TRUE
#' )
#' }
#' @export
d2g <- function(df, filename = NULL,
               sub_dir = "output",
               scolor = "blue!10", verbose = FALSE) {
       # Validate input dataframe
       if (is.null(filename)) filename <- deparse(substitute(df))
       if (!is.data.frame(df)) stop("`df` must be a dataframe.")
       if (nrow(df) == 0) stop("`df` must not be empty.")
       
       # Validate directory path
       if (is.null(sub_dir)) stop("Directory name cannot be NULL")
       if (sub_dir == "") stop("Directory name cannot be empty")
       
       # Try to create directory and check if we can write to it
       if (!dir.exists(sub_dir)) {
         tryCatch({
           dir.create(sub_dir, recursive = TRUE)
         }, error = function(e) {
           stop("Cannot create directory: ", sub_dir)
         })
       }
       
       # Check if directory is writable
       if (file.access(sub_dir, mode = 2) != 0) {
         stop("Directory is not writable: ", sub_dir)
       }

       # Sanitize column names
       colnames(df) <- sanitize_column_names(names(df))

       # Generate sanitized filename
       filename <- sanitize_filename(filename)

       # Paths for output files
       tex_file <- file.path(sub_dir, glue::glue("{filename}.tex"))
       pdf_file <- file.path(sub_dir, glue::glue("{filename}.pdf"))
       cropped_pdf_file <- file.path(sub_dir, glue::glue("{filename}_cropped.pdf"))

       # Create LaTeX table
       log_message("Generating LaTeX table...")
       create_latex_table(df, tex_file, scolor)

       # Compile LaTeX to PDF
       log_message("Compiling LaTeX to PDF...")
       compile_latex(tex_file, sub_dir)

       # Crop PDF
       log_message("Cropping PDF...")
       crop_pdf(pdf_file, cropped_pdf_file)

       log_message(glue::glue("PDF generated at: {cropped_pdf_file}"))

       # Return cropped PDF path invisibly
       invisible(cropped_pdf_file)
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
create_latex_table <- function(df, tex_file, scolor) {
        # Install kableExtra if not installed
        if (!requireNamespace("kableExtra", quietly = TRUE)) {
                stop("The 'kableExtra' package is required but not installed.")
        }

        # Generate LaTeX table
        latex_table <- kableExtra::kable(df, format = "latex", booktabs = TRUE) |>
                kableExtra::row_spec(0, bold = TRUE) |>
                kableExtra::kable_styling(
                        latex_options = c("striped"),
                        stripe_color = scolor
                )

        # Add to LaTeX document
        prelude <- "\\documentclass{article}\n\\usepackage[table]{xcolor}
  \n\\usepackage{booktabs}\n\\begin{document}\n\\thispagestyle{empty}\n"
        ending <- "\\end{document}"

        writeLines(c(prelude, latex_table, ending), con = tex_file)
}

#' Compile a LaTeX file to PDF
#' @param tex_file Path to the LaTeX file.
#' @param sub_dir Directory where the PDF will be generated.
compile_latex <- function(tex_file, sub_dir) {
        old_wd <- setwd(sub_dir)
        on.exit(setwd(old_wd))

        system(glue::glue("pdflatex -interaction=batchmode {basename(tex_file)}"))
}

#' Crop a PDF file
#' @param input_pdf Path to the input PDF file.
#' @param output_pdf Path to the output cropped PDF file.
crop_pdf <- function(input_pdf, output_pdf) {
        system(glue::glue("pdfcrop -margins 10 {shQuote(input_pdf)} {shQuote(output_pdf)}"))
        # since pdfcrop creates a new file, we need to rename it to the original
        # file name. We can do this by issuing a system command to rename the
        # file.
        # issue a system command to rename the cropped file as the original file
        system(glue::glue("mv {shQuote(output_pdf)} {shQuote(input_pdf)}"))
}

#' Log messages if verbose is TRUE
#' @param msg A message to display.
log_message <- function(msg) {
        if (getOption("verbose", FALSE)) message(msg)
}
