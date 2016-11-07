//----------------------------------------------------------
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
//----------------------------------------------------------

#import "../include/screen.s"
#import "../include/colours.s"
#import "../include/keymap.s"
#import "../include/io.s"
#import "../include/sid.s"
#import "../include/strlen.s"

BasicUpstart2(main)
    *=4000 "GameOfLife"

.const current_cell_addr_lo = $7500
.const current_cell_addr_hi = $7501
.const next_screen_addr_lo  = $7502
.const next_screen_addr_hi  = $7503
.const rng                  = $E09A

.const welcome_msg_row = $09
.const enter_msg_row   = $0b
.const quit_msg_row    = $0D

.const screen_ptr_lsb  = $F0
.const screen_ptr_msb  = $F1

.const temp_1          = $7000

//----------------------------------------------------------
// Program Entry Point
//----------------------------------------------------------
main: 
    jsr welcome_screen
    jsr setup
    jsr loop
    rts

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
    
    // Store random number for test
    and #%00000110
    cmp #%00000110
    bne next_seed
    ldx #$00
    lda #$A0
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
    jsr io_getin
    cmp #key_q
    beq loop_done
    bne loop 
loop_done:
    rts

do_simulation:
    // TODO - Simulation
    nop    
    rts

welcome_msg:
    .text "GAME OF LIFE!"
    .byte $00

enter_msg:
    .text "PRESS 'RETURN' TO START"
    .byte  $00

quit_msg:
    .text "PRESS 'Q' TO QUIT"
    .byte $00
