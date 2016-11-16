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
    .const TRUE  = $FF
    .const FALSE = $00
    .const blocks_start_row     = screen_row_2
    .const blocks_start_colour_row = screen_colour_row_2
    .const blocks_end_row       = screen_row_9
    .const screen_msb           = $6F
    .const screen_lsb           = $6E
    .const screen_colour_msb    = $6D
    .const screen_colour_lsb    = $6C
    .const block_colour         = $6B
    .const paddle_offset_x      = $6A
    .const ball_offset_x        = $69
    .const ball_msb             = $68
    .const ball_lsb             = $67
    .const ball_colour_msb      = $66
    .const ball_colour_lsb      = $65
    .const ball_direction       = $64
    .const game_started         = $63
    .const game_over            = $62
    .const ball_last_msb        = $61
    .const ball_last_lsb        = $60
    .const ball_last_colour_msb = $5F
    .const ball_last_colour_lsb = $5E
    .const ball_last_char       = $5D
    .const ball_last_colour     = $5C
    .const paddle_moved         = $5A
    .const paddle_offset_x_last = $50
    .const score_msb = $7001
    .const score_lsb = $7000
    .const red_score    = 5
    .const orange_score = 10
    .const yellow_score = 15
    .const green_score  = 20
    .const blue_score   = 25
    .const paddle_row        = screen_row_24
    .const paddle_colour_row = screen_colour_row_24
    .const paddle_colour     = light_blue
    .const bg_colour         = grey_1
    .const border_colour     = black
    .const ball_dir_none  = $00
    .const ball_dir_up    = $01 
    .const ball_dir_down  = $02
    .const ball_dir_left  = $04
    .const ball_dir_right = $08 
    .const ball_colour      = white
    .const space_char       = $20
    .const block_char       = $EF
    .const paddle_char      = $A0
    .const block_char_right = $FA
    .const ball_char        = $51
    .const paddle_width     = 11
    .const port_a     = $DC00 // CIA#1 (Port Register A)
    .const port_b     = $DC01 // CIA#1 (Port Register B)
    .const data_dir_a = $DC02 // CIA#1 (Data Direction Register A)
    .const data_dir_b = $DC03 // CIA#1 (Data Direction Register B)

    .const joystick_up    = $01
    .const joystick_down  = $02
    .const joystick_left  = $04
    .const joystick_right = $08
    .const joystick_fire  = $10

// Program Entry Point
    main: 
        lda #FALSE
        sta game_over
        jsr screen_clear
        jsr set_bg_colour
        jsr setup_score
        jsr setup_paddle
        jsr draw_paddle
        jsr setup_ball
        jsr setup_blocks
    _main_loop:
        lda #FALSE
        sta paddle_moved
        jsr get_input
        cli
        jsr update_ball
        jsr update_paddle
        jsr update_score
        ldx #18 // num pause loops
        jsr pause
        lda game_over
        cmp #TRUE
        bne _main_loop
        cli
        lda #FALSE
        sta game_started
        jmp main

// Long Pause
    long_pause:
        ldx #0
    _long_pause_loop_x:
        ldy #0
    _long_pause_loop_y:
        iny
        cpy #255
        bne _long_pause_loop_y
        inx
        cpx #255
        bne _long_pause_loop_x
        rts

// Long Pause
    pause:
    _pause_loop_x:
        ldy #255
    _pause_loop_y:
        dey
        cpy #0
        bne _pause_loop_y
        dex
        cpx #0
        bne _pause_loop_x
        rts

// Black Screen
    set_bg_colour:
        lda #bg_colour
        sta background_colour_ptr
        lda #border_colour
        sta border_colour_ptr
        rts

// Setup Score
    setup_score:
        // Init score counter
        lda #00
        sta score_lsb
        sta score_msb
        // Print 'score' text
        lda #<screen_start
        sta screen_lsb
        lda #>screen_start
        sta screen_msb
        lda #<screen_colour_row_0
        sta screen_colour_lsb
        lda #>screen_colour_row_0
        sta screen_colour_msb

        ldy #00
    _setup_score_print_text:
        lda #white
        sta (screen_colour_lsb),y
        lda score,y
        sta (screen_lsb),y
        iny
        lda score,y
        cmp #$00
        bne _setup_score_print_text
        rts

