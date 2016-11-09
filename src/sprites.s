//----------------------------------------------------------
// sprites.s
//----------------------------------------------------------

#import "../include/keymap.s"
#import "../include/screen.s"
#import "../include/io.s"
#import "../sprites/ship.s"

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
    lda #00
    sta colour0
    lda #0
    sta msbx
    ldx #255
    lda #160
    sta sp0y
    stx sp0x

get_key:
    jsr io_getin
    cmp #$00
    beq get_key

    cmp #key_w
    beq move_up

    cmp #key_a
    beq move_left

    cmp #key_s
    beq move_down

    cmp #key_d
    beq move_right

    bne after_key

move_up:
    dec sp0y
    jmp after_key

move_down:
    inc sp0y
    jmp after_key

move_left:
    dec sp0x
    jmp after_key

move_right:
    inc sp0x
    jmp after_key

after_key:

    ldy #00
pause_1:  
    iny
    cpy #255
    bne pause_1
/*
pause_2:  
    dey
    cpy #00
    bne pause_2
*/
    jmp get_key

    rts

