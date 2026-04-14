# zzt2f Helper Migration Map

This document enumerates each `t2f_*` helper in the LaTeX pipeline
and describes the corresponding `zzt2f_*` helper planned for the
Typst pipeline. The intent is to provide a review surface: for each
row, decide whether the helper should exist in both frameworks,
only one, or be dropped.

## API conventions (hybrid)

- **Spec-object helpers.** Each `zzt2f_*` helper returns a small
  S3 spec object (e.g. `zzt2f_format`, `zzt2f_footnote`) that is
  passed to `zzt2f()` via a named parameter. This mirrors the
  `t2f_footnote` / `t2f_header_above` idiom already present.
- **Source-level escape hatch.** `zzt2f()` gains a
  `compile = FALSE` mode that returns the raw `.typ` source as a
  character vector. Power users may apply arbitrary transforms
  and pass the result to a new `zzt2f_compile()` to render.
- **Post-processing.** Spec objects are consumed inside
  `zzt2f_internal()` at two sites: (a) via `tinytable::style_tt()`
  before `save_tt()` for cell-level styling, and (b) appended to
  `opts` in `postprocess_typst()` for source-level directives.

## Mapping table

Status legend: *port* = planned for Batch; *done* = already
present in `zzt2f.R`; *skip* = intentionally not ported (reason
noted); *review* = design question flagged for user decision.

### Batch A — styling (6 helpers)

| `t2f_*`           | `zzt2f_*` counterpart | Mechanism                                              | Notes                                              |
|-------------------|-----------------------|--------------------------------------------------------|----------------------------------------------------|
| `t2f_format`      | `zzt2f_format`        | `tinytable::style_tt(i, j, bold, italic, color, background)` | Condition function applied at spec-consumption. |
| `t2f_bold_col`    | `zzt2f_bold_col`      | `style_tt(j = cols, bold = TRUE)`                      | Thin wrapper over `zzt2f_format`.                  |
| `t2f_italic_col`  | `zzt2f_italic_col`    | `style_tt(j = cols, italic = TRUE)`                    | Thin wrapper.                                      |
| `t2f_color_row`   | `zzt2f_color_row`     | `style_tt(i = rows, background = hex)`                 | LaTeX color names translated to hex via existing `translate_latex_color()`. |
| `t2f_highlight`   | `zzt2f_highlight`     | `style_tt(i = which(condition), ...)`                  | Condition evaluated against coerced character cells. |
| `t2f_decimal`     | `zzt2f_decimal`       | `tinytable::format_tt(digits, num_fmt)`                | Typst has no `siunitx`; decimal alignment via padding. |

### Batch B — structure (2 helpers)

| `t2f_*`            | `zzt2f_*`             | Mechanism                                              | Notes                                              |
|--------------------|-----------------------|--------------------------------------------------------|----------------------------------------------------|
| `t2f_header_above` | already via `header_above =` argument; add `zzt2f_header_above()` constructor that parallels `t2f_header_above()` | `tinytable::group_tt(j = spec)` | `zzt2f()` already accepts a `t2f_header` object. Add `zzt2f_header_above()` so naming is consistent in the Typst pipeline; it may simply delegate to `t2f_header_above()` since the spec is backend-agnostic. |
| `t2f_collapse_rows`| `zzt2f_collapse_rows` | `style_tt(i, j, rowspan = ...)` or Typst `table.cell(rowspan:)` | tinytable has no direct rowspan API; implement via post-processing of `.typ` source. |

### Batch C — references and notes (3 helpers)

| `t2f_*`        | `zzt2f_*`        | Mechanism                                | Notes                                         |
|----------------|------------------|------------------------------------------|-----------------------------------------------|
| `t2f_footnote` | already consumed by `zzt2f()` via `footnote =`; add `zzt2f_footnote()` constructor as a naming-consistent alias. | `translate_footnote()` already emits Typst `notes`. | Existing mechanism; just add a consistent constructor name. |
| `t2f_mark`     | `zzt2f_mark`     | Typst `#super[*]` / `#super[1]` text markers in cell content. | No `\textsuperscript` in Typst; use `super()` function. |
| `t2f_ref`      | `zzt2f_ref`      | Typst `<label>` + `@label` cross-reference. | Returns a character string wrapped for Typst ref syntax. |

