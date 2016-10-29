// ---------------------------------------------------------
// calc.s
//     A simple calculator
// ---------------------------------------------------------

#import "lib/octronic/console_colours.s"
#import "lib/c64/colours.s"
#import "lib/c64/keymap.s"

BasicUpstart2(main)
    *=4000 "CALC"

// ---------------------------------------------------------
// Constants
// ---------------------------------------------------------
.const clear_screen = $E544
.const set_cursor_pos = $FFF0
.const print_at_cursor = $AB1E
.const read_key = $FFE4
.const print_key = $FFD2
.const return_to_basic = $BFFF

.const welcome_msg_row = $00
.const options_row_1 = $04 
.const options_row_2 = $05
.const options_row_3 = $06

.const options_col_1 = $00
.const options_col_2 = $14

.const options_prompt_row = $08
.const selected_op_row = $09

.const operand_1_row = $0b
.const operand_2_row = $0d

.const prompt_col = $00
.const prompt_response_col = $02

.const footer_row = $17
.const footer_col = $20

// Pointers
.const op_ptr = $9000
.const operand_1_ptr = $9001
.const operand_2_ptr = $9003
.const exit_flag_ptr = $9004

// ---------------------------------------------------------
// Program Entry Point
// ---------------------------------------------------------
main: 
    jsr setup
    jsr print_welcome
    jsr print_footer

_main_loop:    
    jsr print_options_prompt
    jsr get_operation
    jsr get_operands
    jsr do_operation
    jsr print_result
    jmp _main_loop

_main_exit:
    rts
// end main

setup:
    jsr clear_screen
    jsr set_colours
    rts
// end setup

set_colours:
    ldx #blue
    ldy #light_blue 
    jsr console_colours
    rts
// end set_colours

print_welcome:
    // Plot Cursor
    clc
    ldx #welcome_msg_row
    ldy #$00 // col
    jsr set_cursor_pos
    // Print msg
    lda #<welcome_msg
    ldy #>welcome_msg
    jsr print_at_cursor 
    rts
// end print_welcome

print_footer:
    // Plot Cursor
    clc
    ldx #footer_row
    ldy #footer_col
    jsr set_cursor_pos
    // Print msg
    lda #<footer_msg
    ldy #>footer_msg
    jsr print_at_cursor
    rts
// end print_footer

print_options_prompt:
    // prompt
    clc
    ldx #$02 // row
    ldy #$00 // col 
    jsr set_cursor_pos
    lda #<prompt_msg
    ldy #>prompt_msg
    jsr print_at_cursor
    jsr print_add_option
    jsr print_sub_option
    jsr print_mul_option
    jsr print_div_option
    jsr print_quit_option

    // Setup prompt 
    clc
    ldx #options_prompt_row
    ldy #$00 // col 
    jsr set_cursor_pos

    lda #<prompt_char
    ldy #>prompt_char
    jsr print_at_cursor
    
    rts
// end print_prompt

print_quit_option:
    clc
    ldx #options_row_3 // row
    ldy #options_col_1
    jsr set_cursor_pos
    lda #<quit_msg
    ldy #>quit_msg
    jsr print_at_cursor
    rts
// end print_quit_option


print_add_option:
    clc
    ldx #options_row_1
    ldy #options_col_1
    jsr set_cursor_pos
    lda #<add_msg
    ldy #>add_msg
    jsr print_at_cursor
    rts
// end print_add_option

print_sub_option:
    clc
    ldx #options_row_2
    ldy #options_col_1
    jsr set_cursor_pos

    lda #<sub_msg
    ldy #>sub_msg
    jsr print_at_cursor

    rts
// end print_sub_option

print_mul_option:
    clc
    ldx #options_row_1
    ldy #options_col_2
    jsr set_cursor_pos
    lda #<mul_msg
    ldy #>mul_msg
    jsr print_at_cursor
    rts
// end print_mul_option

print_div_option:
    clc
    ldx #options_row_2
    ldy #options_col_2
    jsr set_cursor_pos
    lda #<div_msg
    ldy #>div_msg
    jsr print_at_cursor
    rts
