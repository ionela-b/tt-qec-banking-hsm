<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->
## How it works

The FinQ-Chip is a hardware security module (HSM) coprocessor designed for the financial sector, implementing a Quantum Low-Density Parity-Check (QLDPC) syndrome extractor. 

To secure high-frequency trading and banking data against quantum noise or physical fault-injection attacks, the chip processes states from 7 physical data qubits. It calculates a sparse parity-check matrix (Steane/CSS-inspired) using zero-latency combinational XOR gates to extract 3 distinct error syndromes. If any parity check fails (syndrome = 1), a global `qldpc_alert` is triggered, and a sequential 4-bit hardware register logs the attack event on the clock edge.

## How to test

Provide a simulated quantum state across the 7 input pins (`ui_in[6:0]`). 
- A valid codeword (e.g., all 0s) will output all 0s on the syndrome pins.
- Injecting a bit-flip (error) on any of the input pins will instantly change the parity check syndromes (`uo_out[2:0]`) and raise the alert flag (`uo_out[3]`).
- Toggle the clock pin (`clk`) while the alert is active to see the attack counter (`uo_out[7:4]`) increment.

## External hardware

No external hardware is required.
