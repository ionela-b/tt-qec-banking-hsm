/*
 * Copyright (c) 2026 Ionela Balint
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_qec_banking (
    input  wire [7:0] ui_in,    // Dedicated inputs (Qubit states)
    output wire [7:0] uo_out,   // Dedicated outputs (Syndromes & Alerts)
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // 7 Physical Qubits din rețeaua bancară (Date)
    wire [6:0] q_data = ui_in[6:0]; 

    // QLDPC Sparse Parity Checks (Extragerea Sindromului - Z Stabilizers)
    // Fiecare ecuație verifică paritatea (XOR) doar pe un subset specific de qubiți
    wire syn_0 = q_data[0] ^ q_data[1] ^ q_data[3] ^ q_data[4];
    wire syn_1 = q_data[0] ^ q_data[2] ^ q_data[3] ^ q_data[5];
    wire syn_2 = q_data[1] ^ q_data[2] ^ q_data[3] ^ q_data[6];

    // Dacă vreun sindrom e 1, rețeaua a suferit o eroare/atac (decoerență)
    wire qldpc_alert = syn_0 | syn_1 | syn_2;

    // REGISTRU SECVENȚIAL: Numărător de evenimente de decoerență/atacuri
    reg [3:0] attack_counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            attack_counter <= 4'b0;
        end else if (qldpc_alert) begin
            attack_counter <= attack_counter + 1;
        end
    end

    // Alocarea pinilor de ieșire
    assign uo_out[0] = syn_0;         // Parity Check 1
    assign uo_out[1] = syn_1;         // Parity Check 2
    assign uo_out[2] = syn_2;         // Parity Check 3
    assign uo_out[3] = qldpc_alert;   // Trigger general de eroare QLDPC
    assign uo_out[7:4] = attack_counter; // Contor (4 biți) pentru atacuri

endmodule
