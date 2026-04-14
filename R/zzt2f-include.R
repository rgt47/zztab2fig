#' Typst Figure-Inclusion Helpers
#'
#' @description Emit Typst source fragments that embed a rendered
#'   table image (typically from a prior \code{zzt2f()} call) into a
#'   surrounding \code{.typ} document. Parallel in purpose to the
#'   \code{t2f_include*} family but using Typst primitives
#'   (\code{#figure}, \code{#image}, \code{#grid}, \code{#place}).
#'
#' @details
#' Three semantic gaps between the LaTeX and Typst inclusion models
#' are flagged here:
#' \itemize{
#'   \item \code{wrapfigure} (text wrapping around a figure) has no
#'     direct Typst equivalent. \code{zzt2f_include_wrap()} emits a
#'     \code{#place(..., float: true)} approximation; text does not
#'     literally wrap.
#'   \item \code{marginfigure} / \code{\\marginpar} are approximated
#'     via \code{#place(right, dx: 100%, ...)}. This works inside a
#'     \code{#set page(margin: (right: ...))} block; users must
#'     arrange the page layout themselves.
#'   \item LaTeX float placement specifiers (\code{htbp}) have no
#'     clean Typst analog. The \code{position} argument is accepted
#'     for API symmetry but ignored.
#' }
#'
#' @name zzt2f-include
NULL

#' Resolve a Typst image path
#'
#' @param path Character. Input path, with or without extension.
#' @return Character path ending in \code{.pdf} (Typst can embed PDF
#'   directly). Unlike \code{resolve_pdf_path()}, no \code{_cropped}
#'   suffix is added, because \code{zzt2f()} emits already-sized
#'   Typst output.
#' @keywords internal
resolve_typst_path <- function(path) {
  path <- sub("\\.(pdf|png|svg)$", "", path)
  paste0(path, ".pdf")
}

#' Translate a LaTeX width spec to a Typst width
#'
#' @param width Character. A LaTeX-style width such as
#'   \code{"\\textwidth"}, \code{"0.8\\textwidth"}, or a plain Typst
#'   width like \code{"80%"} or \code{"5cm"}.
#' @return Character. A Typst width expression.
#' @keywords internal
translate_width <- function(width) {
  if (is.null(width) || identical(width, "")) return("100%")
  if (identical(width, "\\textwidth")) return("100%")
  if (grepl("\\\\textwidth$", width)) {
    num <- sub("\\\\textwidth$", "", width)
    if (!nzchar(num)) num <- "1"
    if (grepl("^[0-9.]+$", num)) {
      pct <- round(as.numeric(num) * 100, 2)
      return(paste0(pct, "%"))
    }
  }
  width
}

#' Finalize a Typst emission helper
#' @keywords internal
emit_typst <- function(result, cat) {
  if (isTRUE(cat)) {
    cat(result, "\n")
    invisible(result)
  } else {
    result
  }
}

#' Include a rendered table as a Typst figure
#'
#' @param path Path to the image file (with or without extension).
#' @param caption Character or NULL.
#' @param label Character or NULL. Typst label (no angle brackets).
#' @param position Ignored; retained for API symmetry with
#'   \code{t2f_include()}.
#' @param width Width spec; LaTeX \code{\\textwidth} forms are
#'   translated to percentages.
#' @param center Logical. Emit inside an \code{#align(center)[...]}
#'   block.
#' @param short_caption Ignored; Typst has no short-caption concept
#'   in \code{#figure}.
#' @param cat Logical. Print with \code{cat()} if TRUE.
#' @return Character; printed when \code{cat = TRUE}.
#' @examples
#' \dontrun{
#' zzt2f_include("figures/mytab", caption = "Demo.", label = "tab-demo",
#'               cat = FALSE)
#' }
#' @export
zzt2f_include <- function(path,
                          caption = NULL,
                          label = NULL,
                          position = NULL,
                          width = "\\textwidth",
                          center = TRUE,
                          short_caption = NULL,
                          cat = TRUE) {
  typ_path <- resolve_typst_path(path)
  w <- translate_width(width)

  img <- sprintf('image("%s", width: %s)', typ_path, w)
  body <- if (is.null(caption)) {
    sprintf("#figure(%s)", img)
  } else {
    sprintf("#figure(%s, caption: [%s])", img, caption)
  }
  if (!is.null(label)) {
    body <- paste0(body, " <", label, ">")
  }
  if (isTRUE(center)) {
    body <- sprintf("#align(center)[%s]", body)
  }
  emit_typst(body, cat)
}

