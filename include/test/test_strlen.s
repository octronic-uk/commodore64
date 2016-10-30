//----------------------------------------------------------
// test_strlen.s
//     Test strlen function.
//----------------------------------------------------------

#import "assert.s"
#import "../strlen.s"

.const test_string_1_len = $0D
.const test_string_2_len = $06

BasicUpstart2(test_strlen)
    *=4000 "test_strlen"

test_strlen:
    lda #<intro
    ldy #>intro
    jsr print

    jsr test_string_1_good
    jsr test_string_1_bad
    jsr test_string_2_good
    jsr test_string_2_bad
    rts

test_string_1_good:
    lda #<test_string_1_good_msg
    ldy #>test_string_1_good_msg
    jsr print

    lda #<test_string_1
    sta strlen_lsb
    lda #>test_string_1
    sta strlen_msb
    jsr strlen
    cpy #test_string_1_len
    beq goto_assert_pass
    bne goto_assert_fail
    rts

test_string_1_bad:
    lda #<test_string_1_bad_msg
    ldy #>test_string_1_bad_msg
    jsr print

    lda #<test_string_1
    sta strlen_lsb
    lda #>test_string_1
    sta strlen_msb
    jsr strlen
    cpy #test_string_2_len
    beq goto_assert_fail
    bne goto_assert_pass
    rts

test_string_2_good:
    lda #<test_string_2_good_msg
    ldy #>test_string_2_good_msg
    jsr print

    lda #<test_string_2
    sta strlen_lsb
    lda #>test_string_2
    sta strlen_msb
    jsr strlen
    cpy #test_string_2_len
    beq goto_assert_pass
    bne goto_assert_fail
    rts

test_string_2_bad:
    lda #<test_string_2_bad_msg
    ldy #>test_string_2_bad_msg
    jsr print

    lda #<test_string_2
    sta strlen_lsb
    lda #>test_string_2
    sta strlen_msb
    jsr strlen
    cpy #test_string_1_len
    beq goto_assert_fail
    bne goto_assert_pass
    rts

goto_assert_fail:
    jsr assert_fail
    rts

goto_assert_pass:
    jsr assert_pass
    rts

test_string_1:
    .text "hello, world!"
    .byte $00

test_string_2:
    .text "strlen"
    .byte $00

test_string_1_good_msg:
    .text "TEST STRING 1 GOOD"
    .byte key_return
    .byte $00

test_string_1_bad_msg:
    .text "TEST STRING 1 BAD"
    .byte key_return
    .byte $00

test_string_2_good_msg:
    .text "TEST STRING 2 GOOD"
    .byte key_return
    .byte $00

test_string_2_bad_msg:
    .text "TEST STRING 2 BAD"
    .byte key_return
    .byte $00

intro:
    .text "TESTING STRLEN"
    .byte key_return, key_return, $00
