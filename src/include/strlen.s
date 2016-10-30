//----------------------------------------------------------
// strlen.s
//     Get the length of the null-terminated string pointed to 
//     by $00. Store result in x. 
//----------------------------------------------------------

.const strlen_lsb = $FE
.const strlen_msb = $FF

strlen:
    ldy #$00
_strlen_count:
    lda (strlen_lsb),y
    cmp #$00
    beq _strlen_done
    sta $0400,y
    iny
    bne _strlen_count
_strlen_done:
    tya
    tax
    rts
