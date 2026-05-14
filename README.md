# Pipelined MIPS-32 Processor

5-stage pipelined MIPS-32 processor in Verilog, supporting the core RISC instruction subset with forwarding and stall-based hazard resolution.

## Pipeline

| Stage | Function |
|-------|----------|
| IF    | Instruction fetch |
| ID    | Decode, register read, control |
| EX    | ALU, branch resolution |
| MEM   | Data memory access |
| WB    | Register write-back |

## Hazard Handling

- **Data hazards (RAW):** forwarding from EX/MEM and MEM/WB into EX
- **Load-use hazard:** one-cycle stall via the hazard detection unit
- **Control hazards:** branch resolved in EX, pipeline flush on taken branch

## Verification

Cycle-accurate RTL simulation running a factorial program written in MIPS-32 assembly. Final register state and intermediate trace compared against expected values. Python scripts automate simulation and result checking.

## Repository Layout

- `Microprocessor/` — Verilog RTL source
- `Testing_MIPS/` — Testbench and Python automation
