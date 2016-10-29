
// -----------------------------------------------------------------------------
// printash.s
//    Turn the screen to a green and black theme.
//    Print some messages to the user
// -----------------------------------------------------------------------------

#import "lib/console_colours.s"

BasicUpstart2(main)
    *=4000 "PrintMsgInColours"

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------
main: 
// Set console green/black
    ldx #$00
    ldy #$05
    jsr console_colours

// Clear Console
    jsr $E544

// Plot Cursor
    clc
    ldx #$01 // Col
    ldy #$01 // Row
    jsr $E50A
  
// Print msg
    lda #<str_msg
    ldy #>str_msg
    jsr $AB1E

// Plot Cursor
    clc
    ldx #$03 // Col
    ldy #$03 // Row
    jsr $E50A
  
// Print msg
    lda #<str_msg
    ldy #>str_msg
    jsr $AB1E

// Plot Cursor
    clc
    ldx #$05 // Col
    ldy #$05 // Row
    jsr $E50A
  
// Print msg
    lda #<str_msg
    ldy #>str_msg
    jsr $AB1E

// Return
    rts

// Variables -------------------------------------------------------------------
str_msg:
    .text "C64 ROCKS MY SOCKS!!"
    .byte $00

