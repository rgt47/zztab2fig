#' References and Notes for zzt2f Tables
#'
#' @description Footnote, cell-mark, and cross-reference helpers for
#'   the Typst backend. Maps LaTeX-style conventions
#'   (\code{threeparttable}, \code{\\textsuperscript{}}, \code{\\ref{}})
#'   to Typst primitives (\code{#footnote}, \code{#super[]},
#'   \code{@label}).
#'
#' @name zzt2f-refs
NULL

#' Table footnotes (Typst backend)
#'
#' @description Thin constructor that delegates to
#'   \code{t2f_footnote()}. The resulting \code{t2f_footnote} object
#'   is already consumed by \code{zzt2f()} via the internal
#'   \code{translate_footnote()} helper, which emits Typst notes.
#'
#' @inheritParams t2f_footnote
#' @return A \code{t2f_footnote} object.
#' @examples
#' \dontrun{
#' fn <- zzt2f_footnote(
#'   general = "Data from 2024 survey.",
#'   symbol = c("p < 0.05", "p < 0.01")
#' )
#' zzt2f(df, footnote = fn)
#' }
#' @export
zzt2f_footnote <- function(general = NULL,
                           number = NULL,
                           alphabet = NULL,
                           symbol = NULL,
                           title_general = NULL,
                           title_number = NULL,
                           title_alphabet = NULL,
                           title_symbol = NULL,
                           footnote_as_chunk = FALSE,
                           threeparttable = TRUE) {
  t2f_footnote(
    general = general,
    number = number,
    alphabet = alphabet,
    symbol = symbol,
    title_general = title_general,
    title_number = title_number,
    title_alphabet = title_alphabet,
    title_symbol = title_symbol,
    footnote_as_chunk = footnote_as_chunk,
    threeparttable = threeparttable
  )
}

#' Footnote marker for Typst cell content
#'
#' @description Append a superscript footnote marker to a cell value
#'   using Typst's \code{super()} function. Parallel to
#'   \code{t2f_mark()} which emits \code{\\textsuperscript{}}.
#'
#' @param text Character. Cell text to decorate.
#' @param mark Integer. Index into the selected marker family.
#' @param type One of \code{"symbol"}, \code{"number"},
#'   \code{"alphabet"}.
#' @return Character string with embedded Typst superscript.
#' @examples
#' \dontrun{
#' df$value[1] <- zzt2f_mark("23.5", 1, "symbol")
#' }
#' @export
zzt2f_mark <- function(text, mark,
                       type = c("symbol", "number", "alphabet")) {
  type <- match.arg(type)
  if (!is.character(text) || length(text) != 1L) {
    stop("`text` must be a single character string.", call. = FALSE)
  }
  if (!is.numeric(mark) || length(mark) != 1L || mark < 1L) {
    stop("`mark` must be a positive integer.", call. = FALSE)
  }
  mark <- as.integer(mark)

  symbols <- c("*", "\u2020", "\u2021", "\u00A7", "\u00B6")
  marker <- switch(
    type,
    symbol   = if (mark <= length(symbols)) symbols[mark]
               else as.character(mark),
    number   = as.character(mark),
    alphabet = letters[mark]
  )
  paste0(text, "#super[", marker, "]")
}

#' Cross-reference to a labeled table (Typst backend)
#'
#' @description Construct a Typst reference string for a labeled
#'   element. The returned string can be pasted into surrounding
#'   prose in a \code{.typ} document. Typst has no direct analog of
#'   LaTeX's \code{\\pageref} or \code{\\nameref}; those LaTeX-only
#'   types are not supported here.
#'
#' @param label Character. The label name, without angle brackets.
#' @param supplement Character or NULL. Optional supplement text
#'   overriding Typst's default (e.g., "Table", "Figure").
#' @param cat Logical. If TRUE (default), print the string via
#'   \code{cat()} for inline use in R Markdown; otherwise return it.
#' @return Character string of the form \code{@label} (or with a
#'   supplement, \code{#ref(<label>, supplement: [Table])}).
#' @examples
#' \dontrun{
#' zzt2f_ref("tab-demographics", cat = FALSE)
#' }
#' @export
zzt2f_ref <- function(label, supplement = NULL, cat = TRUE) {
  if (!is.character(label) || length(label) != 1L || !nzchar(label)) {
    stop(
      "`label` must be a single non-empty character string.",
      call. = FALSE
    )
  }
  result <- if (is.null(supplement)) {
    paste0("@", label)
  } else {
    sprintf("#ref(<%s>, supplement: [%s])", label, supplement)
  }
  if (isTRUE(cat)) {
    cat(result)
    invisible(result)
  } else {
    result
  }
}
