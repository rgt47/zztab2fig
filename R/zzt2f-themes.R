#' Theme Translation for Typst Backend
#'
#' @description Translates t2f theme objects and LaTeX styling parameters
#'   into Typst-compatible values for use with tinytable.
#'
#' @name zzt2f-themes
#' @keywords internal
NULL

#' Resolve and translate theme for Typst backend
#'
#' @description Takes a theme argument (NULL, character, or t2f_theme object),
#'   resolves it via the existing theme system, then translates LaTeX-specific
#'   fields to Typst-compatible values.
#'
#' @param theme Theme argument from zzt2f() call.
#' @param scolor User-provided scolor override (NULL to use theme default).
#' @return A list with Typst-compatible theme settings.
#' @keywords internal
resolve_typst_theme <- function(theme, scolor = NULL) {
  resolved <- resolve_theme(theme)
  settings <- apply_theme_settings(resolved, scolor = scolor)

  use_stripes <- settings$striped || !is.null(scolor)

  list(
    stripe_color = if (use_stripes) {
      translate_latex_color(settings$scolor)
    } else {
      NULL
    },
    header_bold = settings$header_bold,
    font_size = translate_font_size(settings$font_size),
    striped = use_stripes
  )
}

#' Translate LaTeX color specification to hex
#'
#' @description Converts LaTeX color specs (e.g., "blue!10", "nejmshade",
#'   "#FF0000") to hex color strings suitable for Typst/tinytable.
#'
#' @param color Character string. A LaTeX color specification.
#' @return Character string with hex color (e.g., "#E6E6FF").
#' @keywords internal
translate_latex_color <- function(color) {
  if (is.null(color)) return(NULL)

  if (grepl("^#[0-9A-Fa-f]{6}$", color)) return(toupper(color))

  custom_colors <- c(
    nejmshade = "#FEF8EA"
  )
  if (tolower(color) %in% names(custom_colors)) {
    return(custom_colors[[tolower(color)]])
  }

  if (color == "white") return("#FFFFFF")

  latex_base_colors <- c(
    red     = "#FF0000",
    blue    = "#0000FF",
    green   = "#00FF00",
    gray    = "#808080",
    grey    = "#808080",
    black   = "#000000",
    cyan    = "#00FFFF",
    magenta = "#FF00FF",
    yellow  = "#FFFF00"
  )

  if (grepl("!\\d+$", color)) {
    parts <- strsplit(color, "!")[[1]]
    color_name <- tolower(parts[1])
    pct <- as.numeric(parts[2])

    if (color_name %in% names(custom_colors)) {
      base_hex <- custom_colors[[color_name]]
    } else if (color_name %in% names(latex_base_colors)) {
      base_hex <- latex_base_colors[[color_name]]
    } else {
      warning(
        "Unknown LaTeX color '", color_name,
        "', using gray as fallback.",
        call. = FALSE
      )
      base_hex <- "#808080"
    }

    rgb_base <- grDevices::col2rgb(base_hex)[, 1]
    rgb_result <- round(255 + (rgb_base - 255) * (pct / 100))
    rgb_result <- pmin(pmax(rgb_result, 0), 255)
    return(sprintf("#%02X%02X%02X", rgb_result[1], rgb_result[2], rgb_result[3]))
  }

  if (tolower(color) %in% names(latex_base_colors)) {
    return(latex_base_colors[[tolower(color)]])
  }

  warning(
    "Unrecognized color '", color, "', using gray as fallback.",
    call. = FALSE
  )
  "#808080"
}

#' Translate LaTeX font size commands to numeric points
#'
#' @description Maps LaTeX font size commands to approximate point sizes
#'   for use with Typst.
#'
#' @param latex_size Character string or NULL. A LaTeX size command name
#'   (e.g., "footnotesize", "small").
#' @return Numeric point size, or NULL if input is NULL.
#' @keywords internal
translate_font_size <- function(latex_size) {
  if (is.null(latex_size)) return(NULL)

  size_map <- c(
    tiny         = 5,
    scriptsize   = 7,
    footnotesize = 8,
    small        = 9,
    normalsize   = 10,
    large        = 12,
    Large        = 14,
    LARGE        = 17,
    huge         = 20,
    Huge         = 25
  )

  if (latex_size %in% names(size_map)) {
    return(unname(size_map[latex_size]))
  }

  if (grepl("^\\d+(\\.\\d+)?$", latex_size)) {
    return(as.numeric(latex_size))
  }

  warning(
    "Unknown LaTeX font size '", latex_size,
    "', using 10pt as fallback.",
    call. = FALSE
  )
  10
}

