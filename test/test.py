# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
import random

# Advanced Quantum Environment Parameters
NOISE_PROBABILITY = 0.15  # 15% chance of decoherence per qubit
NUM_TRANSACTIONS = 50     # Number of test cycles
NUM_QUBITS = 16           # Upgraded to 16-Qubit wide datapath

VALID_CODEWORD = 0x0000   # 16-bit baseline stable state

@cocotb.test()
async def quantum_noise_monte_carlo_16q(dut):
    """
    16-Qubit Monte Carlo Simulation of a Quantum Depolarizing Channel.
    Validates the high-density QLDPC combinational matrix.
    """
    dut._log.info("--- STARTING 16-QUBIT QUANTUM NOISE EMULATOR ---")
    
    # initialize system clock (50 MHz)
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())
    
    # Hardware reset sequence
    dut._log.info("Applying hardware reset...")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    dut._log.info("ASIC Boot complete. 16-Qubit QLDPC Engine Online.")

    total_attacks_detected = 0

    # massive Monte Carlo error injection loop
    for i in range(NUM_TRANSACTIONS):
        await RisingEdge(dut.clk)
        
        injected_state = VALID_CODEWORD
        error_mask = 0
        
        # apply statistical bit-flips across ALL 16 physical qubits
        for bit in range(NUM_QUBITS):
            if random.random() < NOISE_PROBABILITY:
                error_mask |= (1 << bit)
                
        injected_state ^= error_mask
        
        # split the 16-bit state into the two 8-bit hardware ports
        dut.ui_in.value = injected_state & 0xFF          # Lower 8 qubits
        dut.uio_in.value = (injected_state >> 8) & 0xFF  # Upper 8 qubits
        
        # wait for the massive combinational logic tree to evaluate
        await ClockCycles(dut.clk, 1)
        
        # read the new output routing
        out_val = dut.uo_out.value.integer
        syndromes = out_val & 0x0F              # Bits 0-3 (4 Syndromes)
        qldpc_alert = (out_val >> 4) & 0x01     # Bit 4 (Global Alert)
        hardware_counter = (out_val >> 5) & 0x07 # Bits 5-7 (3-bit counter)
        
        # analysis and logging
        if error_mask > 0:
            if syndromes == 0:
                dut._log.warning(f"Tx {i+1}: Quantum degeneracy! Error mask {bin(error_mask)} bypassed the parity matrix (Code Distance Limit).")
            else:
                dut._log.info(f"Tx {i+1}: Noise detected! Mask: {bin(error_mask)}")
                assert qldpc_alert == 1, "CRITICAL: ASIC failed to trigger QLDPC alert!"
                total_attacks_detected += 1
        else:
            dut._log.info(f"Tx {i+1}: State stable. No decoherence.")
            assert qldpc_alert == 0, "CRITICAL: ASIC triggered a false positive alert!"

    dut._log.info("--- 16-qubit Monte Carlo Simulation Complete ---")
    dut._log.info(f"Noisy states mitigated by dense hardware: {total_attacks_detected}/{NUM_TRANSACTIONS}")
    dut._log.info(f"Final Hardware Attack Counter State: {hardware_counter}")
