// =========================================================
//               __                                       
//              /\ \__                       __           
//   ___     ___\ \ ,_\  _ __   ___     ___ /\_\    ___   
//  / __`\  /'___\ \ \/ /\`'__\/ __`\ /' _ `\/\ \  /'___\ 
// /\ \L\ \/\ \__/\ \ \_\ \ \//\ \L\ \/\ \/\ \ \ \/\ \__/ 
// \ \____/\ \____\\ \__\\ \_\\ \____/\ \_\ \_\ \_\ \____\
//  \/___/  \/____/ \/__/ \/_/ \/___/  \/_/\/_/\/_/\/____/
//
// breakout.s
//    The classic block buster game!
//
// =========================================================

// Bootstrapper
BasicUpstart2(main)
    *=4000 "Breakout"

// Imports
    #import "../include/keymap.s"
    #import "../include/io.s"
    #import "../include/screen.s"
    #import "../include/colours.s"

// Constants
    .const screen_msb        = $FF
    .const screen_lsb        = $FE
    .const screen_colour_msb = $FD
    .const screen_colour_lsb = $FC
    .const block_colour      = $FB

    .const paddle_offset_x = $FA

    .const ball_offset_x = $F9
    .const ball_msb      = $F8
    .const ball_lsb      = $F7
    .const ball_colour   = white

    .const space_char       = $20
    .const block_char       = $EF
    .const block_char_right = $FA
    .const ball_char        = $51
    .const paddle_width     = 7

    .const port_a     =  $dc00 // CIA#1 (Port Register A)
    .const port_b     =  $dc01 // CIA#1 (Port Register B)
    .const data_dir_a =  $dc02 // CIA#1 (Data Direction Register A)
    .const data_dir_b =  $dc03 // CIA#1 (Data Direction Register B)

// Program Entry Point
    main: 
        jsr screen_clear
        jsr black_screen
        jsr setup_paddle
    _main_loop:
        jsr get_input
        jsr draw_blocks
        jsr draw_paddle
        jsr draw_ball
        jsr short_pause
        jmp _main_loop

// Short pause
    short_pause:
        ldx #0
    _short_pause_loop:
        inx
        cpx #255
        bne _short_pause_loop
        rts

// Black Screen
    black_screen:
        lda #black
        sta border_colour_ptr
        sta background_colour_ptr
        rts

// Draw Blocks
    draw_blocks:
        // Store screen ptr
        lda #<screen_start
        sta screen_lsb
        lda #>screen_start
        sta screen_msb

        // Store screen colour ptr
        lda #<screen_colour_start
        sta screen_colour_lsb
        lda #>screen_colour_start
        sta screen_colour_msb

        // init block colour
        lda #0
        sta block_colour
    _draw_blocks_next:
        jsr draw_block_line
        jsr next_block_line
        // stop at half way point
        lda screen_lsb
        cmp #<screen_row_12
        bcc _draw_blocks_next
        lda screen_msb
        cmp #>screen_row_12
        bcc _draw_blocks_next
        rts

// Drwa Block Line
    draw_block_line:
        ldx #00 
    _draw_block_line_loop:
        jsr next_colour
        jsr draw_single_block
        // Move along by 5 for space+next_block
        clc
        lda screen_lsb
        adc #4
        sta screen_lsb
        lda screen_msb
        adc #0
        sta screen_msb
        clc
        lda screen_colour_lsb
        adc #4
        sta screen_colour_lsb
        lda screen_colour_msb
        adc #0
        sta screen_colour_msb
        txa
        clc
        adc #4
        tax
        cpx #40
        bne _draw_block_line_loop
        jsr next_colour
        jsr next_colour
        rts

// Draw Block
    draw_single_block:
        ldy #0 // Block memory offset
    _draw_single_block_next:
        cpy #3
        bne _draw_single_block_normal_char
        lda #block_char_right
        jmp _draw_single_block_has_char
    _draw_single_block_normal_char:
        lda #block_char
    _draw_single_block_has_char:
        sta (screen_lsb),y
        lda block_colour
        sta (screen_colour_lsb),y
        iny
        cpy #4
        bne _draw_single_block_next
        rts

