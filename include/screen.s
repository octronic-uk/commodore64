// ---------------------------------------------------------
// screen.s
//     Screen address and offset table.
// ---------------------------------------------------------

#importonce

// ---------------------------------------------------------
// Screen Dimensions
// ---------------------------------------------------------
.const screen_width  = $28
.const screen_height = $19

// ---------------------------------------------------------
// Screen char RAM
// ---------------------------------------------------------
.const screen_start  = $0400
.const screen_row_0  = $0400
.const screen_row_1  = $0428
.const screen_row_2  = $0450
.const screen_row_3  = $0478
.const screen_row_4  = $04C8
.const screen_row_5  = $04f0
.const screen_row_6  = $0518
.const screen_row_7  = $0540
.const screen_row_8  = $0568
.const screen_row_9  = $0590
.const screen_row_10 = $05b8
.const screen_row_11 = $05e0
.const screen_row_12 = $0608
.const screen_row_13 = $0630
.const screen_row_14 = $0658
.const screen_row_15 = $0680
.const screen_row_16 = $06a8
.const screen_row_17 = $06d0
.const screen_row_18 = $06f8
.const screen_row_19 = $0720
.const screen_row_20 = $0748
.const screen_row_21 = $0770
.const screen_row_23 = $0798
.const screen_row_24 = $07c0
.const screen_end    = $07e7

// ---------------------------------------------------------
// Screen colour RAM
// ---------------------------------------------------------
.const screen_colour_start  = $d800
.const screen_colour_row_0  = $d800
.const screen_colour_row_1  = $d828
.const screen_colour_row_2  = $d850
.const screen_colour_row_3  = $d878
.const screen_colour_row_4  = $d8a0
.const screen_colour_row_5  = $d8c8
.const screen_colour_row_6  = $d8f0
.const screen_colour_row_7  = $d918
.const screen_colour_row_8  = $d940
.const screen_colour_row_9  = $d968
.const screen_colour_row_10 = $d990
.const screen_colour_row_11 = $d9b8
.const screen_colour_row_12 = $d9e0
.const screen_colour_row_13 = $da08
.const screen_colour_row_14 = $da30
.const screen_colour_row_15 = $da58
.const screen_colour_row_16 = $da80
.const screen_colour_row_17 = $daa8
.const screen_colour_row_18 = $dad0
.const screen_colour_row_19 = $daf8
.const screen_colour_row_20 = $db20
.const screen_colour_row_21 = $db48
.const screen_colour_row_22 = $db70
.const screen_colour_row_23 = $db98
.const screen_colour_row_24 = $dbc0
.const screen_colour_end    = $dbe7

// ---------------------------------------------------------
// Screen Functions
// ---------------------------------------------------------
.const screen_clear  = $E544
.const screen_cursor = $FFF0
.const screen_print  = $AB1E

