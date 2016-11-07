// ---------------------------------------------------------
// sid.s
//     Useful constants and functions for the SID
//     chip.
// ---------------------------------------------------------

#importonce

.const sid_null             = $00

.const sid_1_frequency_lo    = $d400
.const sid_1_frequency_hi    = $d401
.const sid_1_vc              = $d404
.const sid_1_attack_decay    = $d405
.const sid_1_sustain_release = $d406

.const sid_3_frequency_lo  = $d40e
.const sid_3_frequency_hi  = $d40f
.const sid_3_voice_ctrl    = $d412
.const sid_volume          = $d418
.const sid_3_output        = $d41b
