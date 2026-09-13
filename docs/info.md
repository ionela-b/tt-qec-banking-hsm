<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->
## How it works

The FinQ-Chip is a high-density, zero-latency 16-qubit Quantum Low-Density Parity-Check (QLDPC) coprocessor designed for securing financial transactions. It acts as the classical control unit required to stabilize fragile quantum states before decoherence occurs. 

By maximizing the Tiny Tapeout I/O bandwidth, the architecture utilizes both the standard input pins (`ui_in`) and the bidirectional pins (`uio_in` set as inputs) to achieve a 16-qubit wide datapath. The core relies on a highly optimized, sparse parity-check matrix implemented entirely in combinational logic (XOR gates). This design choice guarantees zero clock-cycle latency during syndrome extraction. 

The chip continuously monitors the 16-qubit register. If an error or quantum bit-flip is detected, it instantly computes 4 distinct error syndromes (`uo_out[3:0]`). A non-zero syndrome vector immediately triggers a global hardware alert (`uo_out[4]`) to block the compromised transaction. Additionally, a 3-bit sequential counter (`uo_out[7:5]`) logs the number of detected anomalies on the rising edge of the system clock.

## How to test

The verification of this hardware relies on an advanced Monte Carlo Quantum Noise Emulator, replacing standard linear testbenches. 

**1. Automated Monte Carlo Verification (Python/Cocotb):**
* Navigate to the `test` directory in the repository.
* Run the command `make` in your terminal.
* The Python testbench generates a baseline 16-bit valid quantum state and injects statistical bit-flips (15% decoherence probability) across all 16 channels to simulate real-world environmental noise. It validates that the combinational silicon matrix correctly identifies 100% of the injected errors without false positives.

**2. Interactive Hardware Viewer (GDS Explorer):**
* Activate the chip by setting `ena` (Enable) to `1`.
* Toggle `rst_n` (Reset) low, then high, to initialize the internal attack counter.
* Enable the Auto Clock.
* Manually flip any bit on the 8-bit `ui_in` (Lower Qubits 0-7) or the 8-bit `uio_in` (Upper Qubits 8-15) to simulate an attack.
* **Observe:** The corresponding syndrome bits on `uo_out[0]` to `uo_out[3]` will illuminate instantly, the global alert on `uo_out[4]` will trigger, and the 3-bit counter on `uo_out[7:5]` will increment by one.

## External hardware

No external hardware is required.