### Batch D — figure inclusion (6 helpers)

These generate LaTeX source fragments (`\includegraphics{...}`,
`\begin{figure}`, `\begin{wrapfigure}`, `\begin{marginfigure}`)
that embed a rendered PDF into a host document. In the Typst
pipeline the natural analog is different: users typically embed
PDFs via `#image("file.pdf")` inside `#figure()`, with layout
controlled by `#place()` and `#grid()`. The mapping is therefore
conceptual rather than textual.

| `t2f_*`                    | `zzt2f_*`                   | Mechanism                                           | Notes / caveats                                                 |
|----------------------------|-----------------------------|-----------------------------------------------------|-----------------------------------------------------------------|
| `t2f_include`              | `zzt2f_include`             | Emits `#figure(image("path"), caption: [...]) <label>` | Output is Typst source; user pastes into a `.typ` document.   |
| `t2f_include_inline`       | `zzt2f_include_inline`      | Emits bare `#image("path")`                         | No caption/float wrapping.                                      |
| `t2f_include_margin`       | `zzt2f_include_margin`      | Emits `#place(right, dx: ...)` or a margin-note idiom | Typst has no direct `marginfigure`; approximated via `place(float: true, right + top)`. Flag for review: accept the approximation or drop? |
| `t2f_include_sidebyside`   | `zzt2f_include_sidebyside`  | Emits `#grid(columns: 2, ...)`                      | Clean mapping.                                                  |
| `t2f_include_wrap`         | `zzt2f_include_wrap`        | Emits `#place(auto, float: true, ...)`              | Typst's float semantics differ from `wrapfig`; text does not literally wrap around the figure the way `wrapfig` does. Flag for review. |
| `t2f_margin_packages`      | skip (LaTeX-only)           | —                                                   | Concept is LaTeX preamble package loading; no Typst analog.    |

### Batch E — batch and engine (4 helpers)

| `t2f_*`                    | `zzt2f_*`                  | Mechanism                                                            | Notes                                                |
|----------------------------|----------------------------|----------------------------------------------------------------------|------------------------------------------------------|
| `t2f_batch`                | `zzt2f_batch`              | Iterates over a list of data frames, calling `zzt2f()` on each.      | Near-identical to `t2f_batch`.                       |
| `t2f_batch_advanced`       | `zzt2f_batch_advanced`     | Parallel batch with per-item theme/caption overrides via `future.apply`. | Same structure; Typst CLI is process-based so parallelism is safe. |
| `t2f_batch_spec`           | `zzt2f_batch_spec`         | Spec-object constructor for batch entries.                           | Trivial port.                                        |
| `t2f_inline`               | `zzt2f_inline`             | Generate and return inline image path for use in R Markdown.         | Returns PDF/PNG path from a single zzt2f call.      |
| `register_t2f_engine`      | `register_zzt2f_engine`    | Register a custom knitr engine for Typst-rendered chunks.            | Engine name `zzt2f`.                                 |

### Batch F — stat helpers (3 helpers)

| `t2f_*`           | `zzt2f_*`          | Mechanism                                         | Notes                                   |
|-------------------|--------------------|---------------------------------------------------|-----------------------------------------|
| `t2f_tidy`        | `zzt2f_tidy`       | `broom::tidy()` → data frame → `zzt2f()`.         | Trivial port.                           |
| `t2f_coef`        | `zzt2f_coef`       | Extract coefficients → `zzt2f()`.                 | Backend-agnostic logic; render tail swaps. |
| `t2f_rms_compare` | `zzt2f_rms_compare`| `rms::compareAnova()` side-by-side regression table. | Trivial port.                        |