// Draw Blocks
    setup_blocks:
        // Store screen ptr
        lda #<blocks_start_row
        sta screen_lsb
        lda #>blocks_start_row
        sta screen_msb
        // Store screen colour ptr
        lda #<blocks_start_colour_row
        sta screen_colour_lsb
        lda #>blocks_start_colour_row
        sta screen_colour_msb
        // init block colour
        lda #0
        sta block_colour
    _setup_blocks_next:
        jsr draw_block_line
        jsr next_block_line
        // stop at half way point
        lda screen_lsb
        cmp #<blocks_end_row
        bcc _setup_blocks_next
        lda screen_msb
        cmp #>blocks_end_row
        bcc _setup_blocks_next
        rts

// Draw Block Line
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
        cpx #screen_width
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

// Next Block Line
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
        lda game_over
        cmp #TRUE
        bne _next_colour_not_game_over
        lda #grey_1
        sta block_colour
        rts
    _next_colour_not_game_over:
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
        lda #FALSE
        sta paddle_moved
        // (screen_w/2) - (paddle_w/2) = paddle_offset_x
        lda #paddle_width
        lsr
        sta paddle_offset_x
        lda #screen_width
        lsr
        sec
        sbc paddle_offset_x
        sta paddle_offset_x
        sta paddle_offset_x_last
        rts

// Update Paddle
    update_paddle:
        lda paddle_moved
        cmp #TRUE
        bne _update_paddle_done
        jsr erase_paddle
        jsr draw_paddle
    _update_paddle_done:
        rts

// Erase Paddle
    erase_paddle:
        // Check for change
        lda paddle_offset_x
        cmp paddle_offset_x_last
        beq _erase_paddle_done
        // Set position
        lda #<paddle_row
        sta screen_lsb
        lda #>paddle_row
        sta screen_msb
        lda screen_lsb
        clc
        adc paddle_offset_x_last
        sta screen_lsb
        lda screen_msb
        adc #0
        sta screen_msb
        // Clear paddle
        ldy #00
    _erase_paddle_clear_next:
        lda #space_char
        sta (screen_lsb),y
        iny
        cpy #paddle_width
        bne _erase_paddle_clear_next
    _erase_paddle_done:
        rts

// Draw Paddle
    draw_paddle:
        // Set position
        lda #<paddle_row
        sta screen_lsb
        lda #>paddle_row
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
        lda #<paddle_colour_row
        sta screen_colour_lsb
        lda #>paddle_colour_row
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
        lda #paddle_char
        sta (screen_lsb),y
        lda #paddle_colour
        sta (screen_colour_lsb),y
        iny
        cpy #paddle_width
        bne _draw_paddle_chars
        rts

// Draw Ball
    draw_ball:
        ldy #0
        // Set Char
        lda (ball_lsb),y
        sta ball_last_char
        lda #ball_char
        sta (ball_lsb),y
        // ball_colour
        lda (ball_colour_lsb),y
        sta ball_last_colour
        lda #ball_colour
        sta (ball_colour_lsb),y
        rts

// Setup Ball
    setup_ball:
        lda #space_char
        sta ball_last_char
        // Direction
        lda #00
        sta ball_direction
        // Position
        lda #screen_width
        lsr
        sta ball_offset_x
        // ball_char location
        lda #<screen_row_23
        clc
        adc ball_offset_x
        sta ball_lsb
        lda #>screen_row_23
        adc #0
        sta ball_msb
        // ball_colour
        lda #<screen_colour_row_23
        clc
        adc ball_offset_x
        sta ball_colour_lsb
        lda #>screen_colour_row_23
        adc #0
        sta ball_colour_msb
        jsr store_ball_last
        rts

// Store Ball Last
    store_ball_last:
        // Store last position
        lda ball_lsb
        sta ball_last_lsb
        lda ball_msb
        sta ball_last_msb
        // Store last Colour
        lda ball_colour_lsb
        sta ball_last_colour_lsb
        lda ball_last_msb
        sta ball_last_colour_msb
        rts

