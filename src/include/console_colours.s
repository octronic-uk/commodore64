/* ---------------------------------------------------------
    console_colours.s
        Set the colours of the console
        - Load the background colour into X
        - Load the foreground colour into Y
    Usage:
        ldx #$00 // Black
        ldy #$05 // Green
        jsr console_colours
--------------------------------------------------------- */
console_colours: 
    stx $D020
    stx $D021
    sty $0286
    rts
