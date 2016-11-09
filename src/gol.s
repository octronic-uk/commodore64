//----------------------------------------------------------
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
//----------------------------------------------------------

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
// Pointer to current screen position
.const screen_ptr_lsb  = $F0
.const screen_ptr_msb  = $F1
// Pointer to address of cell currently being tested
// e.g. top_left, bottom_right, etc..
.const test_cell_lsb = $F2
.const test_cell_msb = $F3
// Pointer to where to store results for current screen
// ptr. This will be num living neighbours
.const result_cell_lsb = $F4
.const result_cell_msb = $F5
// Misc Constants
.const temp_1 = $7000
.const inverted_space = $A0
.const regular_space  = $20

.const is_alive = $F6
.const alive = $FF
.const dead  = $00

//----------------------------------------------------------
// Program Entry Point
//----------------------------------------------------------
main: 
    jsr welcome_screen
    jsr setup
    jsr loop
    brk

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
welcome_wait_for_return:
    jsr io_getin
    cmp #key_return
    bne welcome_wait_for_return
    rts

setup:
    jsr screen_clear
    jsr generate_seed
    rts

generate_seed:
    lda #<screen_start
    sta screen_ptr_lsb
    lda #>screen_start
    sta screen_ptr_msb
generate_seed_loop:
// Random Number Gen
    lda #$00
    jsr rng
    lda $64
    sta temp_1
// bitmask to reduce frequency
    and #%00000110
    cmp #%00000110
    bne next_seed
    ldx #$00
    lda #inverted_space
    sta (screen_ptr_lsb,x)
next_seed:
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
    bne generate_seed_loop
    lda screen_ptr_msb
    cmp #>screen_end+1
    bne generate_seed_loop
    rts

loop:
    jsr do_simulation
    jsr results_to_screen
    jsr io_getin
    cmp #key_q
    beq loop_quit
    bne loop 
loop_quit:
    rts

do_simulation:
// Location of current screen char to test.
    lda #<screen_start
    sta screen_ptr_lsb
    lda #>screen_start
    sta screen_ptr_msb
do_simulation_next:
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
    lda screen_ptr_lsb
    sta result_cell_lsb
    clc
    lda screen_ptr_msb
    adc #$70
    sta result_cell_msb
    lda #0
    ldx #0
    sta (result_cell_lsb,x)
test_top_left:
    sec
    lda screen_ptr_lsb
    sbc #41
    sta test_cell_lsb
    lda screen_ptr_msb
    sbc #0
    sta test_cell_msb
    ldx #0
    lda (test_cell_lsb,x)
// is it set?
    cmp #inverted_space
// No
    bne test_top
    // Yes
    ldx #0
    lda (result_cell_lsb,x)
    clc
    adc #1
    sta (result_cell_lsb,x)
test_top:
    sec
    lda screen_ptr_lsb
    sbc #40
    sta test_cell_lsb
    lda screen_ptr_msb
    sbc #0
    sta test_cell_msb
    ldx #0
    lda (test_cell_lsb,x)
// is it set?
    cmp #inverted_space
// No
    bne test_top_right
// Yes
    ldx #0
    lda (result_cell_lsb,x)
    clc
    adc #1
    sta (result_cell_lsb,x)
test_top_right:
    sec
    lda screen_ptr_lsb
    sbc #39
    sta test_cell_lsb
    lda screen_ptr_msb
    sbc #0
    sta test_cell_msb
    ldx #0
    lda (test_cell_lsb,x)
// is it set?
    cmp #inverted_space
// No
    bne test_left
// Yes
    ldx #0
    lda (result_cell_lsb,x)
    clc
    adc #1
    sta (result_cell_lsb,x)
test_left:
    sec
    lda screen_ptr_lsb
    sbc #1
    sta test_cell_lsb
    lda screen_ptr_msb
    sbc #0
    sta test_cell_msb
    ldx #0
    lda (test_cell_lsb,x)
// is it set?
    cmp #inverted_space
// No
    bne test_right
// Yes
    ldx #0
    lda (result_cell_lsb,x)
    clc
    adc #1
    sta (result_cell_lsb,x)
test_right:
    clc
    lda screen_ptr_lsb
    adc #1
    sta test_cell_lsb
    lda screen_ptr_msb
    adc #0
    sta test_cell_msb
    ldx #0
    lda (test_cell_lsb,x)
// is it set?
    cmp #inverted_space
// No
    bne test_bottom_left
// Yes
    ldx #0
    lda (result_cell_lsb,x)
    clc
    adc #1
    sta (result_cell_lsb,x)
test_bottom_left:
    clc
    lda screen_ptr_lsb
    adc #39
    sta test_cell_lsb
    lda screen_ptr_msb
    adc #0
    sta test_cell_msb
    ldx #0
    lda (test_cell_lsb,x)
