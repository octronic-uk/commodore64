//----------------------------------------------------------
// test_strlen.s
//     Test strlen function.
//----------------------------------------------------------

#import "assert.s"
#import "../strlen.s"

.const print_at_cursor = $AB1E
.const test_string_1_len = $0D
.const test_string_2_len = $06

BasicUpstart2(test_strlen)
    *=4000 "test_strlen.s"

test_strlen:
    lda #<test_string_1
    sta strlen_lsb
    lda #>test_string_1
    sta strlen_msb
    jsr strlen
    cpy #test_string_1_len
    beq assert_pass
    bne assert_fail

    rts

test_string_1:
    .text "hello, world!"
    .byte $00

test_string_2:
    .text "strlen"
    .byte $00
