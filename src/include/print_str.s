/* ---------------------------------------------------------
    print_str.s
        Print a string to the screen.
        - Store string data pointer in zero page @[$FE,$FF]
        - Print chars at [$FE,$FF] to screen position 0,0
        - Ends when null ($00) is found

    Usage:
        ldx #<my_str
        ldy #>my_str
        jsr print_str

        mystr:
            .text "hello, world!"
            .byte $00
--------------------------------------------------------- */
print_str: 
// Data structure start
    stx $FE
    sty $FF
    ldy #$00
_print_str_next_char:
    lda ($FE),y
    cmp #$00
    beq _print_str_end
    jmp $F1CA
    iny
    jmp _print_str_next_char
_print_str_end:
    rts
