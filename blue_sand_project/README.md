# Blue Sand Project — UVM Counter Verification over APB

> **Phase:** Final Project — Exalt DV Training (March 2026)
> **Tool:** Synopsys VCS (accessed remotely via MobaXterm SSH)
> **Protocol:** APB (Advanced Peripheral Bus — ARM AMBA)
> **My scope:** Counter block verification only

---

## ⚠️ Important Disclaimer

This is a **team project** from the Exalt Technologies training program.

- The **design RTL** (`design/`) belongs to the Blue Sand project team. I had no involvement in writing or fixing the RTL.
- My contribution is **entirely within the `verif/` directory**.
- The RTL **may still contain unfixed bugs** — the simulation logs and bug waveforms reflect the design state at the time I was testing it. Bugs were reported to the design team but were not necessarily fixed before this snapshot was taken.
- **This code is not production-ready.** It is a training exercise.

---

## My Contribution — Verification Environment

I built a complete **UVM testbench** to verify the counter block over the APB protocol.

### UVM Architecture

```
                        ┌─────────────────────────────────┐
                        │         counter_env              │
                        │                                  │
          ┌─────────────┤  apb_agent        counter_agent │
          │             │  ├─ apb_driver    ├─ counter_mon │
          │             │  ├─ apb_monitor   └─ ...         │
          │             │  └─ apb_sequencer                │
          │             │                                  │
          │             │  counter_scoreboard              │
          └──────────── │  (golden reference checker)      │
                        └─────────────────────────────────┘
                                      ▲
                              UVM sequences
                         apb_seqs / counter_cfg_seqs
                         counter_program_seq
```

### File Map

| File | UVM Class | Role |
|------|-----------|------|
| `sv/apb_if.sv` | Interface | APB signal bundle |
| `sv/apb_seq_item.sv` | `uvm_sequence_item` | APB transaction |
| `sv/apb_sequencer.sv` | `uvm_sequencer` | APB sequencer |
| `sv/apb_driver.sv` | `uvm_driver` | Drives APB read/write transactions |
| `sv/apb_monitor.sv` | `uvm_monitor` | Passive APB bus observer |
| `sv/apb_agent.sv` | `uvm_agent` | Active APB agent |
| `sv/counter_if.sv` | Interface | Counter output signal bundle |
| `sv/counter_seq_item.sv` | `uvm_sequence_item` | Counter observation item |
| `sv/counter_monitor.sv` | `uvm_monitor` | Watches counter output port |
| `sv/counter_scoreboard.sv` | `uvm_scoreboard` | Golden model — compares predicted vs actual |
| `sv/counter_env.sv` | `uvm_env` | Top-level environment |
| `sv/counter_verif_pkg.sv` | Package | Compiles all verification components |
| `seq/apb_seqs.sv` | Sequences | Low-level APB read/write sequences |
| `seq/counter_cfg_seqs.sv` | Sequences | Counter configuration sequences |
| `seq/counter_program_seq.sv` | Sequence | Programs the counter via APB |
| `seq/counter_seq_lib.sv` | Sequence lib | Sequence library |
| `tests/base_test.sv` | `uvm_test` | Base test — env build + default config |
| `tests/free_run_tests.sv` | Tests | Free-running counter tests |
| `tests/single_wrap_tests.sv` | Tests | Single-wrap counter tests |
| `tests/double_wrap_tests.sv` | Tests | Double-wrap counter tests |
| `tests/special_wrap_tests.sv` | Tests | Special wrap-value edge cases |
| `tests/interrupt_and_accuracy_tests.sv` | Tests | Interrupt generation + timing accuracy |
| `tests/new_tests.sv` | Tests | Additional tests developed during bug hunt |
| `tb/tb.sv` | Top TB | DUT instantiation, interface binding, UVM `run_test()` |

---

## 🐛 Bug Findings — 15 Bugs

Through systematic simulation using the UVM testbench, I identified **15 functional bugs** in the counter RTL.

📄 **Full bug report: [`verif/bug_waves/BugDocument.pdf`](verif/bug_waves/BugDocument.pdf)**

Waveform evidence for each bug is in `verif/bug_waves/bug1.png` through `bug15.png`.

---

## Running the Tests

> Requires Synopsys VCS license and access to the Exalt server.

```bash
cd verif/bin

# Source environment (sets VCS path, include dirs, etc.)
source ../etc/project_setup

# Run a specific test
make slow_count_test
make very_slow_count_test
make sanity06_count_down_test
make sanity07_num_cycles_test
make sanity08_special_wrap_test

# See all available targets
cat Makefile
```

Simulation logs are saved in `bin/logs/`.

---

## Regression List

`verif/regr/regr_list.txt` contains the full regression test list used during the verification campaign.
