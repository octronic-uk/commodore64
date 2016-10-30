//----------------------------------------------------------
// js_test.s
//     A small utility to test the joystick
//----------------------------------------------------------

#import "include/keymap.s"
#import "include/joystick.s"
#import "include/colours.s"
#import "include/util.s"

.const text_colour = $0286
.const js_data     = $00

BasicUpstart2(main)
    *=4000 "JsTest"

//----------------------------------------------------------
// Program Entry Point
//----------------------------------------------------------
main: 
    jsr clear_screen
    jsr print_welcome
    
main_loop:
    lda js_port_1
    sta js_data

    lda #js_up
    bit js_data
    beq print_up_msg
after_up:

    lda #js_down
    bit js_data
    beq print_down_msg
after_down:

    lda #js_left
    bit js_data
    beq print_left_msg
after_left:

    lda #js_right
    bit js_data
    beq print_right_msg
after_right:

    lda #js_fire
    bit js_data
    beq print_fire_msg
after_fire:

    jmp main_loop

print_up_msg:
    lda #red 
    sta text_colour
    lda #<up_msg
    ldy #>up_msg
    jsr print_at_cursor
    jmp after_up

print_down_msg:
    lda #green
    sta text_colour
    lda #<down_msg
    ldy #>down_msg
    jsr print_at_cursor
    jmp after_down

print_left_msg:
    lda #orange
    sta text_colour
    lda #<left_msg
    ldy #>left_msg
    jsr print_at_cursor
    jmp after_left

print_right_msg:
    lda #yellow 
    sta text_colour
    lda #<right_msg
    ldy #>right_msg
    jsr print_at_cursor
    jmp after_right

print_fire_msg:
    lda #cyan 
    sta text_colour
    lda #<fire_msg
    ldy #>fire_msg
    jsr print_at_cursor
    jmp after_fire

print_welcome:
    lda #<welcome_msg
    ldy #>welcome_msg
    jsr print_at_cursor
    rts

fire_msg:
    .text "FIRE!"
    .byte key_return, $00

up_msg:
    .text "UP"
    .byte key_return, $00

down_msg:
    .text "DOWN"
    .byte key_return, $00

left_msg:
    .text "LEFT"
    .byte key_return, $00

right_msg:
    .text "RIGHT"
    .byte key_return, $00

welcome_msg:
    .text "> JS TEST"
    .byte key_return,  $00
