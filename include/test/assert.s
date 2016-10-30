// ---------------------------------------------------------
// assert.s
//      Uint test assertion utilities.
// ---------------------------------------------------------

#import "../keymap.s"

.const print = $AB1E

assert_pass:
    lda #<pass_msg
    ldy #>pass_msg
    jsr print
    rts

assert_fail:
    lda #<fail_msg
    ldy #>fail_msg
    jsr print
    rts

pass_msg:
    .text " PASS"
    .byte key_return
    .byte $00

fail_msg:
    .text " FAIL"
    .byte key_return
    .byte $00
