#set page(width: auto, height: auto, margin: (x: 5pt, y: 5pt))
#show figure: set block(breakable: true)
#figure( // start preamble figure
  
  kind: "tinytable",
  supplement: "Table", // end preamble figure

block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "2_0": 0, "4_0": 0, "6_0": 0, "2_1": 0, "4_1": 0, "6_1": 0, "2_2": 0, "4_2": 0, "6_2": 0, "2_3": 0, "4_3": 0, "6_3": 0, "1_0": 1, "3_0": 1, "5_0": 1, "7_0": 1, "1_1": 1, "3_1": 1, "5_1": 1, "7_1": 1, "1_2": 1, "3_2": 1, "5_2": 1, "7_2": 1, "1_3": 1, "3_3": 1, "5_3": 1, "7_3": 1, "0_0": 2, "0_1": 2, "0_2": 2, "0_3": 2
  )

  #let style-array = ( 
    // tinytable cell style after
    (align: left,),
    (background: rgb("#E6E6FF"), align: left,),
    (bold: true, align: left,),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 { return it }
    
    let style = get-style(it.x, it.y)
    if style == none { return it }
    
    let tmp = it
    if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
    if ("color" in style) { tmp = text(fill: style.color, tmp) }
    if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
    if ("underline" in style) { tmp = underline(tmp) }
    if ("italic" in style) { tmp = emph(tmp) }
    if ("bold" in style) { tmp = strong(tmp) }
    if ("mono" in style) { tmp = math.mono(tmp) }
    if ("strikeout" in style) { tmp = strike(tmp) }
    if ("smallcaps" in style) { tmp = smallcaps(tmp) }
    tmp
  }

  #align(center, [

  #table( // tinytable table start
    columns: (auto, auto, auto, auto),
    stroke: none,
    rows: auto,
    align: (x, y) => {
      let style = get-style(x, y)
      if style != none and "align" in style { style.align } else { left }
    },
    fill: (x, y) => {
      let style = get-style(x, y)
      if style != none and "background" in style { style.background }
    },
 table.hline(y: 1, start: 0, end: 4, stroke: 0.05em + black),
 table.hline(y: 8, start: 0, end: 4, stroke: 0.08em + black),
 table.hline(y: 0, start: 0, end: 4, stroke: 0.08em + black),
    // tinytable lines before
 table.hline(y: 5, start: 0, end: 4, stroke: 0.05em + black),

    // tinytable header start
    table.header(
      repeat: true,
[Term], [Model1], [Model2], [Model3],
    ),
    // tinytable header end

    // tinytable cell content after
[(Intercept)], [37.885\* (2.074)], [36.908\* (2.191)], [38.752\* (1.787)],
[cyl], [-2.876\* (0.322)], [-2.265\* (0.576)], [-0.942 (0.551)],
[hp], [], [-0.019 (0.015)], [-0.018 (0.012)],
[wt], [], [], [-3.167\* (0.741)],
[N], [32], [32], [32],
[R-squared], [0.726], [0.741], [0.843],
[Adj. R-squared], [0.717], [0.723], [0.826],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
) // end figure
