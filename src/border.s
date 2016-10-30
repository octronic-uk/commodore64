//----------------------------------------------------------
// border.s
//    Draw a border around the screen
//----------------------------------------------------------
BasicUpstart2(main)
    *=4000 "Border!"

#import "include/colours.s"
#import "include/util.s"

.const top_left_char     = $D5
.const top_right_char    = $C9
.const bottom_left_char  = $CA
.const bottom_right_char = $CB

.const horiz_bar_char    = $C3
.const vert_bar_char     = $C2
.const left_sep_char     = $EB
.const right_sep_char    = $F3

.const row_1  = $0400 
.const row_2  = $0428
.const row_3  = $0450
.const row_5  = $04C8
.const row_10 = $0590
.const row_15 = $0658
.const row_20 = $0720
.const row_25 = $07C0


.const num_rows = $19
.const num_cols = $28

//----------------------------------------------------------
// Program Entry Point
//----------------------------------------------------------
main: 
    jsr clear_screen
    jsr draw_top
    jsr draw_sides
    jsr draw_bottom
    jsr draw_header_separator
    jsr draw_title
    
    jmp chill

chill:
    nop
    jmp chill

draw_top:
    ldx #$00
    lda #top_left_char 
    sta row_1,x
draw_top_next_hbar:
    inx
    lda #horiz_bar_char
    sta row_1,x
    cpx #num_cols-2
    bne draw_top_next_hbar
    inx
    lda #top_right_char 
    sta row_1,x
    rts

draw_title:
    rts

draw_header_separator:
    ldx #$00
    lda #left_sep_char
    sta row_3,x
draw_sep_next_hbar:
    inx
    lda #horiz_bar_char
    sta row_3,x
    cpx #num_cols-2
    bne draw_sep_next_hbar

    inx
    lda #right_sep_char 
    sta row_3,x
    rts

draw_sides:

// 0 - 5
    lda #<row_1+num_cols
    sta $FE
    lda #>row_1+num_cols
    sta $FF
    ldy #$00
draw_side_1_to_5:
    lda #vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #num_cols-1
    tay
    lda #vert_bar_char
    sta ($FE),y
    iny
    cpy #(num_cols)*5
    bne draw_side_1_to_5

// 5 - 10
    lda #<row_5
    sta $FE
    lda #>row_5
    sta $FF
    ldy #$00
draw_side_5_to_10:
    lda #vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #num_cols-1
    tay
    lda #vert_bar_char
    sta ($FE),y
    iny
    cpy #(num_cols)*5
    bne draw_side_5_to_10

// 10 - 15
    lda #<row_10
    sta $FE
    lda #>row_10
    sta $FF
    ldy #$00
draw_side_10_to_15:
    lda #vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #num_cols-1
    tay
    lda #vert_bar_char
    sta ($FE),y
    iny
    cpy #(num_cols)*5
    bne draw_side_10_to_15

// 15 - 20
    lda #<row_15
    sta $FE
    lda #>row_15
    sta $FF
    ldy #$00
draw_side_15_to_20:
    lda #vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #num_cols-1
    tay
    lda #vert_bar_char
    sta ($FE),y
    iny
    cpy #(num_cols)*5
    bne draw_side_15_to_20

// 20 - 25
    lda #<row_20
    sta $FE
    lda #>row_20
    sta $FF
    ldy #$00
draw_side_20_to_25:
    lda #vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #num_cols-1
    tay
    lda #vert_bar_char
    sta ($FE),y
    iny
    cpy #(num_cols)*5
    bne draw_side_20_to_25

draw_sides_done:
    rts

draw_bottom:
    ldx #$00
    lda #bottom_left_char 
    sta row_25,x
draw_bottom_next_hbar:
    inx
    lda #horiz_bar_char
    sta row_25,x
    cpx #num_cols-2
    bne draw_bottom_next_hbar
    inx
    lda #bottom_right_char 
    sta row_25,x
    rts
