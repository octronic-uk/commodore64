// =========================================================
//               __                                       
//              /\ \__                       __           
//   ___     ___\ \ ,_\  _ __   ___     ___ /\_\    ___   
//  / __`\  /'___\ \ \/ /\`'__\/ __`\ /' _ `\/\ \  /'___\ 
// /\ \L\ \/\ \__/\ \ \_\ \ \//\ \L\ \/\ \/\ \ \ \/\ \__/ 
// \ \____/\ \____\\ \__\\ \_\\ \____/\ \_\ \_\ \_\ \____\
//  \/___/  \/____/ \/__/ \/_/ \/___/  \/_/\/_/\/_/\/____/
//
// game_of_life.s
//
//    Conway's Game of Life
// 
//    Every cell interacts with its eight neighbours, which are 
//    the cells that are horizontally, vertically, or diagonally
//    adjacent. At each step in time, the following transitions
//    occur:
//
//      1. Any live cell with fewer than two live neighbours dies,
//         as if caused by under-population.
//
//      2. Any live cell with two or three live neighbours lives
//         on to the next generation.
//
//      3. Any live cell with more than three live neighbours dies,
//         as if by over-population.
//
//      4. Any dead cell with exactly three live neighbours becomes
//         a live cell, as if by reproduction.
//
//    The initial pattern constitutes the seed of the system.
//    The first generation is created by applying the above rules
//    simultaneously to every cell in the seed—births and deaths
//    occur simultaneously, and the discrete moment at which this
//    happens is sometimes called a tick (in other words, each
//    generation is a pure function of the preceding one). The
//    rules continue to be applied repeatedly to create further
//    generations.
//
// Ref: https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
//
// =========================================================

#import "../include/screen.s"
#import "../include/colours.s"
#import "../include/keymap.s"
#import "../include/io.s"
#import "../include/sid.s"
#import "../include/strlen.s"

BasicUpstart2(main)
    *=4000 "GameOfLife"

// RNG Function
.const rng = $E09A
// Welcome screen text rows
.const welcome_msg_row = $09
.const enter_msg_row = $0b
.const quit_msg_row = $0D
.const at_symbol = $80
// Pointer to current screen position
.const screen_ptr_lsb  = $80
.const screen_ptr_msb  = $81
// Pointer to address of cell currently being tested
// e.g. top_left, bottom_right, etc..
.const test_cell_lsb = $82
.const test_cell_msb = $83
// Pointer to where to store results for current screen
// ptr. This will be num living neighbours
.const result_cell_lsb = $84
.const result_cell_msb = $85
// Character of cell before change
.const cell_was = $86
// Misc Constants
.const temp_1 = $7000
.const living_cell_char = $51
.const dead_cell_char  = $20

.const is_alive = $F6
.const alive = $FF
.const dead  = $00

// Main ====================================================
    main: 
        jsr welcome_screen
        jsr setup
        jsr loop
        brk

// Welcome Screen ==========================================
    welcome_screen:
        jsr screen_clear
        // Welcome
        // Get String len
        lda #<welcome_msg
        sta strlen_lsb
        lda #>welcome_msg
        sta strlen_msb
        jsr strlen
        // strlen/2
        txa
        lsr
        sta temp_1
        // screen_width/2
        lda #screen_width
        lsr
        // minus strlen/2
        sbc temp_1
        // Plot to welcome x,y and print
        ldx #welcome_msg_row
        tay
        clc
        jsr screen_cursor
        lda #<welcome_msg
        ldy #>welcome_msg
        jsr screen_print
        // Enter to start
        // get strlen
        lda #<enter_msg
        sta strlen_lsb
        lda #>enter_msg
        sta strlen_msb
        jsr strlen
        // strlen/2
        txa
        lsr
        sta temp_1
        // screen_w/2
        lda #screen_width
        lsr
        sbc temp_1
        // plot to enter_msg x,y and print
        ldx #enter_msg_row
        tay
        clc
        jsr screen_cursor
        lda #<enter_msg
        ldy #>enter_msg
        jsr screen_print
        // Q to Quit
        // get strlen
        lda #<quit_msg
        sta strlen_lsb
        lda #>quit_msg
        sta strlen_msb
        jsr strlen
        // strlen/2
        txa
        lsr
        sta temp_1
        // screen_w/2
        lda #screen_width
        lsr
        sbc temp_1
        // plot to quit_msg x,y and print
        ldx #quit_msg_row
        tay
        clc
        jsr screen_cursor
        lda #<quit_msg
        ldy #>quit_msg
        jsr screen_print
    _welcome_wait_for_return:
        jsr io_getin
        cmp #key_return
        bne _welcome_wait_for_return
        rts

// Setup ===================================================
    setup:
        jsr screen_clear
        jsr generate_seed
        rts

