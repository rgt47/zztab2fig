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

#' Ensure pdfcrop is available
#'
#' @description Checks for pdfcrop and attempts to install it via tinytex
#'   if available. Provides helpful instructions if installation is not
#'   possible.
#'
#' @param auto_install Logical. If TRUE, attempt automatic installation
#'   via tinytex. Default is TRUE.
#' @param verbose Logical. Print status messages. Default is TRUE.
#'
#' @return Logical indicating if pdfcrop is available (invisibly).
#'
#' @examples
#' \dontrun{
#' ensure_pdfcrop()
#' }
#'
#' @export
ensure_pdfcrop <- function(auto_install = TRUE, verbose = TRUE) {
  # Check if pdfcrop already exists

  if (nzchar(Sys.which("pdfcrop"))) {
    if (verbose) message("pdfcrop is available.")
    return(invisible(TRUE))
  }


  # Check if tinytex R package is installed

  has_tinytex_pkg <- requireNamespace("tinytex", quietly = TRUE)

  if (!has_tinytex_pkg) {
    warning(
      "pdfcrop not found and tinytex R package is not installed.\n\n",
      "Option 1 - Install tinytex (recommended for R users):\n",
      "  install.packages('tinytex')\n",
      "  tinytex::install_tinytex()\n",
      "  tinytex::tlmgr_install('pdfcrop')\n\n",
      "Option 2 - Install via system package manager:\n",
      "  macOS:   brew install pdfcrop\n",
      "  Ubuntu:  sudo apt install texlive-extra-utils\n",
      "  Fedora:  sudo dnf install texlive-pdfcrop\n\n",
      "Option 3 - Use t2f() without cropping:\n",
      "  t2f(data, crop = FALSE)",
      call. = FALSE
    )
    return(invisible(FALSE))
  }

  # Check if tinytex distribution is installed
  has_tinytex_dist <- tinytex::is_tinytex()

  if (!has_tinytex_dist) {
    if (auto_install && verbose) {
      message(
        "tinytex R package found but TinyTeX distribution not installed.\n",
        "Install with: tinytex::install_tinytex()"
      )
    }
    warning(
      "pdfcrop not found. TinyTeX distribution is not installed.\n\n",
      "To install TinyTeX and pdfcrop:\n",
      "  tinytex::install_tinytex()\n",
      "  tinytex::tlmgr_install('pdfcrop')\n\n",
      "Or use t2f() without cropping: t2f(data, crop = FALSE)",
      call. = FALSE
    )
    return(invisible(FALSE))
  }

  # TinyTeX is available - try to install pdfcrop
  if (auto_install) {
    if (verbose) message("Installing pdfcrop via tinytex...")
    tryCatch(
      {
        tinytex::tlmgr_install("pdfcrop")
        if (nzchar(Sys.which("pdfcrop"))) {
          if (verbose) message("pdfcrop installed successfully.")
          return(invisible(TRUE))
        }
      },
      error = function(e) {
        warning(
          "Failed to install pdfcrop: ", conditionMessage(e),
          call. = FALSE
        )
      }
    )
  }

  # Installation failed or not attempted
  warning(
    "pdfcrop not available.\n",
    "Install manually with: tinytex::tlmgr_install('pdfcrop')\n",
    "Or use t2f() without cropping: t2f(data, crop = FALSE)",
    call. = FALSE
  )
  invisible(FALSE)
}

#' Ensure pdflatex is available
#'
#' @description Checks for pdflatex and provides installation instructions
#'   if not found.
#'
#' @param verbose Logical. Print status messages. Default is TRUE.
#'
#' @return Logical indicating if pdflatex is available (invisibly).
#'
#' @examples
#' \dontrun{
#' ensure_pdflatex()
#' }
#'
#' @export
ensure_pdflatex <- function(verbose = TRUE) {
  if (nzchar(Sys.which("pdflatex"))) {
    if (verbose) message("pdflatex is available.")
    return(invisible(TRUE))
  }

  has_tinytex_pkg <- requireNamespace("tinytex", quietly = TRUE)

  if (has_tinytex_pkg && !tinytex::is_tinytex()) {
    warning(
      "pdflatex not found. TinyTeX distribution is not installed.\n\n",
      "Install with: tinytex::install_tinytex()",
      call. = FALSE
    )
  } else if (!has_tinytex_pkg) {
    warning(
      "pdflatex not found. No LaTeX distribution detected.\n\n",
      "Option 1 - Install tinytex (recommended for R users):\n",
      "  install.packages('tinytex')\n",
      "  tinytex::install_tinytex()\n\n",
      "Option 2 - Install a full LaTeX distribution:\n",
      "  macOS:   brew install --cask mactex\n",
      "  Ubuntu:  sudo apt install texlive-full\n",
      "  Windows: https://miktex.org/",
      call. = FALSE
    )
  } else {
    warning("pdflatex not found.", call. = FALSE)
  }

  invisible(FALSE)
}

#' Check LaTeX dependencies for zztab2fig
#'
#' @description Checks that all required LaTeX tools are available and
#'   provides installation guidance if not.
#'
#' @param auto_install Logical. Attempt to auto-install missing components
#'   via tinytex. Default is TRUE.
#'
#' @return A list with availability status for each component (invisibly).
#'
#' @examples
#' \dontrun{
#' check_latex_deps()
#' }
#'
#' @export
check_latex_deps <- function(auto_install = TRUE) {
  message("Checking LaTeX dependencies for zztab2fig...\n")

  has_pdflatex <- nzchar(Sys.which("pdflatex"))
  has_pdfcrop <- nzchar(Sys.which("pdfcrop"))

  message("pdflatex: ", if (has_pdflatex) "OK" else "NOT FOUND")
  message("pdfcrop:  ", if (has_pdfcrop) "OK" else "NOT FOUND")

  if (!has_pdflatex) {
    message("")
    ensure_pdflatex(verbose = FALSE)
  }

  if (!has_pdfcrop && auto_install) {
    message("")
    ensure_pdfcrop(auto_install = TRUE, verbose = TRUE)
    has_pdfcrop <- nzchar(Sys.which("pdfcrop"))
  }

  result <- list(
    pdflatex = has_pdflatex,
    pdfcrop = has_pdfcrop,
    ready = has_pdflatex
  )

  if (all(unlist(result))) {
    message("\nAll dependencies available. zztab2fig is ready to use.")
  } else if (has_pdflatex) {
    message("\nzztab2fig can run but PDF cropping is unavailable.")
  } else {
    message("\nzztab2fig requires pdflatex. Please install a LaTeX distribution.")
  }

  invisible(result)
}
