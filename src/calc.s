// ---------------------------------------------------------
// calc.s
//     A simple calculator
// ---------------------------------------------------------

#import "../include/io.s"
#import "../include/colours.s"
#import "../include/keymap.s"
#import "border.s"

BasicUpstart2(main)
    *=4000 "CALC"

// ---------------------------------------------------------
// Constants
// ---------------------------------------------------------

.const prompt_msg_row = $04
.const prompt_msg_col = $02

.const options_row_1 = $06
.const options_row_2 = $07
.const options_row_3 = $08

.const options_col_1 = $02
.const options_col_2 = $14

.const options_prompt_row = $0a
.const selected_op_row = $0b

.const operand_1_row = $0c
.const operand_2_row = $0d

.const prompt_col = $02
.const prompt_response_col = $04

// Addresses
.const operation_addr = $7000
.const operand_index  = $7010
.const operand_1_addr = $7100
.const operand_2_addr = $7200

// ---------------------------------------------------------
// Program Entry Point
// ---------------------------------------------------------
main: 
    jsr setup
    jsr print_prompt_msg
    jsr print_options_prompt

_main_loop:    
    jsr get_operation
    jsr get_operands
    jsr do_operation
    jsr print_result
    jmp _main_loop

setup:
    jsr screen_clear
    jsr set_colours
    jsr draw_border
    rts

set_colours:
    lda #orange
    sta text_colour_ptr
    lda #blue
    sta border_colour_ptr 
    sta background_colour_ptr 
    rts

print_prompt_msg:
    // prompt
    clc
    ldx #prompt_msg_row
    ldy #prompt_msg_col
    jsr screen_cursor
    lda #<prompt_msg
    ldy #>prompt_msg
    jsr screen_print
    rts

print_options_prompt:
    jsr print_add_option
    jsr print_sub_option
    jsr print_mul_option
    jsr print_div_option
    jsr print_quit_option

    // Setup prompt 
    clc
    ldx #options_prompt_row
    ldy #prompt_col
    jsr screen_cursor

    lda #<prompt_char
    ldy #>prompt_char
    jsr screen_print
    
    rts

print_quit_option:
    clc
    ldx #options_row_3
    ldy #options_col_1
    jsr screen_cursor
    lda #<quit_msg
    ldy #>quit_msg
    jsr screen_print
    rts


print_add_option:
    clc
    ldx #options_row_1
    ldy #options_col_1
    jsr screen_cursor
    lda #<add_msg
    ldy #>add_msg
    jsr screen_print
    rts

print_sub_option:
    clc
    ldx #options_row_2
    ldy #options_col_1
    jsr screen_cursor

    lda #<sub_msg
    ldy #>sub_msg
    jsr screen_print

    rts

print_mul_option:
    clc
    ldx #options_row_1
    ldy #options_col_2
    jsr screen_cursor
    lda #<mul_msg
    ldy #>mul_msg
    jsr screen_print
    rts

print_div_option:
    clc
    ldx #options_row_2
    ldy #options_col_2
    jsr screen_cursor
    lda #<div_msg
    ldy #>div_msg
    jsr screen_print
    rts

get_operation:
    clc
    ldx #options_prompt_row
    ldy #prompt_response_col 
    jsr screen_cursor
    jsr io_getin
    beq get_operation
    jsr io_chrout
    sta operation_addr
    jsr print_selected_operation
    rts

get_operand_1:
    clc
    ldx #operand_1_row
    ldy #prompt_col
    jsr screen_cursor

    lda #<prompt_char
    ldy #>prompt_char
    jsr screen_print

    clc
    ldx #operand_1_row
    ldy #prompt_response_col
    jsr screen_cursor

    ldx #$00
    stx operand_index
get_operand_1_loop:
    jsr io_getin
    beq get_operand_1_loop
    ldx operand_index
    sta operand_1_addr,x
    inx
    stx operand_index
    jsr io_chrout
    cmp #key_return
    bne get_operand_1_loop
    lda #$00
    sta operand_1_addr,x
    rts

get_operand_2:
    clc
    ldx #operand_2_row
    ldy #prompt_col 
    jsr screen_cursor

    lda #<prompt_char
    ldy #>prompt_char
    jsr screen_print

    clc
    ldx #operand_2_row
    ldy #prompt_response_col 
    jsr screen_cursor

    ldx #$00
    stx operand_index
get_operand_2_loop:
    jsr io_getin
    beq get_operand_2_loop
    ldx operand_index
    sta operand_2_addr,x
    inx
    stx operand_index
    jsr io_chrout
    cmp #key_return
    bne get_operand_2_loop
    lda #$00
    sta operand_2_addr,x
    rts

get_operands:
    jsr get_operand_1
    jsr get_operand_2
    rts

do_operation:
    rts

print_result:
    rts

print_selected_operation:
    clc
    ldx #selected_op_row
    ldy #prompt_col
    jsr screen_cursor

    lda operation_addr

    cmp #key_1
    beq print_add_mode_msg

    cmp #key_2
    beq print_sub_mode_msg

    cmp #key_3
    beq print_mul_mode_msg

    cmp #key_4
    beq print_div_mode_msg

    cmp #key_back
    beq done

    jmp print_invalid_mode_msg

    rts

done:
    brk

print_add_mode_msg:
    lda #<add_mode_msg
    ldy #>add_mode_msg
    jsr screen_print
    rts

print_sub_mode_msg:
    lda #<sub_mode_msg
    ldy #>sub_mode_msg
    jsr screen_print
    rts

print_mul_mode_msg:
    lda #<mul_mode_msg
    ldy #>mul_mode_msg
    jsr screen_print
    rts

print_div_mode_msg:
    lda #<div_mode_msg
    ldy #>div_mode_msg
    jsr screen_print
    rts

print_invalid_mode_msg:
    lda #<invalid_mode_msg
    ldy #>invalid_mode_msg
    jsr screen_print
    jmp get_operation

// ---------------------------------------------------------
// Variables
// ---------------------------------------------------------

prompt_msg:
    .text "PLEASE CHOOSE AN OPERATION..."
    .byte $00

quit_msg:
    .byte $5F
    .text ". BACK TO BASIC"
    .byte $00


add_msg:
    .text "1. ADD"
    .byte $00

add_mode_msg:
    .text "ADD MODE            "
    .byte $00

sub_msg:
    .text "2. SUBTRACT"
    .byte $00

sub_mode_msg:
    .text "SUBTRACT MODE       "
    .byte $00

mul_msg:
    .text "3. MULTIPLY"
    .byte $00

mul_mode_msg:
    .text "MULTIPLY MODE       "
    .byte $00

div_msg:
    .text "4. DIVIDE"
    .byte $00

div_mode_msg:
    .text "DIVIDE MODE         "
    .byte $00

invalid_mode_msg:
    .text "INVALID MODE        "
    .byte $00

prompt_char:
    .text ">"
    .byte $00

border_title:
    .text "CALCULATOR"
    .byte $00
