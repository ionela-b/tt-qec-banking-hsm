/*
 * Copyright (c) 2026 Ionela Balint
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_qec_banking (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // All bidirectional IOs set to 0 as we do not use them
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Banking transaction redundant inputs (Simulating Quantum/Classical states)
    wire bit1 = ui_in[0];
    wire bit2 = ui_in[1];
    wire bit3 = ui_in[2];

    // Majority Voting Logic: Corrects a single bit-flip error instantly
    wire corrected_bit = (bit1 & bit2) | (bit2 & bit3) | (bit1 & bit3);

    // Syndrome detection: Triggers if bits do not match (Error/Hack detected)
    wire security_alert = (bit1 ^ bit2) | (bit2 ^ bit3);

    // Assign outputs
    assign uo_out[0] = corrected_bit;  // Clean, verified transaction bit
    assign uo_out[1] = security_alert; // Hardware trigger to block malicious activity
    assign uo_out[7:2] = 6'b0;         // Remaining outputs grounded

endmodule
