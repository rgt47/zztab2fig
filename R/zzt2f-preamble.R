#' Preamble Emitters for the Typst Backend
#'
#' @description Parallel to the LaTeX preamble helpers (\code{babel},
#'   \code{fontspec}, \code{geometry}) but emit Typst directives
#'   (\code{#set text(lang: ...)}, \code{#set text(font: ...)},
#'   \code{#set page(...)}). Each returns a character vector of
#'   directive lines that can be prepended to a \code{.typ} document
#'   or passed to \code{zzt2f(..., preamble = ...)} when that
#'   consumption site lands.
#'
#' @details
#' These helpers are intentionally thin. Typst users normally write
#' preamble directives directly in their \code{.typ} source; these
#' exist so that code migrating from \code{t2f_*} has
#' naming-consistent alternatives. Flagged for review: keep as a
#' programmatic-preamble API, or deprecate in favor of raw Typst?
#'
#' @name zzt2f-preamble
NULL

#' Language directive for Typst (parallel to \code{babel()})
#'
#' @param language Character. An ISO 639 language code (e.g.
#'   \code{"en"}, \code{"de"}, \code{"fr"}).
#' @return Character string \code{"#set text(lang: \"<code>\")"}.
#' @export
zzt2f_textlang <- function(language) {
  if (!is.character(language) || length(language) != 1L ||
      !nzchar(language)) {
    stop(
      "`language` must be a single non-empty character string.",
      call. = FALSE
    )
  }
  sprintf('#set text(lang: "%s")', language)
}

#' Font directive for Typst (parallel to \code{fontspec()})
#'
#' @param main_font Character or NULL. Typst font family for body
#'   text.
#' @param mono_font Character or NULL. Font for raw / code blocks.
#' @param sans_font Ignored; Typst has no sans-specific setter. The
#'   argument is retained for API symmetry with \code{fontspec()};
#'   users who need separate sans handling should write a
#'   \code{#show} rule.
#' @return Character vector of Typst directives.
#' @export
zzt2f_font <- function(main_font = NULL,
                       mono_font = NULL,
                       sans_font = NULL) {
  out <- character(0)
  if (!is.null(main_font)) {
    out <- c(out, sprintf('#set text(font: "%s")', main_font))
  }
  if (!is.null(mono_font)) {
    out <- c(
      out,
      sprintf('#show raw: set text(font: "%s")', mono_font)
    )
  }
  if (length(out) == 0L) {
    message(
      "zzt2f_font() called with no font specified; returning ",
      "empty vector."
    )
  }
  out
}

#' Page directive for Typst (parallel to \code{geometry()})
#'
#' @param margin Character or NULL. A Typst length
#'   (\code{"2cm"}) or a named list like
#'   \code{list(x = "2cm", y = "1.5cm")} for horizontal / vertical
#'   margins, or \code{list(top = ..., bottom = ..., left = ...,
#'   right = ...)} for a full specification.
#' @param paper Character or NULL. Typst paper code (e.g.
#'   \code{"a4"}, \code{"us-letter"}).
#' @param landscape Logical. Emit \code{flipped: true}.
#' @param width Character or NULL. Typst length, e.g. \code{"auto"}.
#' @param height Character or NULL.
#' @return Character scalar Typst \code{#set page(...)} directive.
#' @export
zzt2f_page <- function(margin = NULL, paper = NULL,
                       landscape = FALSE,
                       width = NULL, height = NULL) {
  parts <- character(0)
  if (!is.null(paper)) {
    parts <- c(parts, sprintf('paper: "%s"', paper))
  }
  if (isTRUE(landscape)) {
    parts <- c(parts, "flipped: true")
  }
  if (!is.null(width)) {
    parts <- c(parts, sprintf("width: %s", width))
  }
  if (!is.null(height)) {
    parts <- c(parts, sprintf("height: %s", height))
  }
  if (!is.null(margin)) {
    parts <- c(parts, paste0("margin: ", fmt_margin(margin)))
  }
  if (length(parts) == 0L) {
    return("#set page()")
  }
  paste0("#set page(", paste(parts, collapse = ", "), ")")
}

#' Format a margin argument as a Typst expression
#' @param margin Character or named list.
#' @return Character scalar.
#' @keywords internal
fmt_margin <- function(margin) {
  if (is.character(margin) && length(margin) == 1L) return(margin)
  if (is.list(margin)) {
    nm <- names(margin)
    if (is.null(nm) || any(!nzchar(nm))) {
      stop(
        "`margin` list must be fully named (e.g., ",
        "list(x = \"2cm\", y = \"1.5cm\")).",
        call. = FALSE
      )
    }
    items <- vapply(nm, function(k) {
      sprintf("%s: %s", k, margin[[k]])
    }, character(1L))
    return(paste0("(", paste(items, collapse = ", "), ")"))
  }
  stop(
    "`margin` must be a character length 1 or a named list.",
    call. = FALSE
  )
}
