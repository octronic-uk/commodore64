//----------------------------------------------------------
// sprites.s
//----------------------------------------------------------

#import "../include/screen.s"

BasicUpstart2(main)
    *=4000 "Sprites"

//----------------------------------------------------------
// Program Entry Point
//----------------------------------------------------------
.const sprite0 = $7f8
.const enable = $d015
.const colour0 = $d027
.const sp0x = $d000
.const sp0y = $d001
.const msbx = $d010
.const ship = $0340

main: 
    jsr screen_clear
    lda #13
    sta sprite0
    lda #1
    sta enable
    lda #7
    sta colour0
    ldx #0
    lda #0
cleanup:
    sta ship,x
    inx
    cpx #63
    bne cleanup
    ldx #0
    lda #255
build:
    sta ship,x
    inx
    cpx #63
    bne build
    lda #0
    sta msbx
    ldx #0
    lda #70
move:
    sta sp0x
    stx sp0y
    ldy #0
pause:  
    iny
    cpy #255
    bne pause
    inx
    //cpx #254
    //bne move
    jmp move
    rts
