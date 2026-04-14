#' Numeric Alignment for the Typst Backend
#'
#' @description Typst approximation of \code{siunitx}'s
#'   decimal-aligned columns via the \code{metro} community package
#'   (\url{https://typst.app/universe/package/metro}). Emits a
#'   Typst import directive and a \code{zzt2f_siunitx} spec that can
#'   be recognized downstream for column-level number formatting.
#'
#' @details
#' \code{metro} supports \code{#qty} and \code{#num} functions that
#' format numeric values with unit-aware spacing and padded decimal
#' alignment. It does \strong{not} cover every \code{siunitx}
#' option; notable gaps include per-row rounding modes beyond
#' \code{places} / \code{figures}, bracket/parenthesis wrapping of
#' uncertainties, and the full range of \code{round-mode} behaviors.
#'
#' @name zzt2f-siunitx
NULL

#' Build a Typst \code{siunitx}-analog specification
#'
#' @param table_format Character. Analogous to siunitx
#'   \code{table-format} (e.g., \code{"3.2"}). Used to compute
#'   integer-side and decimal-side padding widths.
#' @param round_mode One of \code{"none"}, \code{"places"},
#'   \code{"figures"}.
#' @param round_precision Integer or NULL.
#' @param group_separator Character or NULL.
#' @return A \code{zzt2f_siunitx} object (character directive lines
#'   with a \code{table_format} attribute).
#' @examples
#' \dontrun{
#' spec <- zzt2f_siunitx(table_format = "2.3", round_mode = "places",
#'                        round_precision = 3)
#' cat(unclass(spec), sep = "\n")
#' }
#' @export
zzt2f_siunitx <- function(table_format = "3.2",
                          round_mode = c("none", "places",
                                         "figures"),
                          round_precision = NULL,
                          group_separator = NULL) {
  round_mode <- match.arg(round_mode)
  if (!grepl("^[0-9]+\\.[0-9]+$", table_format)) {
    stop(
      "`table_format` must be \"<int>.<dec>\" (e.g., \"3.2\").",
      call. = FALSE
    )
  }
  if (identical(round_mode, "figures") &&
      is.null(round_precision)) {
    stop(
      "round_mode = \"figures\" requires `round_precision`.",
      call. = FALSE
    )
  }

  preamble <- c(
    '#import "@preview/metro:0.3.0": *'
  )
  if (!is.null(group_separator)) {
    preamble <- c(
      preamble,
      sprintf(
        '#metro-setup(group-separator: "%s")',
        group_separator
      )
    )
  }
  if (!identical(round_mode, "none") &&
      !is.null(round_precision)) {
    preamble <- c(
      preamble,
      sprintf(
        '#metro-setup(round-mode: "%s", round-precision: %d)',
        round_mode, as.integer(round_precision)
      )
    )
  }

  structure(
    preamble,
    class = c("zzt2f_siunitx", "character"),
    table_format = table_format,
    round_mode = round_mode,
    round_precision = round_precision,
    group_separator = group_separator
  )
}

#' Print method for zzt2f_siunitx
#' @param x A \code{zzt2f_siunitx} object.
#' @param ... Ignored.
#' @return Invisibly \code{x}.
#' @export
print.zzt2f_siunitx <- function(x, ...) {
  cat("zzt2f_siunitx (Typst metro adapter):\n")
  cat("  table_format:    ", attr(x, "table_format"), "\n",
      sep = "")
  cat("  round_mode:      ", attr(x, "round_mode"), "\n",
      sep = "")
  if (!is.null(attr(x, "round_precision"))) {
    cat("  round_precision: ",
        attr(x, "round_precision"), "\n", sep = "")
  }
  if (!is.null(attr(x, "group_separator"))) {
    cat("  group_separator: \"",
        attr(x, "group_separator"), "\"\n", sep = "")
  }
  cat("Preamble directives:\n")
  cat(paste0("  ", unclass(x)), sep = "\n")
  invisible(x)
}