### Batch G — page setup (3 helpers, *review*)

LaTeX preamble emitters. Typst users normally write
`#set text(font: ...)`, `#set page(margin: ...)`, etc. directly
in the `.typ` document preamble. These helpers may still be
useful for programmatic generation of the preamble, but their
role is different. Flag for user review: keep, drop, or
redesign.

| `t2f_*`      | `zzt2f_*`         | Mechanism                                              | Notes                                                |
|--------------|-------------------|--------------------------------------------------------|------------------------------------------------------|
| `babel`      | `zzt2f_textlang`  | Emits `#set text(lang: "xx")` directive.               | Typst uses ISO 639 codes, not `babel` language names. |
| `fontspec`   | `zzt2f_font`      | Emits `#set text(font: "Font Name")` directive.        | Typst has native font handling; no `fontspec`.       |
| `geometry`   | `zzt2f_page`      | Emits `#set page(margin: ..., width: ..., height: ...)`. | Tight semantic parallel.                           |

### Batch H — siunitx (1 helper, partial)

| `t2f_*`       | `zzt2f_*`        | Mechanism                                     | Notes                                                                     |
|---------------|------------------|-----------------------------------------------|---------------------------------------------------------------------------|
| `t2f_siunitx` | `zzt2f_siunitx`  | Emits `#import "@preview/metro:0.3.0": *`.    | Partial coverage. `metro` supports `qty` and `num` but not all `siunitx` options. Document gaps. |

### Skipped (already generic or LaTeX-only)

| Function                        | Rationale                                                                 |
|---------------------------------|---------------------------------------------------------------------------|
| `t2f_cache_*` family            | Backend-agnostic; cache already works for both pipelines.                 |
| `convert_pdf_to_png/svg`        | Operate on any PDF regardless of source.                                  |
| `ensure_pdflatex`, `ensure_pdfcrop`, `check_latex_deps` | LaTeX-only; `check_typst_deps()` already exists as Typst equivalent. |
| `t2f_output_formats`            | Reports the format registry; Typst pipeline has its own.                  |
| Theme family (`t2f_theme*`)     | Already ported — see `zzt2f-themes.R`.                                    |

## Consumption sites in `zzt2f()`

New or extended parameters on `zzt2f()`:

- `formats = NULL` — a single `zzt2f_format` spec or a list of
  them. Applied via `tinytable::style_tt()` before `save_tt()`.
- `marks = NULL` — list of `zzt2f_mark` specs; cell content
  replacement happens pre-`tt()`.
- `preamble = NULL` — a list of preamble-emitter spec objects
  (`zzt2f_page`, `zzt2f_font`, `zzt2f_textlang`, `zzt2f_siunitx`)
  collected into `postprocess_typst()` opts.
- `compile = TRUE` — when `FALSE`, skip `typst compile` and
  return the character vector of `.typ` source lines.

New standalone function: `zzt2f_compile(source, filename,
sub_dir, format, dpi)` — compiles source lines produced by
`zzt2f(..., compile = FALSE)` to a PDF/PNG/SVG.

## Review questions flagged

1. **Batch D margin / wrap inclusion.** LaTeX `marginfigure` and
   `wrapfigure` have no clean Typst analogs. Accept approximations,
   or drop these two helpers from the Typst side?
2. **Batch G preamble emitters.** Do we want these at all in the
   Typst pipeline, or should users write `.typ` preambles by hand?
3. **`header_above` vs `zzt2f_header_above`.** The current
   `zzt2f()` accepts the `t2f_header` object directly. Is a
   separate `zzt2f_header_above()` constructor worth having for
   naming consistency, or is the shared class sufficient?

---

*Reviewer note:* After the full batch set lands, please mark each
row as *both frameworks* / *zzt2f only* / *t2f only* / *drop* to
guide deprecation decisions in the next release.