#' Include a rendered table inline (no figure wrapper)
#'
#' @param path Path to the image file.
#' @param width Width spec.
#' @param center Logical.
#' @param vspace Character or NULL. Typst length, e.g. \code{"1em"};
#'   inserted as \code{#v(length)} before and after.
#' @param cat Logical.
#' @return Character; printed when \code{cat = TRUE}.
#' @examples
#' \dontrun{
#' zzt2f_include_inline("figures/mytab", width = "0.9\\textwidth",
#'                       cat = FALSE)
#' }
#' @export
zzt2f_include_inline <- function(path,
                                 width = "\\textwidth",
                                 center = TRUE,
                                 vspace = NULL,
                                 cat = TRUE) {
  typ_path <- resolve_typst_path(path)
  w <- translate_width(width)
  img <- sprintf('#image("%s", width: %s)', typ_path, w)
  if (isTRUE(center)) {
    img <- sprintf("#align(center)[%s]", img)
  }
  parts <- character(0)
  if (!is.null(vspace)) parts <- c(parts, sprintf("#v(%s)", vspace))
  parts <- c(parts, img)
  if (!is.null(vspace)) parts <- c(parts, sprintf("#v(%s)", vspace))
  emit_typst(paste(parts, collapse = "\n"), cat)
}

#' Include a rendered table with text flowing around it (approximation)
#'
#' @description Typst has no direct \code{wrapfigure}; this emits a
#'   \code{#place(auto, float: true, ...)} block that floats the
#'   figure to the requested side. Text does not literally wrap
#'   around the figure in the LaTeX sense.
#'
#' @param path Path to the image file.
#' @param placement \code{"r"}, \code{"l"}, or their long forms
#'   \code{"right"}, \code{"left"}.
#' @param wrap_width Character. Typst or LaTeX width; translated.
#' @param width Character or NULL. Defaults to \code{wrap_width}.
#' @param caption Character or NULL.
#' @param label Character or NULL.
#' @param cat Logical.
#' @return Character; printed when \code{cat = TRUE}.
#' @export
zzt2f_include_wrap <- function(path,
                               placement = c("r", "l",
                                             "right", "left"),
                               wrap_width = "0.5\\textwidth",
                               width = NULL,
                               caption = NULL,
                               label = NULL,
                               cat = TRUE) {
  placement <- match.arg(placement)
  side <- if (placement %in% c("r", "right")) "right" else "left"
  if (is.null(width)) width <- wrap_width
  typ_path <- resolve_typst_path(path)
  w <- translate_width(width)

  img <- sprintf('image("%s", width: %s)', typ_path, w)
  inner <- if (is.null(caption)) {
    sprintf("figure(%s)", img)
  } else {
    sprintf("figure(%s, caption: [%s])", img, caption)
  }
  body <- sprintf("#place(%s, float: true, %s)", side, inner)
  if (!is.null(label)) {
    body <- paste0(body, " <", label, ">")
  }
  emit_typst(body, cat)
}

