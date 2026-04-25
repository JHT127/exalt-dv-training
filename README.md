# 🔬 Exalt DV Training — Design Verification Portfolio

> **Training Period:** October 2025 – March 2026  
> **Provider:** [Exalt Technologies](https://www.exalt.ps/)  
> **Domain:** Digital Design Verification (DV) — Verilog · SystemVerilog · UVM

---

## 📌 Overview

This repository documents my complete journey through Exalt Technologies' Design Verification training program — a six-month structured program covering the full DV stack from foundational Verilog RTL and testbench writing, through SystemVerilog OOP and constrained-random verification, to industry-standard UVM methodology and real silicon sign-off workflows.

The training was divided into progressive tasks and projects, each building on the last. Folder names reflect the design/verification concept rather than raw task numbers, and each section below maps back to the original task and its live EDA Playground link.

---

## 🗺️ Repository Structure

```
exalt-dv-training/
│
├── verilog/
│   ├── 01_waveform_generation/        # Task 1  — Timing & stimulus basics
│   ├── 02_updown_counter/             # Task 2  — RTL design + constrained-random TB
│   ├── 03_non_retriggerable_monoshot/ # Task 3  — FSM-aware RTL + golden checker
│   ├── 04_nbit_comparator/            # Task 4  — Parameterised RTL + directed TB
│   └── 05_serial_adder_fsm/          # Final Verilog Project — Serial adder with FSM
│
├── systemverilog/
│   ├── practices/
│   │   ├── ch2_data_types/            # Ch.2 practice — SV data types exploration
│   │   └── ch5_procedural/            # Ch.5 practice — Procedural statements & operators
│   ├── ch5_linked_list/               # Ch.5 Task — OOP doubly-linked list in SV
│   ├── ch6_randomisation/             # Ch.6 Task — Constrained randomisation (tasks a–f)
│   └── ch7_mailboxes/                 # Ch.7 Task — Mailboxes, Producer-Consumer pattern
│
└── blue_sand_project/                 # Final Project — UVM testbench, APB counter (Synopsys VCS)
    └── verif/
        ├── sv/                        # UVM components (agents, drivers, monitors, scoreboard)
        ├── seq/                       # Sequences & sequence libraries
        ├── tests/                     # Test classes (free-run, wrap, interrupt, etc.)
        ├── tb/                        # Top-level testbench
        ├── bin/                       # Makefile + simulation logs
        ├── bug_waves/                 # 🐛 Bug waveform screenshots + BugDocument.pdf
        ├── etc/                       # Project setup scripts
        └── lib/                       # File list (.f)
```

---

## 📚 Training Progression

### Phase 1 — Verilog RTL & Testbench Fundamentals

| # | Folder | Concept | EDA Playground |
|---|--------|---------|---------------|
| Task 1 | `verilog/01_waveform_generation` | Clock generation, signal assertion/de-assertion, edge-aligned signals, multi-clock domains — 10 timing cases | [▶ Open](https://www.edaplayground.com/x/nkSA) |
| Task 2 | `verilog/02_updown_counter` | 8-bit up/down counter with load, golden-reference checker, monitoring, constrained-random stimulus | [▶ Open](https://www.edaplayground.com/x/t4mN) |
| Task 3 | `verilog/03_non_retriggerable_monoshot` | Non-retriggerable monoshot (128-cycle pulse), FSM-based control, verification with edge cases | [▶ Open](https://www.edaplayground.com/x/cRRe) |
| Task 4 | `verilog/04_nbit_comparator` | Parameterised N-bit comparator built from cascaded 1-bit comparators using `generate` | [▶ Open](https://www.edaplayground.com/x/aapV) |
| Final | `verilog/05_serial_adder_fsm` | Serial adder — PISO + FSM-based full adder + SIPO, with timing-aligned buffers and per-block testbenches | [▶ Open](https://www.edaplayground.com/x/6g3p) |

> **Note on EDA Playground files:** Files were downloaded directly from EDA Playground. If you open them locally, ensure `\`include` paths match your directory layout (e.g. `\`include "one_bit_comparator.v"` in the comparator task points to a file in the same folder).

---

### Phase 2 — SystemVerilog for Verification
*Based on chapters from **"SystemVerilog for Verification"** (Spear & Tumbush)*

| # | Folder | Chapter | Concept | EDA Playground |
|---|--------|---------|---------|---------------|
| Practice | `systemverilog/practices/ch2_data_types` | Ch. 2 | `logic` vs `byte`, structs vs unions, signed/unsigned, overflow behaviour | [▶ Open](https://www.edaplayground.com/x/a9rs) |
| Practice | `systemverilog/practices/ch5_procedural` | Ch. 5 | `for`/`foreach`, `do-while`, `unique`/`priority`, `$cast`, string ops | [▶ Open](https://www.edaplayground.com/x/bhjF) |
| Task | `systemverilog/ch5_linked_list` | Ch. 5 | OOP in SV — doubly linked list with `Node` & `LinkedList` classes, full insert/delete/search | [▶ Open](https://www.edaplayground.com/x/eSZz) |
| Task | `systemverilog/ch6_randomisation` | Ch. 6 | Constrained randomisation — `rand`/`randc`, hard & soft constraints, `constraint_mode`, tasks a–f | [▶ Open](https://www.edaplayground.com/x/JSgJ) |
| Task | `systemverilog/ch7_mailboxes` | Ch. 7 | IPC with mailboxes — custom bounded/unbounded generic mailbox class, Producer-Consumer pattern using semaphores | [▶ Open](https://www.edaplayground.com/x/gznM) |

---

### Phase 3 — UVM & Final Project

> **UVM study topics covered:**
> UVM hierarchy and base classes · Factory & overrides · Config database · Driver-Sequence communication · TLM ports & FIFOs · UVM phases (build → connect → run → report)
>
> 📁 Final project: `blue_sand_project/` — see dedicated section below.
>
> ⚠️ A UVM practice repository will be added separately once it is ready to share.

---

## 🏭 Blue Sand Project — UVM Counter Verification (APB Protocol)

> **My role:** Verification engineer responsible exclusively for the **counter block**
> **Tool:** Synopsys VCS via MobaXterm (SSH to remote Linux server)
> **Protocol:** APB (Advanced Peripheral Bus)

This was a team project under Exalt Technologies — I was assigned the counter block. The design RTL belonged to the project team; my contribution is entirely within the `verif/` directory.

### What I built

| Component | File(s) | Description |
|-----------|---------|-------------|
| APB Agent | `verif/sv/apb_agent.sv` | UVM agent wrapping the APB interface |
| APB Driver | `verif/sv/apb_driver.sv` | Drives APB transactions onto the interface |
| APB Monitor | `verif/sv/apb_monitor.sv` | Passive monitor — captures APB bus activity |
| APB Seq Item | `verif/sv/apb_seq_item.sv` | Transaction item with randomisation |
| Counter Monitor | `verif/sv/counter_monitor.sv` | Dedicated counter output monitor |
| Counter Scoreboard | `verif/sv/counter_scoreboard.sv` | Golden reference checker — compares expected vs actual |
| Counter Env | `verif/sv/counter_env.sv` | Top-level UVM environment |
| Sequences | `verif/seq/` | Config, program, and APB sequences |
| Tests | `verif/tests/` | free-run, wrap, double-wrap, interrupt, special-wrap tests |
| Top TB | `verif/tb/tb.sv` | DUT instantiation + interface binding |

### Bug Findings — 15 Bugs Identified 🐛

I identified **15 functional bugs** in the counter RTL through simulation. Each bug is documented with a waveform screenshot and a formal bug report:

📄 **[`verif/bug_waves/BugDocument.pdf`](blue_sand_project/verif/bug_waves/BugDocument.pdf)**

| Bug | Wave | Description |
|-----|------|-------------|
| Bug 1 | `bug1.png` | |
| Bug 2 | `bug2.png` | |
| ... | ... | See BugDocument.pdf for full descriptions |
| Bug 15 | `bug15.png` | |

> ⚠️ **Note:** The RTL code in `design/` was provided by the project team and may still contain unfixed bugs. Waveforms reflect the state of the design at the time of testing — they are intentionally showing bug behaviour, not passing simulations.

### Simulation Logs

Saved logs in `verif/bin/logs/` show the output of multiple test runs:
- `sanity06_count_down_test.log`
- `sanity07_num_cycles_test.log`
- `sanity08_special_wrap_test.log`
- `slow_count_test.log`
- `very_slow_count_test.log`

### Running the Simulation (Synopsys VCS)

```bash
# From verif/bin/
source ../etc/project_setup
make <test_name>
# Example:
make slow_count_test
```

> Requires Synopsys VCS license and the Exalt server environment. The Makefile and `project_setup` script handle include paths automatically.

---

## ⚖️ License & IP Notice

```
© 2025–2026 Exalt Technologies & the author.

All code in this repository was produced as part of the Exalt Technologies
Design Verification training program. Intellectual property is jointly
owned by Exalt Technologies and the author.

This repository is shared for portfolio and demonstration purposes ONLY.
No part of this code may be copied, reproduced, submitted as coursework,
or used in any commercial product without explicit written permission
from Exalt Technologies and the author.

The Blue Sand project design RTL is the property of the Blue Sand project
team and Exalt Technologies. The verification environment (verif/) is the
author's own work produced under the training program.
```

---

## 🛠️ Tools & Technologies

![Verilog](https://img.shields.io/badge/Verilog-RTL-orange)
![SystemVerilog](https://img.shields.io/badge/SystemVerilog-Verification-blue)
![UVM](https://img.shields.io/badge/UVM-Methodology-purple)
![VCS](https://img.shields.io/badge/Synopsys-VCS-red)
![EDA Playground](https://img.shields.io/badge/EDA-Playground-green)

| Tool | Usage |
|------|-------|
| EDA Playground | Phases 1 & 2 — Verilog & SystemVerilog tasks |
| Synopsys VCS | Phase 3 — UVM / Blue Sand project |
| DVE / GTKWave | Waveform analysis |
| MobaXterm | SSH client for VCS server access |
| Git | Version control |