// is it set?
    cmp #inverted_space
// No
    bne test_bottom
// Yes
    ldx #0
    lda (result_cell_lsb,x)
    clc
    adc #1
    sta (result_cell_lsb,x)
test_bottom:
    clc
    lda screen_ptr_lsb
    adc #40
    sta test_cell_lsb
    lda screen_ptr_msb
    adc #0
    sta test_cell_msb
    ldx #0
    lda (test_cell_lsb,x)
// is it set?
    cmp #inverted_space
    // No
    bne test_bottom_right
// Yes
    lda #0
    lda (result_cell_lsb,x)
    clc
    adc #1
    sta (result_cell_lsb,x)
test_bottom_right:
    sec
    lda screen_ptr_lsb
    sbc #40
    sta test_cell_lsb
    lda screen_ptr_msb
    sbc #0
    sta test_cell_msb
    ldx #0
    lda (test_cell_lsb,x)
// is it set?
    cmp #inverted_space
// No
    bne test_done
// Yes
    lda #0
    lda (result_cell_lsb,x)
    clc
    adc #1
    sta (result_cell_lsb,x)
test_done:
    ldx #0
    lda (screen_ptr_lsb,x)
    cmp #inverted_space
    bne reproduction
// 1. Underpopulation - alive and <2 neighbours = dead
underpopulation:
    ldx #0
    lda (result_cell_lsb,x)
    sec
    sbc #2
    bcs survive 
    lda #inverted_space
    sta (result_cell_lsb,x)
    jmp inc_screen
// 2. Survive - alive and 2 or 3 neighbours = alive
survive:
    ldx #0
    lda (result_cell_lsb,x)
    cmp #2
    bne survive_with_3
    lda #inverted_space
    sta (result_cell_lsb,x)
    jmp inc_screen
survive_with_3:
    cmp #3
    bne overcrowding
    lda #inverted_space
    sta (result_cell_lsb,x)
    jmp inc_screen
// 3. Overcrowding - alive with >3 neighbours = dead
overcrowding:
    ldx #0
    lda (result_cell_lsb,x)
    sec
    sbc #3
    bcs set_dead
    lda #inverted_space
    sta (result_cell_lsb,x)
    jmp inc_screen
// 4. Reproduction - dead with 3 neighbours = alive
reproduction:
    ldx #0
    lda (result_cell_lsb,x)
    cmp #3
    lda #inverted_space
    sta (result_cell_lsb,x)
    jmp inc_screen
set_dead:
    lda #regular_space
    sta (result_cell_lsb,x)
    jmp inc_screen
// Increment screen position
inc_screen:
    clc
    lda screen_ptr_lsb
    adc #1
    sta screen_ptr_lsb
    lda screen_ptr_msb
    adc #0
    sta screen_ptr_msb
// Check we have reached the end of the screen area
    lda screen_ptr_lsb
    cmp #<screen_end+1
    beq do_simulation_check_msb
    jmp do_simulation_next
do_simulation_check_msb:
    lda screen_ptr_msb
    cmp #>screen_end+1
    beq do_simulation_complete
    jmp do_simulation_next
do_simulation_complete:

    ldx #0
pause_loop_x:
    ldy #0
pause_loop_y:
    iny
    cpy #255
    bne pause_loop_y
    inx
    cpx #64
    bne pause_loop_x
    rts

results_to_screen:
    lda #<screen_start
    sta screen_ptr_lsb 
    sta result_cell_lsb

    lda #>screen_start
    sta screen_ptr_msb

    clc
    adc #$70
    sta result_cell_msb

results_to_screen_next:
    ldx #0
    lda (result_cell_lsb,x)
    sta (screen_ptr_lsb,x)

    clc
    lda screen_ptr_lsb
    adc #1
    sta screen_ptr_lsb
    lda screen_ptr_msb
    adc #0
    sta screen_ptr_msb

    clc
    lda result_cell_lsb
    adc #1
    sta result_cell_lsb
    lda result_cell_msb
    adc #0
    sta result_cell_msb

    lda screen_ptr_lsb
    cmp #<screen_end+1
    bne results_to_screen_next
    lda screen_ptr_msb
    cmp #>screen_end+1
    bne results_to_screen_next
    rts

//----------------------------------------------------------
// Memory Allocations
//----------------------------------------------------------

welcome_msg:
    .text "CONWAY'S GAME OF LIFE"
    .byte $00

enter_msg:
    .text "PRESS 'RETURN' TO START"
    .byte  $00

quit_msg:
    .text "PRESS 'Q' TO QUIT"
    .byte $00
