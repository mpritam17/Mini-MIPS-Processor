# Mini RISC-V Processor Design

This repository contains the Verilog implementation of a custom 32-bit Mini RISC-V processor. The design features a Harvard-like architecture with separate instruction and data paths, a custom control unit, and a specialized instruction set including Hamming distance and Conditional Move operations.

## Architecture Overview

The processor design utilizes a multi-stage datapath controlled by a central Control Unit.

* **Architecture Type:** Harvard (Separate Instruction and Data Caches)
* **Datapath Components:**
    * **Register Bank:** Dual-read, single-write port configuration.
    * **ALU:** Arithmetic Logic Unit handling integer operations.
    * **Next Address Logic:** Handles PC increments and branch target calculations.
    * **Control Unit:** Generates signals for write backs, memory access, and ALU function selection.

### Control Signals
Based on the provided block diagram, the Control Unit manages the following key signals:
* `Branch sel`: Selector for Next Address logic (PC update).
* `Dest Reg`: Destination register selector.
* `Reg write`: Write enable for the Register Bank.
* `ALU src`: Multiplexer selector for ALU second operand (Immediate vs Register).
* `Data Write`: Write enable for Data Cache.
* `Mem to Reg`: Selector for write-back data (ALU result vs Memory load).

## Instruction Set Architecture (ISA)

The processor uses a fixed-length instruction format.

### 1. R-Type Instructions
**Opcode:** `000000`
**Format:** `opcode` | `rs` | `rt` | `rd` | `shamt` | `funct`

| Instruction | Function Code (Hex) | Description |
| :--- | :--- | :--- |
| **ADD** | `0x00` | Add |
| **SUB** | `0x01` | Subtract |
| **INC** | `0x02` | Increment |
| **DEC** | `0x03` | Decrement |
| **AND** | `0x04` | Bitwise AND |
| **OR** | `0x05` | Bitwise OR |
| **NOR** | `0x06` | Bitwise NOR |
| **XOR** | `0x07` | Bitwise XOR |
| **NOT** | `0x08` | Bitwise NOT |
| **SL** | `0x09` | Shift Left |
| **SRL** | `0x0A` | Shift Right Logical |
| **SRA** | `0x0B` | Shift Right Arithmetic |
| **SLT** | `0x0C` | Set Less Than |
| **SGT** | `0x0D` | Set Greater Than |
| **HAM** | `0x0E` | Hamming Distance |
| **MOV** | `0x0F` | Move |
| **CMOV**| `0x10` | Conditional Move |

### 2. I-Type & Branch Instructions
These instructions use distinct opcodes for immediate and control flow operations.

| Instruction | Opcode (Binary) | Type | Description |
| :--- | :--- | :--- | :--- |
| **ADDI** | `100000` | I-Type | Add Immediate |
| **SUBI** | `100001` | I-Type | Subtract Immediate |
| **ANDI** | `101000` | I-Type | AND Immediate |
| **ORI** | `101001` | I-Type | OR Immediate |
| **XORI** | `101010` | I-Type | XOR Immediate |
| **NORI** | `101011` | I-Type | NOR Immediate |
| **SLI** | `110000` | I-Type | Shift Left Immediate |
| **SRLI** | `110001` | I-Type | Shift Right Logical Immediate |
| **SRAI** | `110010` | I-Type | Shift Right Arithmetic Immediate |
| **LUI** | `110101` | I-Type | Load Upper Immediate |
| **BR** | `100100` | Branch | Unconditional Branch |
| **BMI** | `100101` | Branch | Branch if Minus |
| **BPL** | `100110` | Branch | Branch if Plus |
| **BZ** | `100111` | Branch | Branch if Zero |
| **BGT** | `101100` | Branch | Branch if Greater Than |
| **BLT** | `101101` | Branch | Branch if Less Than |
| **BEQ** | `101110` | Branch | Branch if Equal |
| **BNE** | `101111` | Branch | Branch if Not Equal |
| **LD** | `111000` | Mem | Load Word |
| **ST** | `111001` | Mem | Store Word |
| **HALT** | `111111` | Control | Stop Execution |
