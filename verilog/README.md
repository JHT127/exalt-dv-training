# Verilog — Phase 1: RTL Design & Verification Tasks

This section covers the Verilog phase of the Exalt DV training (October–December 2025).
Each subfolder is one task from the training program, renamed to reflect the design concept.

---

## 01 · Waveform Generation
**Original:** Task 1 | **EDA Playground:** https://www.edaplayground.com/x/nkSA

10 waveform timing cases covering:
- Clock generation at specific frequencies
- Signal assertion/de-assertion with random periods (`$urandom_range`)
- Clock-synchronous and asynchronous signal relationships
- Multi-clock domain timing
- Bus toggling patterns

Files downloaded from EDA Playground — no `\`include` dependencies.

---

## 02 · Up-Down Counter
**Original:** Task 2 | **EDA Playground:** https://www.edaplayground.com/x/t4mN

8-bit synchronous up/down counter with:
- Active-low reset, parallel load, direction control
- Testbench with golden reference checker and monitor
- Constrained-random stimulus generation

---

## 03 · Non-Retriggerable Monoshot
**Original:** Task 3 | **EDA Playground:** https://www.edaplayground.com/x/cRRe

FSM-based monoshot that:
- Fires a 128-cycle output pulse on trigger
- Ignores any trigger that arrives during an active pulse (non-retriggerable)
- Verified with edge cases: trigger exactly at cycle 127, back-to-back triggers

---

## 04 · N-bit Comparator
**Original:** Task 4 | **EDA Playground:** https://www.edaplayground.com/x/aapV

Parameterised comparator built by cascading 1-bit stages using `generate`:
- `one_bit_comparator.v` — base 1-bit GT/LT/EQ comparator
- `nbit_comparator.sv` — N-bit wrapper (default N=4, parameterisable)

> ⚠️ **`\`include` note:** `nbit_comparator.sv` uses `` `include "one_bit_comparator.v" `` — both files must be in the same directory when compiling locally.

---

## 05 · Serial Adder with FSM Full Adder (Final Verilog Project)
**Original:** finalVerilogProject | **EDA Playground:** https://www.edaplayground.com/x/6g3p

Top-level serial adder that adds two 8-bit numbers bit-serially:

```
A[7:0] ──→ PISO ──→ a ──┐
                         ├──→ FSM Full Adder ──→ sum ──→ SIPO ──→ summation[8:0]
B[7:0] ──→ PISO ──→ b ──┘
              ↑
         shift_load → buffer1 → buffer2  (timing alignment)
```

| File | Module | Role |
|------|--------|------|
| `PISO.v` | `PISO` | Parallel-In Serial-Out shift register |
| `SIPO.v` | `SIPO` | Serial-In Parallel-Out shift register (9-bit output) |
| `fsm_full_adder.v` | `fsm_full_adder` | 1-bit full adder with carry, FSM-controlled |
| `buffer.v` | `buffer` | 1-cycle delay buffer for shift_load alignment |
| `serial_adder.sv` | `serial_adder` | Top-level integration |

> ⚠️ **`\`include` note:** `serial_adder.sv` uses `` `include "PISO.v" ``, `` `include "fsm_full_adder.v" ``, `` `include "SIPO.v" ``, `` `include "buffer.v" `` — all files must be in the same directory.
