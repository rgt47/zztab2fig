#' Package Initialization
#'
#' @description Functions called when the package is loaded or attached.
#'
#' @name zzz
NULL

.onLoad <- function(libname, pkgname) {
  # Register the t2f knitr engine if knitr is available
  if (requireNamespace("knitr", quietly = TRUE)) {
    knitr::knit_engines$set(t2f = t2f_engine)
  }

  invisible()
}

.onAttach <- function(libname, pkgname) {
  # Display startup message with version
  pkg_version <- utils::packageVersion(pkgname)
  packageStartupMessage(
    "zztab2fig ", pkg_version, " - LaTeX table generation for R"
  )

  # Check for required system dependencies
  has_pdflatex <- check_system_command("pdflatex")
  has_pdfcrop <- check_system_command("pdfcrop")

  if (!has_pdflatex) {
    packageStartupMessage(
      "Note: pdflatex not found. Install a LaTeX distribution to use t2f()."
    )
  }

  if (!has_pdfcrop) {
    packageStartupMessage(
      "Note: pdfcrop not found. PDF cropping will not be available."
    )
  }

  invisible()
}

#' Check if a system command is available
#'
#' @param cmd Command name to check.
#' @return Logical indicating if command is available.
#' @keywords internal
check_system_command <- function(cmd) {
  result <- suppressWarnings(
    system(paste(cmd, "--version"), ignore.stdout = TRUE, ignore.stderr = TRUE)
  )
  result == 0
}
