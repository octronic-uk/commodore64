//----------------------------------------------------------
// some_sid.s
//----------------------------------------------------------

#import "../include/sid.s"

BasicUpstart2(main)
    *=4000 "SomeSID"

//----------------------------------------------------------
// Program Entry Point
//----------------------------------------------------------
main: 
    lda #$0f
    sta sid_volume
    lda #$80
    sta sid_1_attack_decay
    sta sid_1_sustain_release
    lda #$c3
    sta sid_1_frequency_lo
    lda #$10
    sta sid_1_frequency_hi
    lda #$11
    sta sid_1_vc
    ldy #$00
set:
    ldx #$00
play:
    inx
    cpx #$ff
    bne play
    iny
    cpy #$64
    bne set

    lda #$00
    sta sid_1_vc
    sta sid_1_attack_decay
    sta sid_1_sustain_release
    sta sid_1_frequency_hi
    sta sid_1_frequency_hi
    rts