// Update Ball
    update_ball:
        // Save last position
        lda ball_lsb
        sta ball_last_lsb
        lda ball_msb
        sta ball_last_msb
        // Save last colour
        lda ball_colour_lsb
        sta ball_last_colour_lsb
        lda ball_colour_msb
        sta ball_last_colour_msb
        jsr check_ball_collision
        jsr move_ball
        // Check if redraw required
        lda ball_last_msb
        cmp ball_msb
        beq _update_ball_draw
        lda ball_last_lsb
        cmp ball_lsb
        bne _update_ball_draw
    _update_ball_draw:
        jsr erase_last_ball
        jsr draw_ball
    _update_ball_done:
        rts

// Update Score
    update_score:
        rts

// Check Ball Collision
    check_ball_collision:
        jsr check_ball_side_collision 
        jsr check_ball_dead_collision
        jsr check_ball_block_collision
        jsr check_ball_paddle_collision
        rts

// Check Ball Paddle Collision
    check_ball_paddle_collision:
        // Get paddle collision position
        // (paddle_row-screen_width)+x_offset
        //      
        //    ,------ o = Ball
        // ***o*** <- Collision Area
        // ======= <- Paddle
        // X = lsb
        // Y = msb
    
        // Check ball is moving down
        lda ball_direction
        and #ball_dir_down
        cmp #ball_dir_down
        bne _check_ball_paddle_collision_done
        // Yes, moving down    
        lda #<paddle_row
        sec
        sbc #screen_width
        tax
        lda #>paddle_row
        sbc #0
        tay
        txa
        clc
        adc paddle_offset_x
        tax
        tya
        adc #0
        tay
        // Check msb
        cpy ball_msb
        bne _check_ball_paddle_collision_done
        // Check lsb
        ldy #paddle_width
        iny
    _check_ball_paddle_collision_next_lsb:
        cpx ball_lsb
        beq _check_ball_paddle_collision_true
        inx
        dey
        cpy #0
        bne _check_ball_paddle_collision_next_lsb
        jmp _check_ball_paddle_collision_done
    _check_ball_paddle_collision_true:
        jsr flip_y_direction
    _check_ball_paddle_collision_done:
        rts

// Check ball side collision
    check_ball_side_collision:
        jsr check_ball_top_collision
        jsr check_ball_left_collision
        jsr check_ball_right_collision
        rts

// Check ball left collision
    check_ball_left_collision:
        lda #<screen_start
        sta screen_lsb
        lda #>screen_start
        sta screen_msb
        ldx #0
    _check_ball_left_collision_next:
        lda ball_msb
        cmp screen_msb 
        bne _check_ball_left_collision_incr
        lda ball_lsb
        cmp screen_lsb
        bne _check_ball_left_collision_incr
        jsr flip_x_direction
        jmp _check_ball_left_collision_done
    _check_ball_left_collision_incr:
        inx
        cpx #25
        beq _check_ball_left_collision_done
        lda screen_lsb
        clc
        adc #screen_width
        sta screen_lsb
        lda screen_msb
        adc #0
        sta screen_msb
        jmp _check_ball_left_collision_next
    _check_ball_left_collision_done:
        rts

// Check ball right collision
    check_ball_right_collision:
        lda #<screen_start
        clc
        adc #39
        sta screen_lsb
        lda #>screen_start
        adc #0
        sta screen_msb
        ldx #0
    _check_ball_right_collision_next:
        lda ball_msb
        cmp screen_msb 
        bne _check_ball_right_collision_incr
        lda ball_lsb
        cmp screen_lsb
        bne _check_ball_right_collision_incr
        jsr flip_x_direction
    _check_ball_right_collision_incr:
        inx
        cpx #25
        beq _check_ball_right_collision_done
        lda screen_lsb
        clc
        adc #screen_width
        sta screen_lsb
        lda screen_msb
        adc #0
        sta screen_msb
        jmp _check_ball_right_collision_next
    _check_ball_right_collision_done:
        rts

// Check ball top collision
    check_ball_top_collision:
        ldy #00
        lda ball_msb
        cmp #>screen_row_1
        bne _check_ball_top_collision_done
        lda ball_lsb
        cmp #<screen_row_1
        bcs _check_ball_top_collision_done
        // change upwards to downwards
        jsr flip_y_direction 
    _check_ball_top_collision_done:
        rts

// flip x direction
    flip_x_direction:
        lda ball_direction
        eor #ball_dir_left
        eor #ball_dir_right
        sta ball_direction 
        rts