// Next Block LIne
    next_block_line:
        // Position
        clc
        lda screen_lsb
        adc #0
        sta screen_lsb  
        lda screen_msb
        adc #0 
        sta screen_msb
        // Colour
        clc
        lda screen_colour_lsb
        adc #0
        sta screen_colour_lsb  
        lda screen_colour_msb
        adc #0 
        sta screen_colour_msb 
        rts

// Next Colour
//     Cycle through commodore logo colours
//     Red, Orange, Yellow, Green, Blue
    next_colour:
        lda block_colour
        cmp #red
        beq _next_colour_set_orange
        cmp #orange
        beq _next_colour_set_yellow
        cmp #yellow
        beq _next_colour_set_green
        cmp #green
        beq _next_colour_set_blue
        cmp #blue
        beq _next_colour_set_red
        // Default to red if none of the above
    _next_colour_set_red:
        lda #red
        sta block_colour
        rts
    _next_colour_set_orange:
        lda #orange
        sta block_colour
        rts
    _next_colour_set_yellow:
        lda #yellow
        sta block_colour
        rts
    _next_colour_set_green:
        lda #green
        sta block_colour
        rts
    _next_colour_set_blue:
        lda #blue
        sta block_colour
        rts

// Setup Paddle
    setup_paddle:
        // (screen_w/2) - (paddle_w/2) = paddle_offset_x
        lda #paddle_width
        lsr
        sta paddle_offset_x
        lda #screen_width
        lsr
        sec
        sbc paddle_offset_x
        sta paddle_offset_x
        rts

// Draw Paddle
    draw_paddle:
        // Set position
        lda #<screen_row_24
        sta screen_lsb
        lda #>screen_row_24
        sta screen_msb
        // Clear paddle row
        ldy #0
    _draw_paddle_clear_next:
        lda #space_char
        sta (screen_lsb),y
        iny
        cpy #40
        bne _draw_paddle_clear_next
        // Set position
        lda #<screen_row_24
        sta screen_lsb
        lda #>screen_row_24
        sta screen_msb
        // Add offset
        clc
        lda screen_lsb
        adc paddle_offset_x
        sta screen_lsb
        lda screen_msb
        adc #0
        sta screen_msb
        // Set colour
        lda #<screen_colour_row_24
        sta screen_colour_lsb
        lda #>screen_colour_row_24
        sta screen_colour_msb
        // Add Offset
        clc
        lda screen_colour_lsb
        adc paddle_offset_x
        sta screen_colour_lsb
        lda screen_colour_msb
        adc #0
        sta screen_colour_msb
        // Draw
        ldy #0
    _draw_paddle_chars:
        lda #block_char
        sta (screen_lsb),y
        lda #light_blue
        sta (screen_colour_lsb),y
        iny
        cpy #paddle_width
        bne _draw_paddle_chars
        rts

// Draw Ball
    draw_ball:
        lda #screen_width
        lsr
        sta ball_offset_x
        // ball_char
        lda #<screen_row_23
        clc
        adc ball_offset_x
        sta ball_lsb
        lda #>screen_row_23
        adc #0
        sta ball_msb
        lda #ball_char
        ldy #0
        sta (ball_lsb),y
        // ball_colour
        lda #<screen_colour_row_23
        clc
        adc ball_offset_x
        sta screen_colour_lsb
        lda #>screen_colour_row_23
        adc #0
        sta screen_colour_msb
        lda #ball_colour
        ldy #0
        sta (screen_colour_lsb),y
        rts
        
// Get Input
    get_input:
        sei
        lda #%11111111 // CIA#1 port A = outputs 
        sta data_dir_a        
        lda #%00000000 // CIA#1 port B = inputs
        sta data_dir_b  
        lda #%11111101 // testing column 1 of kb-mat
        sta port_a
        lda port_b // Debounce?
        lda port_b
        // Check for A Key
        and #%00000100
        beq _get_input_a
        // Check for D key
        lda #%11111011 // testing column 3 of kb-mat
        sta port_a
        lda port_b  // Debounce?
        lda port_b 
        and #%00000100
        beq _get_input_d
        jmp _get_input_done
    _get_input_a:
        lda paddle_offset_x
        cmp #0
        beq _get_input_done
        dec paddle_offset_x
        jmp _get_input_done
    _get_input_d:
        lda #paddle_width
        sta $00
        lda paddle_offset_x
        clc
        adc $00
        cmp #screen_width
        beq _get_input_done
        inc paddle_offset_x
    _get_input_done:
        cli
        rts
