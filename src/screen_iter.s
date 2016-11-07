//----------------------------------------------------------
// screen_iter.s
//    Iterate the screen using 16-bit arithmetic.
//----------------------------------------------------------

#import "../include/colours.s"
#import "../include/screen.s"

BasicUpstart2(main)
    *=4000 "ScreenIter"

//----------------------------------------------------------
// Program Entry Point
//----------------------------------------------------------

.const screen_ptr_lsb = $f0
.const screen_ptr_msb = $f1

.const screen_colour_ptr_lsb = $f2
.const screen_colour_ptr_msb = $f3

.const current_char   = $7500
.const current_colour = $7501

main: 
    // Set bg to black
    lda #green
    sta background_colour_ptr
    sta border_colour_ptr
    // set the character
    lda #$51
    sta current_char
    lda #$00
    sta current_colour
start:
    
    // Store the screen char offset in screen_ptr
    // lsb
    lda #<screen_start
    sta screen_ptr_lsb

    // msb
    lda #>screen_start
    sta screen_ptr_msb

    // Store the screen colour offset in screen_ptr
    // lsb
    lda #<screen_colour_start
    sta screen_colour_ptr_lsb

    // msb
    lda #>screen_colour_start
    sta screen_colour_ptr_msb

// Print the next char position
next_char:
    lda current_colour
    sbc #$F0
    ldx #$00
    cmp background_colour_ptr
    bne colour_ok
    inc current_colour
colour_ok:
    inc current_colour
    lda current_char
    // Store character
    ldx #$00
    sta (screen_ptr_lsb,x)
    // Increment screen address lsb
    clc
    lda screen_ptr_lsb
    adc #$01
    sta screen_ptr_lsb
    // Increment screen address msb
    lda screen_ptr_msb
    adc #$00
    sta screen_ptr_msb

    lda current_colour
    // Store colour
    ldx #$00
    sta (screen_colour_ptr_lsb,x)
    // Increment screen address lsb
    clc
    lda screen_colour_ptr_lsb
    adc #$01
    sta screen_colour_ptr_lsb
    // Increment screen address msb
    lda screen_colour_ptr_msb
    adc #$00
    sta screen_colour_ptr_msb
    

/*
    // Pause Loop
    ldy #$00
loop_y:
    iny
    cpy #$ff
    bne loop_y
*/

    // Compare with screen end lsb
    lda screen_ptr_lsb
    cmp #<screen_end+1
    bne next_char

    // Compare with screen end msb
    lda screen_ptr_msb
    cmp #>screen_end+1
    bne next_char

    // Pause Loop
    ldx #$00
loop_x_2:
    ldy #$00
loop_y_2:
    iny
    cpy #$ff
    bne loop_y_2
    inx
    cpx #$0f
    bne loop_x_2

    jmp start