// end print_div_option

get_operation:
    clc
    ldx #options_prompt_row
    ldy #prompt_response_col 
    jsr set_cursor_pos
    jsr read_key      // read key
    beq get_operation // if no key pressed loop forever
    jsr print_key         // print key on the screen
    sta op_ptr        // store the key to key buffer
    jsr print_selected_operation
    rts
// end get_operation

get_operand_1:
    clc
    ldx #operand_1_row
    ldy #prompt_col
    jsr set_cursor_pos

    lda #<prompt_char
    ldy #>prompt_char
    jsr print_at_cursor

    clc
    ldx #operand_1_row
    ldy #prompt_response_col
    jsr set_cursor_pos

get_operand_1_loop:
    jsr read_key      // read key
    beq get_operand_1_loop  // if no key pressed loop forever
    jsr print_key     // print key on the screen
    sta operand_1_ptr       // store the key to key buffer
    rts
// end get_operand_1

get_operand_2:
    clc
    ldx #operand_2_row
    ldy #prompt_col 
    jsr set_cursor_pos

    lda #<prompt_char
    ldy #>prompt_char
    jsr print_at_cursor

    clc
    ldx #operand_2_row
    ldy #prompt_response_col 
    jsr set_cursor_pos


get_operand_2_loop:
    jsr read_key        // read key
    beq get_operand_2_loop // if no key pressed loop forever
    jsr print_key        // print key on the screen
    sta operand_2_ptr      // store the key to key buffer
    rts
// end get_operand_2

get_operands:
    jsr get_operand_1
    jsr get_operand_2
    rts
// end get_operands

do_operation:
    rts
// end do_operation

print_result:
    rts
// end print_result

print_selected_operation:
    clc
    ldx #selected_op_row
    ldy #$00
    jsr set_cursor_pos

    lda op_ptr

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
// end print_selected_operation    

done:
    jmp return_to_basic 

print_add_mode_msg:
    lda #<add_mode_msg
    ldy #>add_mode_msg
    jsr print_at_cursor
    rts
// end print_op_add_msg

print_sub_mode_msg:
    lda #<sub_mode_msg
    ldy #>sub_mode_msg
    jsr print_at_cursor
    rts
// print_op_sub_mode_msg

print_mul_mode_msg:
    lda #<mul_mode_msg
    ldy #>mul_mode_msg
    jsr print_at_cursor
    rts
// end print_mul_mode_msg

print_div_mode_msg:
    lda #<div_mode_msg
    ldy #>div_mode_msg
    jsr print_at_cursor
    rts
// end print_div_mode_msg 

print_invalid_mode_msg:
    lda #<invalid_mode_msg
    ldy #>invalid_mode_msg
    jsr print_at_cursor
    jmp get_operation
// end print_invalid_mode_msg
// ---------------------------------------------------------
// Variables
// ---------------------------------------------------------

welcome_msg: 
    .text ">>>>>>>>>>> WELCOME TO CALC! <<<<<<<<<<<"
    .byte $00

footer_msg: 
    .text "OCTRONIC"
    .byte $00

prompt_msg:
    .text "PLEASE CHOOSE AN OPERATION"
    .byte $00

quit_msg:
    .byte $5F
    .text ". BACK TO BASIC"
    .byte $00


add_msg:
    .text "1. ADD"
    .byte $00

add_mode_msg:
    .text "ADD MODE                                "
    .byte $00

sub_msg:
    .text "2. SUBTRACT"
    .byte $00

sub_mode_msg:
    .text "SUBTRACT MODE                           "
    .byte $00

mul_msg:
    .text "3. MULTIPLY"
    .byte $00

mul_mode_msg:
    .text "MULTIPLY MODE                           "
    .byte $00

div_msg:
    .text "4. DIVIDE"
    .byte $00

div_mode_msg:
    .text "DIVIDE MODE                             "
    .byte $00

invalid_mode_msg:
    .text "INVALID MODE                            "
    .byte $00

prompt_char:
    .text ">"
    .byte $00