// Generate Seed ===========================================
    generate_seed:
        lda #<screen_start
        sta screen_ptr_lsb
        lda #>screen_start
        sta screen_ptr_msb
    _generate_seed_loop:
        // Random Number Gen
        lda #$00
        jsr rng
        lda $64
        sta temp_1
        // bitmask to reduce frequency
        and #%00000010
        cmp #%00000010
        bne _next_seed
        ldx #$00
        lda #living_cell_char
        sta (screen_ptr_lsb,x)
    _next_seed:
        // Increment screen position
        // lsb
        clc
        lda screen_ptr_lsb
        adc #$01
        sta screen_ptr_lsb
        // msb
        lda screen_ptr_msb
        adc #$00
        sta screen_ptr_msb
        // Check we have reached the end
        lda screen_ptr_lsb
        cmp #<screen_end+1
        bne _generate_seed_loop
        lda screen_ptr_msb
        cmp #>screen_end+1
        bne _generate_seed_loop
        rts

// Loop ====================================================
    loop:
        jsr do_sim
        jsr results_to_screen
        jsr io_getin
        cmp #key_back
        bne _loop_check_q
        jmp main
    _loop_check_q: 
        cmp #key_q
        bne loop 
        rts

// Pause Long ==============================================
    pause_long:
        ldx #0
    _pause_long_x:
        ldy #0
    _pause_long_y:
        iny
        cpy #255
        bne _pause_long_y
        inx
        cpx #255
        bne _pause_long_x
        rts

// Pause Short =============================================
    pause_short:
        ldx #0
    _pause_short_x:
        inx
        cpx #255
        bne _pause_short_x
        rts

// HighlightTestCell =======================================
    highlight_test_cell:
        ldx #0
        lda (test_cell_lsb,x)
        sta cell_was
        lda #at_symbol
        sta (test_cell_lsb,x)
        jsr pause_short
        ldx #0
        lda cell_was
        sta (test_cell_lsb,x)
        rts

// InitResultCell ==========================================
    init_result_cell:
        clc
        // lsb
        lda screen_ptr_lsb
        //adc #<$7000
        sta result_cell_lsb
        // msb
        lda screen_ptr_msb
        adc #>$7000
        sta result_cell_msb
        // zero init
        ldx #0
        lda #0
        sta (result_cell_lsb,x)
        rts

// IncrementResultCell =====================================
    increment_result_cell:
        ldx #0
        lda (result_cell_lsb,x)
        clc
        adc #1
        sta (result_cell_lsb,x)
        rts

// Do Simulation ===========================================
    do_sim:
        // Location of screen memory.
        lda #<screen_start
        sta screen_ptr_lsb
        lda #>screen_start
        sta screen_ptr_msb
    _do_sim_next:
        // Compare the 8 neighbours of the cell.
        // -------------
        // | N | N | N |  Where:
        // -------------    T = Target/Current cell
        // | N | T | N |    N = Neighbour
        // -------------
        // | N | N | N |
        // -------------
        // Using the following Offsets
        // -------------
        // |-41|-40|-39|
        // -------------
        // |-01|-T-|+01|
        // -------------
        // |+39|+40|+41|
        // -------------
        // New state of the cell will be saved at
        // screen_ptr + $7000
        // by adding $70 to screen_ptr_msb
        // Result for screen start at $0400 becomes $7400
        // Result for screen end  at  $07e7 becomes $77e7

        // set / initialise result location
    _do_sim_init_result:
        jsr init_result_cell
    _do_sim_top_left:
        sec
        lda screen_ptr_lsb
        sbc #41
        sta test_cell_lsb
        lda screen_ptr_msb
        sbc #0
        sta test_cell_msb
        //jsr highlight_test_cell
        // is it set?
        ldx #0
        lda (test_cell_lsb,x)
        cmp #living_cell_char
        bne _do_sim_top
        jsr increment_result_cell

    _do_sim_top:
        sec
        lda screen_ptr_lsb
        sbc #40
        sta test_cell_lsb
        lda screen_ptr_msb
        sbc #0
        sta test_cell_msb
        //jsr highlight_test_cell
        // is it set?
        ldx #0
        lda (test_cell_lsb,x)
        cmp #living_cell_char
        bne _do_sim_top_right
        jsr increment_result_cell

    _do_sim_top_right:
        sec
        lda screen_ptr_lsb
        sbc #39
        sta test_cell_lsb
        lda screen_ptr_msb
        sbc #0
        sta test_cell_msb
        //jsr highlight_test_cell
        // is it set?
        ldx #0
        lda (test_cell_lsb,x)
        cmp #living_cell_char
        // No
        bne _do_sim_left
        // Yes
        jsr increment_result_cell
    _do_sim_left:
        sec
        lda screen_ptr_lsb
        sbc #1
        sta test_cell_lsb
        lda screen_ptr_msb
        sbc #0
        sta test_cell_msb
        //jsr highlight_test_cell
        // is it set?
        ldx #0
        lda (test_cell_lsb,x)
        cmp #living_cell_char
        // No
        bne _do_sim_right
        // Yes
        jsr increment_result_cell
    _do_sim_right:
        clc
        lda screen_ptr_lsb
        adc #1
        sta test_cell_lsb
        lda screen_ptr_msb
        adc #0
        sta test_cell_msb
        //jsr highlight_test_cell
        // is it set?
        ldx #0
        lda (test_cell_lsb,x)
        cmp #living_cell_char
        // No
        bne _do_sim_bottom_left
        // Yes
        jsr increment_result_cell
    _do_sim_bottom_left:
        clc
        lda screen_ptr_lsb
        adc #39
        sta test_cell_lsb
        lda screen_ptr_msb
        adc #0
        sta test_cell_msb
        //jsr highlight_test_cell
        // is it set?
        ldx #0
        lda (test_cell_lsb,x)
        cmp #living_cell_char
        // No
        bne _do_sim_bottom
        // Yes
        jsr increment_result_cell
    _do_sim_bottom:
        clc
        lda screen_ptr_lsb
        adc #40
        sta test_cell_lsb
        lda screen_ptr_msb
        adc #0
        sta test_cell_msb
        //jsr highlight_test_cell
        // is it set?
        ldx #0
        lda (test_cell_lsb,x)
        cmp #living_cell_char
        // No
        bne _do_sim_bottom_right
        // Yes
        jsr increment_result_cell
    _do_sim_bottom_right:
        clc
        lda screen_ptr_lsb
        adc #41
        sta test_cell_lsb
        lda screen_ptr_msb
        adc #0
        sta test_cell_msb
        //jsr highlight_test_cell
        // is it set?
        ldx #0
        lda (test_cell_lsb,x)
        cmp #living_cell_char
        // No
        bne _do_sim_done
        // Yes
        jsr increment_result_cell
    _do_sim_done:
        jsr test_rules
    _do_sim_inc_screen:
        clc
        lda screen_ptr_lsb
        adc #1
        sta screen_ptr_lsb
        lda screen_ptr_msb
        adc #0
        sta screen_ptr_msb
        // Check if we have reached the end of the screen
        lda screen_ptr_lsb
        cmp #<screen_end+1
        beq _do_sim_check_msb
        jmp _do_sim_next
    _do_sim_check_msb:
        lda screen_ptr_msb
        cmp #>screen_end+1
        beq _do_sim_complete
        jmp _do_sim_next
    _do_sim_complete:
        rts

