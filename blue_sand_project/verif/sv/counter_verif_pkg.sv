package counter_verif_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `uvm_analysis_imp_decl(_apb)
    `uvm_analysis_imp_decl(_cntr)

    `include "apb_seq_item.sv"
    `include "counter_seq_item.sv"

    `include "apb_sequencer.sv"
    `include "apb_driver.sv"
    `include "apb_monitor.sv"
    `include "apb_agent.sv"

    `include "counter_monitor.sv"
    `include "counter_agent.sv"

    `include "counter_scoreboard.sv"
    `include "counter_env.sv"

    `include "../seq/counter_seq_lib.sv"

    `include "../tests/base_test.sv"
    `include "../tests/free_run_tests.sv"
    `include "../tests/special_wrap_tests.sv"
    `include "../tests/single_wrap_tests.sv"
    `include "../tests/double_wrap_tests.sv"
    `include "../tests/new_tests.sv"
    `include "../tests/interrupt_and_accuracy_tests.sv"

endpackage
