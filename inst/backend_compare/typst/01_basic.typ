#set page(width: auto, height: auto, margin: (x: 5pt, y: 5pt))
#show figure: set block(breakable: true)
#figure( // start preamble figure
  
  kind: "tinytable",
  supplement: "Table", // end preamble figure

block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "2_0": 0, "4_0": 0, "6_0": 0, "2_1": 1, "4_1": 1, "6_1": 1, "2_2": 1, "4_2": 1, "6_2": 1, "2_3": 1, "4_3": 1, "6_3": 1, "2_4": 1, "4_4": 1, "6_4": 1, "1_0": 2, "3_0": 2, "5_0": 2, "1_1": 3, "3_1": 3, "5_1": 3, "1_2": 3, "3_2": 3, "5_2": 3, "1_3": 3, "3_3": 3, "5_3": 3, "1_4": 3, "3_4": 3, "5_4": 3, "0_0": 4, "0_1": 5, "0_2": 5, "0_3": 5, "0_4": 5
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
