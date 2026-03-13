#set page(width: auto, height: auto, margin: (x: 5pt, y: 5pt))
#show figure: set block(breakable: true)
#figure( // start preamble figure
  
  kind: "tinytable",
  supplement: "Table", // end preamble figure

block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "1_0": 0, "3_0": 0, "5_0": 0, "1_1": 1, "3_1": 1, "5_1": 1, "1_2": 1, "3_2": 1, "5_2": 1, "1_3": 1, "3_3": 1, "5_3": 1, "1_4": 1, "3_4": 1, "5_4": 1, "0_0": 2, "0_1": 3, "0_2": 3, "0_3": 3, "0_4": 3, "2_0": 4, "4_0": 4, "6_0": 4, "2_1": 5, "4_1": 5, "6_1": 5, "2_2": 5, "4_2": 5, "6_2": 5, "2_3": 5, "4_3": 5, "6_3": 5, "2_4": 5, "4_4": 5, "6_4": 5
  )

  #let style-array = ( 
    // tinytable cell style after
    (background: rgb("#FEF8EA"), fontsize: 0.8em, align: left,),
    (background: rgb("#FEF8EA"), fontsize: 0.8em, align: right,),
    (bold: true, fontsize: 0.8em, align: left,),
    (bold: true, fontsize: 0.8em, align: right,),
    (fontsize: 0.8em, align: left,),
    (fontsize: 0.8em, align: right,),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, left, ) // tinytable align-default-array here
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
    columns: (auto, auto, auto, auto, auto),
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
 table.hline(y: 1, start: 0, end: 5, stroke: 0.05em + black),
 table.hline(y: 7, start: 0, end: 5, stroke: 0.08em + black),
 table.hline(y: 0, start: 0, end: 5, stroke: 0.08em + black),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[ ], [mpg], [cyl], [disp], [hp],
    ),
    // tinytable header end

    // tinytable cell content after
[Mazda RX4], [21.0], [6], [160], [110],
[Mazda RX4 Wag], [21.0], [6], [160], [110],
[Datsun 710], [22.8], [4], [108], [93],
[Hornet 4 Drive], [21.4], [6], [258], [110],
[Hornet Sportabout], [18.7], [8], [360], [175],
[Valiant], [18.1], [6], [225], [105],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
) // end figure
