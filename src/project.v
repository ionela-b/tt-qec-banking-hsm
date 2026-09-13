/*
 * Copyright (c) 2026 Ionela Balint
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_qec_banking (
    input  wire [7:0] ui_in,    // Quantum register low (8 qubits)
    output wire [7:0] uo_out,   // syndromes & alerts
    input  wire [7:0] uio_in,   // Quantum register high (8 qubits)
    output wire [7:0] uio_out,  // IO output path (unused)
    output wire [7:0] uio_oe,   // IO enable path (0 = input)
    input  wire       ena,      // power enable
    input  wire       clk,      // system clock
    input  wire       rst_n     // reset
);

    // set all bidirectional IOs as inputs to maximize qubit processing power
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;

    // 16-Qubit Quantum Data Register
    wire [15:0] q_data = {uio_in[7:0], ui_in[7:0]};

    // Advanced 16-Qubit QLDPC Sparse Matrix
    // Generates a massive combinational logic tree in silicon
    wire syn_0 = q_data[0] ^ q_data[1] ^ q_data[3] ^ q_data[5] ^ q_data[8] ^ q_data[10] ^ q_data[13];
    wire syn_1 = q_data[0] ^ q_data[2] ^ q_data[3] ^ q_data[6] ^ q_data[9] ^ q_data[11] ^ q_data[14];
    wire syn_2 = q_data[1] ^ q_data[2] ^ q_data[3] ^ q_data[7] ^ q_data[10] ^ q_data[12] ^ q_data[15];
    wire syn_3 = q_data[4] ^ q_data[5] ^ q_data[6] ^ q_data[7] ^ q_data[11] ^ q_data[12] ^ q_data[14];

    // global QLDPC alert logic
    wire qldpc_alert = syn_0 | syn_1 | syn_2 | syn_3;

    // 3-bit Hardware Decoherence Counter
    reg [2:0] attack_counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            attack_counter <= 3'b000;
        end else if (qldpc_alert) begin
            attack_counter <= attack_counter + 1;
        end
    end

    // Output Routing
    assign uo_out[0] = syn_0;            // Syndrome 0
    assign uo_out[1] = syn_1;            // Syndrome 1
    assign uo_out[2] = syn_2;            // Syndrome 2
    assign uo_out[3] = syn_3;            // Syndrome 3
    assign uo_out[4] = qldpc_alert;      // Global Threat Trigger
    assign uo_out[7:5] = attack_counter; // Sequential Counter

endmodule