// flip y direction
    flip_y_direction:
        lda ball_direction
        eor #ball_dir_up
        eor #ball_dir_down
        sta ball_direction 
        rts

// Check ball dead collision
    check_ball_dead_collision:
        lda ball_msb
        cmp #>screen_end
        bcc _collision_ball_dead_return
        lda ball_lsb
        cmp #<screen_end
        bcc _collision_ball_dead_return
        lda #TRUE
        sta game_over
    _collision_ball_dead_return:
        rts

// check ball block collision
    check_ball_block_collision:
        // Only check when ball is going up
        lda ball_direction
        and #ball_dir_up
        cmp #ball_dir_up
        bne _check_ball_block_collision_done
        // get ball pos into screen pointer
        lda ball_lsb
        sta screen_lsb
        lda ball_msb
        sta screen_msb
        // check above ball
        lda screen_lsb
        sec
        sbc #screen_width
        sta screen_lsb
        lda screen_msb
        sbc #0
        sta screen_msb
        // get char above ball
        ldy #0
        lda (screen_lsb),y
        // is it a block char?
        cmp #block_char
        beq _check_ball_block_collision_true
        // or the right block char?
        cmp #block_char_right
        beq _check_ball_block_collision_true
        jmp _check_ball_block_collision_done
    _check_ball_block_collision_true:
        jsr add_score 
        jsr remove_block
        jsr flip_y_direction
    _check_ball_block_collision_done:
        rts

// Add Score
    add_score:
        // Get colour ram position above ball
        lda ball_colour_lsb
        sec
        sbc #screen_width
        sta screen_colour_lsb
        lda ball_colour_msb
        sbc #0
        sta screen_colour_msb
        ldy #0
        // Read Value
        lda (screen_colour_lsb),y
        cmp #red
        beq _add_score_red
        cmp #orange
        beq _add_score_orange
        cmp #yellow
        beq _add_score_yellow
        cmp #green
        beq _add_score_green
        cmp #blue
        beq _add_score_blue
        rts
    _add_score_red:
        lda score_lsb
        clc
        adc red_score
        sta score_lsb
        lda score_msb
        adc #0
        sta score_msb
        rts
    _add_score_orange:
        lda score_lsb
        clc
        adc orange_score
        sta score_lsb
        lda score_msb
        adc #0
        sta score_msb
        rts
    _add_score_yellow:
        lda score_lsb
        clc
        adc yellow_score
        sta score_lsb
        lda score_msb
        adc #0
        sta score_msb
        rts
    _add_score_green:
        lda score_lsb
        clc
        adc green_score
        sta score_lsb
        lda score_msb
        adc #0
        sta score_msb
        rts
    _add_score_blue:
        lda score_lsb
        clc
        adc blue_score
        sta score_lsb
        lda score_msb
        adc #0
        sta score_msb
        rts

// Remove Bolck
    remove_block:
        ldy #0
        lda (screen_lsb),y
        cmp #block_char
        beq _remove_block_find_right
        cmp #block_char_right
        beq _remove_block_found_right
        jmp _remove_block_done
    _remove_block_find_right:
        ldy #0
    _remove_block_find_right_next:
        lda (screen_lsb),y
        cmp #block_char_right
        beq _remove_block_found_right
        lda screen_lsb
        clc
        adc #1
        sta screen_lsb
        lda screen_msb
        adc #0
        sta screen_msb
        jmp _remove_block_find_right_next
    _remove_block_found_right: 
        // Go back to block char 1 (sorry)
        lda screen_lsb
        sec
        sbc #3
        sta screen_lsb
        lda screen_msb
        sbc #0
        sta screen_msb
        ldy #0
    _remove_block_from_right:
        lda #space_char
        sta (screen_lsb),y
        iny
        cpy #4
        bne _remove_block_from_right
    _remove_block_done:
        rts

// Erase Ball
    erase_last_ball:
        ldy #0
        lda ball_last_char
        sta (ball_last_lsb),y
        lda ball_last_colour
        sta (ball_last_colour_lsb),y
        rts