#' Include two rendered tables side by side
#'
#' @param path1 First image path.
#' @param path2 Second image path.
#' @param caption1 Caption for the first figure.
#' @param caption2 Caption for the second figure.
#' @param label1 Label for the first figure.
#' @param label2 Label for the second figure.
#' @param width1 Width of the first column (translated).
#' @param width2 Width of the second column (translated).
#' @param position Ignored; retained for API symmetry.
#' @param main_caption Outer caption around the grid.
#' @param main_label Outer label.
#' @param cat Logical.
#' @return Character; printed when \code{cat = TRUE}.
#' @export
zzt2f_include_sidebyside <- function(path1, path2,
                                     caption1 = NULL,
                                     caption2 = NULL,
                                     label1 = NULL,
                                     label2 = NULL,
                                     width1 = "0.48\\textwidth",
                                     width2 = "0.48\\textwidth",
                                     position = NULL,
                                     main_caption = NULL,
                                     main_label = NULL,
                                     cat = TRUE) {
  make_cell <- function(p, cap, lab, wd) {
    w <- translate_width(wd)
    img <- sprintf('image("%s", width: 100%%)', resolve_typst_path(p))
    fig <- if (is.null(cap)) {
      sprintf("figure(%s)", img)
    } else {
      sprintf("figure(%s, caption: [%s])", img, cap)
    }
    if (!is.null(lab)) fig <- paste0(fig, " <", lab, ">")
    list(fig = fig, width = w)
  }
  a <- make_cell(path1, caption1, label1, width1)
  b <- make_cell(path2, caption2, label2, width2)
  grid_block <- sprintf(
    "#grid(columns: (%s, %s), column-gutter: 1em,\n  %s,\n  %s\n)",
    a$width, b$width, a$fig, b$fig
  )
  body <- if (is.null(main_caption)) {
    grid_block
  } else {
    sprintf(
      "#figure(%s, caption: [%s])",
      sub("^#", "", grid_block), main_caption
    )
  }
  if (!is.null(main_label)) body <- paste0(body, " <", main_label, ">")
  emit_typst(body, cat)
}

#' Include a rendered table in the page margin (approximation)
#'
#' @description Emits \code{#place(right, dx: ...)[...]} which floats
#'   the figure toward the page margin. True marginfigure semantics
#'   (automatic margin-parallel placement) require the document to
#'   reserve margin space via \code{#set page(margin: (right: ...))}.
#'
#' @param path Path to the image file.
#' @param caption Character or NULL.
#' @param label Character or NULL.
#' @param width Width spec.
#' @param offset Character. Typst length for horizontal offset; use
#'   \code{"100%"} to push into a reserved right margin. Default
#'   \code{"100%"}.
#' @param method Ignored for Typst; retained for API symmetry with
#'   \code{t2f_include_margin()}.
#' @param cat Logical.
#' @return Character; printed when \code{cat = TRUE}.
#' @export
zzt2f_include_margin <- function(path,
                                 caption = NULL,
                                 label = NULL,
                                 width = "4cm",
                                 offset = "100%",
                                 method = NULL,
                                 cat = TRUE) {
  typ_path <- resolve_typst_path(path)
  w <- translate_width(width)
  img <- sprintf('image("%s", width: %s)', typ_path, w)
  inner <- if (is.null(caption)) {
    sprintf("figure(%s)", img)
  } else {
    sprintf("figure(%s, caption: [%s])", img, caption)
  }
  body <- sprintf("#place(right, dx: %s, %s)", offset, inner)
  if (!is.null(label)) body <- paste0(body, " <", label, ">")
  emit_typst(body, cat)
}

#' Margin-figure preamble packages (Typst: none required)
#'
#' @description Typst handles margin placement via native
#'   \code{#place()} and \code{#set page()} directives; no analog to
#'   LaTeX's \code{sidenotes} / \code{marginnote} packages. Returns
#'   NULL invisibly and emits a message noting this.
#'
#' @param method Retained for API symmetry.
#' @return NULL (invisible).
#' @export
zzt2f_margin_packages <- function(method = NULL) {
  message(
    "Typst requires no margin packages; use ",
    "`#set page(margin: (right: <length>))` and ",
    "`zzt2f_include_margin()`."
  )
  invisible(NULL)
}
