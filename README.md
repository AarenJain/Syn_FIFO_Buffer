Synchronous FIFO Buffer (Verilog)
This project implements a Synchronous FIFO (First-In-First-Out) buffer using Verilog. It is designed to manage data transfer efficiently between modules operating in the same clock domain.

Features:
-Parameterizable data width and FIFO depth
-Fully synchronous design (single clock domain)
-Standard handshake signals: full, empty, read_en, write_en
-Testbench with comprehensive functional verification

Project Structure:
-code.sv – RTL implementation of the synchronous FIFO
-testbench.sv – Testbench for simulating and verifying behavior
-README.md – Project documentation and usage overview

Verification Approach:
-Stimulus generation and monitoring using Verilog testbench
-Edge case scenarios tested: full, empty, overflow, and underflow
-Functional correctness validated through simulation

