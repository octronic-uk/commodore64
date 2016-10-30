//----------------------------------------------------------
// border.s
//    Draw a border around the screen
//----------------------------------------------------------

// For Testing
//BasicUpstart2(_border_main)
//*=4000 "Border!"

#import "../include/colours.s"
#import "../include/util.s"
#import "../include/strlen.s"

.const _border_top_left_char     = $D5
.const _border_top_right_char    = $C9
.const _border_bottom_left_char  = $CA
.const _border_bottom_right_char = $CB

.const _border_horiz_bar_char    = $C3
.const _border_vert_bar_char     = $C2
.const _border_left_sep_char     = $EB
.const _border_right_sep_char    = $F3

.const _border_row_1  = $0400 
.const _border_row_2  = $0428
.const _border_row_3  = $0450
.const _border_row_5  = $04C8
.const _border_row_10 = $0590
.const _border_row_15 = $0658
.const _border_row_20 = $0720
.const _border_row_25 = $07C0


.const _border_num_rows = $19
.const _border_num_cols = $28

//----------------------------------------------------------
// Program Entry Point
//----------------------------------------------------------
draw_border: 
    jsr clear_screen
    jsr _border_draw_top
    jsr _border_draw_sides
    jsr _border_draw_bottom
    jsr _border_draw_header_separator
    jsr _border_draw_title
    rts

_border_draw_top:
    ldx #$00
    lda #_border_top_left_char 
    sta _border_row_1,x
_border_draw_top_next_hbar:
    inx
    lda #_border_horiz_bar_char
    sta _border_row_1,x
    cpx #_border_num_cols-2
    bne _border_draw_top_next_hbar
    inx
    lda #_border_top_right_char 
    sta _border_row_1,x
    rts

_border_draw_title:
    // Get title length
    lda #<border_title
    sta strlen_lsb
    lda #>border_title
    sta strlen_msb
    jsr strlen
    txa
    // Divide title length by 2 and store in C0
    lsr
    sta $C0
    // Get title space width
    lda #_border_num_cols
    sec
    sbc #$2
    // Divide by 2
    lsr
    // subtract title width/2
    sec
    sbc $C0
    // Store back in $C0
    sta $C0
    
    ldx #$01
    ldy $C0
    clc
    jsr set_cursor_pos
    lda #<border_title 
    ldy #>border_title
    jsr $AB1E
    rts

_border_draw_header_separator:
    ldx #$00
    lda #_border_left_sep_char
    sta _border_row_3,x
_border_draw_sep_next_hbar:
    inx
    lda #_border_horiz_bar_char
    sta _border_row_3,x
    cpx #_border_num_cols-2
    bne _border_draw_sep_next_hbar

    inx
    lda #_border_right_sep_char 
    sta _border_row_3,x
    rts

_border_draw_sides:
// 0 - 5
    lda #<_border_row_1+_border_num_cols
    sta $FE
    lda #>_border_row_1+_border_num_cols
    sta $FF
    ldy #$00
_border_draw_side_1_to_5:
    lda #_border_vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #_border_num_cols-1
    tay
    lda #_border_vert_bar_char
    sta ($FE),y
    iny
    cpy #(_border_num_cols)*5
    bne _border_draw_side_1_to_5
// 5 - 10
    lda #<_border_row_5
    sta $FE
    lda #>_border_row_5
    sta $FF
    ldy #$00
 _border_draw_side_5_to_10:
    lda #_border_vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #_border_num_cols-1
    tay
    lda #_border_vert_bar_char
    sta ($FE),y
    iny
    cpy #(_border_num_cols)*5
    bne _border_draw_side_5_to_10

// 10 - 15
    lda #<_border_row_10
    sta $FE
    lda #>_border_row_10
    sta $FF
    ldy #$00
 _border_draw_side_10_to_15:
    lda #_border_vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #_border_num_cols-1
    tay
    lda #_border_vert_bar_char
    sta ($FE),y
    iny
    cpy #(_border_num_cols)*5
    bne _border_draw_side_10_to_15

// 15 - 20
    lda #<_border_row_15
    sta $FE
    lda #>_border_row_15
    sta $FF
    ldy #$00
 _border_draw_side_15_to_20:
    lda #_border_vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #_border_num_cols-1
    tay
    lda #_border_vert_bar_char
    sta ($FE),y
    iny
    cpy #(_border_num_cols)*5
    bne _border_draw_side_15_to_20

// 20 - 25
    lda #<_border_row_20
    sta $FE
    lda #>_border_row_20
    sta $FF
    ldy #$00
 _border_draw_side_20_to_25:
    lda #_border_vert_bar_char
    sta ($FE),y
    tya 
    clc
    adc #_border_num_cols-1
    tay
    lda #_border_vert_bar_char
    sta ($FE),y
    iny
    cpy #(_border_num_cols)*5
    bne _border_draw_side_20_to_25

 _border_draw_sides_done:
    rts

 _border_draw_bottom:
    ldx #$00
    lda #_border_bottom_left_char 
    sta _border_row_25,x
 _border_draw_bottom_next_hbar:
    inx
    lda #_border_horiz_bar_char
    sta _border_row_25,x
    cpx #_border_num_cols-2
    bne _border_draw_bottom_next_hbar
    inx
    lda #_border_bottom_right_char 
    sta _border_row_25,x
    rts