#' Translate t2f_footnote to tinytable notes
#'
#' @description Converts a t2f_footnote object into a character vector
#'   suitable for `tinytable::tt(notes=)`.
#'
#' @param footnote A t2f_footnote object or NULL.
#' @return Character vector of footnote strings, or NULL.
#' @keywords internal
translate_footnote <- function(footnote) {
  if (is.null(footnote)) return(NULL)
  if (!inherits(footnote, "t2f_footnote")) {
    stop("`footnote` must be a t2f_footnote object or NULL.", call. = FALSE)
  }

  notes <- character(0)

  if (!is.null(footnote$general)) {
    notes <- c(notes, footnote$general)
  }

  if (!is.null(footnote$number)) {
    numbered <- paste0(
      seq_along(footnote$number), ". ", footnote$number
    )
    notes <- c(notes, numbered)
  }

  if (!is.null(footnote$alphabet)) {
    lettered <- paste0(
      letters[seq_along(footnote$alphabet)], ". ", footnote$alphabet
    )
    notes <- c(notes, lettered)
  }

  if (!is.null(footnote$symbol)) {
    symbols <- c("*", "\u2020", "\u2021", "\u00A7", "\u00B6")
    sym_notes <- vapply(seq_along(footnote$symbol), function(i) {
      sym <- if (i <= length(symbols)) symbols[i] else paste0("(", i, ")")
      paste0(sym, " ", footnote$symbol[i])
    }, character(1))
    notes <- c(notes, sym_notes)
  }

  if (length(notes) == 0) return(NULL)
  vapply(notes, escape_typst_content, character(1), USE.NAMES = FALSE)
}

#' Escape Typst content-mode special characters
#'
#' @description Escapes characters that have special meaning in Typst
#'   content mode (inside \code{[...]} blocks), such as \code{*}, \code{_},
#'   \code{<}, \code{>}, \code{@}, \code{#}, and \code{$}.
#'
#' @param x Character string.
#' @return Escaped character string safe for Typst content.
#' @keywords internal
escape_typst_content <- function(x) {
  x <- gsub("\\\\", "\\\\\\\\", x)
  x <- gsub("#", "\\\\#", x, fixed = TRUE)
  x <- gsub("\\$", "\\\\$", x)
  x <- gsub("\\*", "\\\\*", x)
  x <- gsub("_", "\\\\_", x, fixed = TRUE)
  x <- gsub("<", "\\\\<", x, fixed = TRUE)
  x <- gsub(">", "\\\\>", x, fixed = TRUE)
  x <- gsub("@", "\\\\@", x, fixed = TRUE)
  x <- gsub("`", "\\\\`", x, fixed = TRUE)
  x
}

#' Translate t2f_header to tinytable group_tt spec
#'
#' @description Converts a t2f_header object (or list of them) into a named
#'   list suitable for `tinytable::group_tt(j=)`.
#'
#' @param header_above A t2f_header object, list of t2f_header objects, or
#'   NULL.
#' @return A named list mapping group labels to column index ranges, or NULL.
#' @keywords internal
translate_header_above <- function(header_above) {
  if (is.null(header_above)) return(NULL)

  if (inherits(header_above, "t2f_header")) {
    header_above <- list(header_above)
  }

  result <- list()

  for (hdr in header_above) {
    if (!inherits(hdr, "t2f_header")) next

    spans <- hdr$header
    labels <- names(spans)
    col_pos <- 1L
    j_spec <- list()

    for (i in seq_along(spans)) {
      span <- unname(spans[i])
      label <- labels[i]

      if (trimws(label) != "" && trimws(label) != " ") {
        j_spec[[label]] <- col_pos:(col_pos + span - 1L)
      }
      col_pos <- col_pos + span
    }

    result <- c(result, list(j_spec))
  }

  if (length(result) == 1) return(result[[1]])
  result
}
