# SystemVerilog — Phase 2: SV for Verification

This section covers the SystemVerilog phase of the Exalt DV training (January–February 2026),
based on chapters from **"SystemVerilog for Verification"** (Spear & Tumbush).

Each subfolder corresponds to either a chapter practice session or a graded task.

> All files were written and simulated on EDA Playground using Synopsys VCS.
> `\`include` paths are flat (all files in the same directory) as downloaded.

---

## Practices

### ch2_data_types
**EDA Playground:** https://www.edaplayground.com/x/a9rs

Hands-on exploration of SystemVerilog data types (Chapter 2):
- `logic` vs `byte` — X/Z handling, signed vs unsigned, overflow
- `struct` vs `union` — memory layout differences
- `typedef` usage
- 2-state vs 4-state types

### ch5_procedural
**EDA Playground:** https://www.edaplayground.com/x/bhjF

Procedural statements and operators (Chapter 5):
- Enhanced `for` loop with inline variable declaration
- `do-while`, `foreach`
- `unique` / `priority` case statements
- `%0d` vs `%d` formatting
- String operators

---

## Tasks

### ch5_linked_list — OOP Doubly Linked List
**Original:** Ch5Task_LinkedList | **EDA Playground:** https://www.edaplayground.com/x/eSZz

Full implementation of a **doubly linked list** in SystemVerilog using OOP:

```
LinkedList
├── Node class (value, next handle, prev handle)
└── LinkedList class
    ├── push_front / push_back
    ├── pop_front / pop_back
    ├── insert_at / delete_at
    ├── search
    ├── print_forward / print_backward
    └── size tracking
```

Packaged as `linkedlist_package` with a separate testbench driving all operations.

---

### ch6_randomisation — Constrained Randomisation
**Original:** Ch6Task_Randomisation | **EDA Playground:** https://www.edaplayground.com/x/JSgJ

Six sub-tasks (a–f) covering Chapter 6 randomisation concepts:

| File | Task | Topic |
|------|------|-------|
| `task_a.sv` | A | Basic `rand`/`randc` — complement constraint (`b == ~a`) |
| `task_b.sv` | B | Weighted distribution with `dist` |
| `task_c.sv` | C | Constraint inheritance and override |
| `task_d.sv` | D | `constraint_mode()` — enabling/disabling constraints at runtime |
| `task_e.sv` | E | Inline constraints with `randomize() with {}` |
| `task_f.sv` | F | Soft constraints — default vs overrideable |
| `soft_constraints.sv` | — | Dedicated soft constraint exploration |
| `questions_answers.sv` | — | Written Q&A on randomisation theory |

Custom `\`SV_RAND_CHECK` macro used throughout for safe randomisation checking.

---

### ch7_mailboxes — Producer-Consumer with Mailboxes
**Original:** Ch7Task_Mailboxes | **EDA Playground:** https://www.edaplayground.com/x/gznM

Custom generic mailbox class with full IPC semantics (Chapter 7):

```
my_mailbox #(type T)
├── Bounded & unbounded modes
├── Semaphore-based blocking put/get
├── try_put / try_get (non-blocking)
└── num() — current item count

Producer.sv  ──→ mailbox ──→ Consumer.sv
```

Key concepts: parameterised classes, semaphores (`new(N)`), generic typing, Producer-Consumer synchronisation pattern.
