// =========================================================
//               __                                       
//              /\ \__                       __           
//   ___     ___\ \ ,_\  _ __   ___     ___ /\_\    ___   
//  / __`\  /'___\ \ \/ /\`'__\/ __`\ /' _ `\/\ \  /'___\ 
// /\ \L\ \/\ \__/\ \ \_\ \ \//\ \L\ \/\ \/\ \ \ \/\ \__/ 
// \ \____/\ \____\\ \__\\ \_\\ \____/\ \_\ \_\ \_\ \____\
//  \/___/  \/____/ \/__/ \/_/ \/___/  \/_/\/_/\/_/\/____/
//
//
// template.s
//    A template assembly program
// =========================================================

BasicUpstart2(main)
    *=4000 "Breakout"

// Program Entry Point
    main: 
        jsr draw_blocks
        rts

// Draw Blocks
    draw_blocks:
