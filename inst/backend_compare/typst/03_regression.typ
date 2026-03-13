#set page(width: auto, height: auto, margin: (x: 5pt, y: 5pt))
#show figure: set block(breakable: true)
#figure( // start preamble figure
  
  kind: "tinytable",
  supplement: "Table", // end preamble figure

block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "2_0": 0, "4_0": 0, "2_3": 0, "4_3": 0, "2_1": 1, "4_1": 1, "2_2": 1, "4_2": 1, "1_0": 2, "3_0": 2, "1_3": 2, "3_3": 2, "1_1": 3, "3_1": 3, "1_2": 3, "3_2": 3, "0_0": 4, "0_3": 4, "0_1": 5, "0_2": 5
  )

  #let style-array = ( 
    // tinytable cell style after
    (align: left,),
    (align: right,),
    (background: rgb("#E6E6FF"), align: left,),
    (background: rgb("#E6E6FF"), align: right,),
    (bold: true, align: left,),
    (bold: true, align: right,),
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
 table.hline(y: 5, start: 0, end: 4, stroke: 0.08em + black),
 table.hline(y: 0, start: 0, end: 4, stroke: 0.08em + black),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[term], [estimate], [std.error], [p.value],
    ),
    // tinytable header end

    // tinytable cell content after
[(Intercept)], [38.7517874], [1.78686403], [\<0.001],
[cyl], [-0.9416168], [0.55091638], [0.098],
[hp], [-0.0180381], [0.01187625], [0.140],
[wt], [-3.1669731], [0.74057588], [\<0.001],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
) // end figure