// Move Ball
    // $01 = UP
    // $02 = DOWN
    // $04 = LEFT
    // $08 = RIGHT
    move_ball:
        // Up
        lda ball_direction
        and #ball_dir_up
        cmp #ball_dir_up
        beq _move_ball_up
        // Down
        lda ball_direction
        and #ball_dir_down
        cmp #ball_dir_down
        beq _move_ball_down
        // Neither
        jmp _move_ball_x
    _move_ball_up:
        // Position
        lda ball_lsb
        sec
        sbc #screen_width
        sta ball_lsb
        lda ball_msb
        sbc #00
        sta ball_msb
        // Colour
        lda ball_colour_lsb
        sec
        sbc #screen_width
        sta ball_colour_lsb
        lda ball_colour_msb
        sbc #00
        sta ball_colour_msb
        jmp _move_ball_x
    _move_ball_down:
        // Position
        lda ball_lsb
        clc
        adc #screen_width
        sta ball_lsb
        lda ball_msb
        adc #00
        sta ball_msb
        // Colour
        lda ball_colour_lsb
        clc
        adc #screen_width
        sta ball_colour_lsb
        lda ball_colour_msb
        adc #00
        sta ball_colour_msb
        jmp _move_ball_x
    _move_ball_x:
        // left
        lda ball_direction
        and #ball_dir_left
        cmp #ball_dir_left
        beq _move_ball_left
        // right
        lda ball_direction
        and #ball_dir_right
        cmp #ball_dir_right
        beq _move_ball_right
        // Neither
        jmp _move_ball_done
    _move_ball_left:
        // Position
        lda ball_lsb
        sec
        sbc #1
        sta ball_lsb
        lda ball_msb
        sbc #00
        sta ball_msb
        // Colour
        lda ball_colour_lsb
        sec
        sbc #1
        sta ball_colour_lsb
        lda ball_colour_msb
        sbc #00
        sta ball_colour_msb
        jmp _move_ball_done
    _move_ball_right:
        // Position
        lda ball_lsb
        clc
        adc #1
        sta ball_lsb
        lda ball_msb
        adc #00
        sta ball_msb
        // Colour
        lda ball_colour_lsb
        clc
        adc #1
        sta ball_colour_lsb
        lda ball_colour_msb
        adc #00
        sta ball_colour_msb
        jmp _move_ball_done
    _move_ball_done:
        rts
        
// Get Input
    get_input:
        sei
        lda #%11111111 // CIA#1 port A = outputs 
        sta data_dir_a        
        lda #%00000000 // CIA#1 port B = inputs
        sta data_dir_b  
        // Check for A Key
        lda #%11111101 // testing column kb-mat
        sta port_a
        lda port_b
        and #%00000100
        beq _get_input_a
        // Check for D key
        lda #%11111011 // testing column kb-mat
        sta port_a
        lda port_b 
        and #%00000100
        beq _get_input_d
        // Ignore space after game has started
        lda game_started
        cmp #FALSE
        bne _get_input_done
        // Check for Space key
        lda #%01111111 // testing column kb-mat
        sta port_a
        lda port_b 
        and #%00010000
        beq _get_input_space
        // No Match
        jmp _get_input_done
    _get_input_a:
        lda paddle_offset_x
        sta paddle_offset_x_last
        cmp #0
        beq _get_input_done
        lda #TRUE
        sta paddle_moved
        dec paddle_offset_x
        lda game_started 
        cmp #TRUE
        beq _get_input_a_game_started
        jsr _move_ball_left
        jsr erase_last_ball
        jsr draw_ball
    _get_input_a_game_started:
        jmp _get_input_done
    _get_input_d:
        lda #paddle_width
        sta $00
        lda paddle_offset_x
        sta paddle_offset_x_last
        clc
        adc $00
        cmp #screen_width
        beq _get_input_done
        lda #TRUE
        sta paddle_moved
        inc paddle_offset_x
        lda game_started
        cmp #TRUE
        beq _get_input_d_game_started
        jsr _move_ball_right
        jsr erase_last_ball
        jsr draw_ball
    _get_input_d_game_started:
        jmp _get_input_done
    _get_input_space:
        lda #$00
        ora #$01
        ora #$08
        sta ball_direction 
        lda #TRUE
        sta game_started
        jmp _get_input_done
    _get_input_done:
        rts

score:
    .text "score:"
    .byte $00