// Test Rules ==============================================
    test_rules:
    _test_rules_is_cell_alive:
        ldx #0
        lda (screen_ptr_lsb,x)
        cmp #living_cell_char
        bne _test_rules_reproduction
    _test_rules_underpopulation:
        // 1. Underpopulation - alive and <2 neighbours = dead
        ldx #0
        lda (result_cell_lsb,x)
        cmp #2
        bcs _test_rules_survive 
        lda #dead_cell_char
        sta (result_cell_lsb,x)
        jmp _test_rules_done
    _test_rules_survive:
        // 2. Survive - alive and 2 or 3 neighbours = alive
        ldx #0
        lda (result_cell_lsb,x)
        cmp #2
        bne _test_rules_survive_3
        lda #living_cell_char
        sta (result_cell_lsb,x)
        jmp _test_rules_done
    _test_rules_survive_3:
        cmp #3
        bne _test_rules_overcrowding
        lda #living_cell_char
        sta (result_cell_lsb,x)
        jmp _test_rules_done
    _test_rules_overcrowding:
        // 3. Overcrowding - alive with >3 neighbours = dead
        ldx #0
        lda (result_cell_lsb,x)
        cmp #4
        bcs _test_rules_set_dead
        lda #living_cell_char
        sta (result_cell_lsb,x)
        jmp _test_rules_done
    _test_rules_reproduction:
        // 4. Reproduction - dead with 3 neighbours = alive
        ldx #0
        lda (result_cell_lsb,x)
        cmp #3
        bne _test_rules_set_dead
        lda #living_cell_char
        sta (result_cell_lsb,x)
        jmp _test_rules_done
    _test_rules_set_dead:
        lda #dead_cell_char
        sta (result_cell_lsb,x)
    _test_rules_done:
        rts

// Results to Screen =======================================
    results_to_screen:
        // init results cell
        lda #<$7400
        sta result_cell_lsb
        lda #>$7400
        sta result_cell_msb
        // init screen pointer
        lda #<screen_start
        sta screen_ptr_lsb
        lda #>screen_start
        sta screen_ptr_msb
    _results_to_screen_next:
        // set from result
        ldx #0
        lda (result_cell_lsb,x)
        sta (screen_ptr_lsb,x)
        // screen result pointer
        clc
        lda screen_ptr_lsb
        adc #1
        sta screen_ptr_lsb
        lda screen_ptr_msb
        adc #0
        sta screen_ptr_msb
        // increment results pointer
        clc
        lda result_cell_lsb
        adc #1
        sta result_cell_lsb
        lda result_cell_msb
        adc #0
        sta result_cell_msb
        // Check for end of screen
        lda screen_ptr_lsb
        cmp #<screen_end+1
        bne _results_to_screen_next
        lda screen_ptr_msb
        cmp #>screen_end+1
        bne _results_to_screen_next
        rts

// Memory Allocations ======================================
    welcome_msg:
        .text "ASH'S GAME OF LIFE"
        .byte $00

    enter_msg:
        .text "PRESS 'RETURN' TO START"
        .byte  $00

    quit_msg:
        .text "PRESS 'Q' TO QUIT"
        .byte $00
