TEST ?= mode1_free_run_up_test

WORK_DIR  = $(PROJECT_VER)/bin/work
LOG_DIR   = $(PROJECT_VER)/bin/logs

VCS_FLAGS = \
	-sverilog \
	-ntb_opts uvm-1.2 \
	-timescale=1ns/1ps \
	-full64 \
	+incdir+$(PROJECT_VER)/sv \
	+incdir+$(PROJECT_VER)/seq \
	+incdir+$(PROJECT_VER)/tests \
	-f $(PROJECT_VER)/lib/lib.f \
	-l $(LOG_DIR)/compile.log \
	-o $(WORK_DIR)/simv \
	-debug_acc+all

SIMV_FLAGS = \
	+UVM_VERBOSITY=UVM_MEDIUM \
	+UVM_TESTNAME=$(TEST) \
	-l $(LOG_DIR)/$(TEST).log

.PHONY: help setup compile run regr clean

help:
	@echo ""
	@echo "  make setup    - create work/log directories (run once)"
	@echo "  make compile  - compile all RTL + TB with VCS"
	@echo "  make run      - compile + simulate  (default TEST=$(TEST))"
	@echo "  make regr     - run all tests"
	@echo "  make clean    - remove work dir and logs"
	@echo ""

setup:
	@echo "[setup] creating directories"
	mkdir -p $(WORK_DIR)
	mkdir -p $(LOG_DIR)

compile: setup
	@echo "[compile] running VCS..."
	vcs $(VCS_FLAGS)
	@echo ""
	@if grep -i "^Error\|^Warning.*Error" $(LOG_DIR)/compile.log 2>/dev/null; then \
	    echo "=== COMPILE ERRORS - check $(LOG_DIR)/compile.log ==="; \
	else \
	    echo "=== Compile finished - check $(LOG_DIR)/compile.log for warnings ==="; \
	fi

run: compile
	@echo "[run] simulating: $(TEST)"
	$(WORK_DIR)/simv $(SIMV_FLAGS)
	@echo ""
	@echo "=== Log: $(LOG_DIR)/$(TEST).log ==="
	@if grep -qE "UVM_ERROR @|UVM_FATAL @|UVM_ERROR[[:space:]]*:[[:space:]]*[1-9]" $(LOG_DIR)/$(TEST).log 2>/dev/null; then \
	    echo "*** RESULT: FAIL ***"; \
	    grep -E "UVM_ERROR @|UVM_FATAL @|TEST FAILED" $(LOG_DIR)/$(TEST).log | tail -5; \
	else \
	    echo "*** RESULT: PASS ***"; \
	fi

regr: compile
	@echo "======================================================"
	@echo " Running all tests"
	@echo "======================================================"
	@pass=0; fail=0; \
	for t in \
	    mode1_free_run_up_test \
	    mode1_free_run_down_test \
	    mode1_free_run_wrap_up_test \
	    mode1_free_run_wrap_down_test \
	    mode4_special_wrap_up_test \
	    mode4_special_wrap_down_test \
	    mode4_special_wrap_mid_range_test \
	    mode2_single_wrap_up_test \
	    mode2_single_wrap_down_test \
	    mode3_double_wrap_inner_up_test \
	    mode3_double_wrap_dir_change_test \
	    mode3_double_wrap_equal_loads_test \
            mode1_free_run_large_num_cycles_test \
            mode1_free_run_disable_reenable_test \
            mode2_single_wrap_at_max_up_test \
            mode2_single_wrap_at_zero_down_test \
            mode2_single_wrap_at_main_up_test \
            mode2_single_wrap_at_main_down_test \
            mode3_double_wrap_inner_down_test \
            mode3_double_wrap_outer_region_test \
            mode3_double_wrap_reenable_test \
            mode4_special_wrap_reenable_test \
            mode4_special_wrap_num_cycles_test \
            mode1_free_run_overflow_intr_test \
            mode1_free_run_underflow_intr_test \
            mode1_free_run_wrap_signal_test \
            mode2_single_wrap_region_change_intr_test \
            mode3_double_wrap_region_change_intr_test \
            mode3_double_wrap_sec_load_change_test \
            mode4_special_wrap_intr_test \
            mode2_single_wrap_cycle_accuracy_test \
            mode1_free_run_count_progression_test \
            mode3_double_wrap_outer_wrap_signal_test; do \
	    echo ""; \
	    echo "--- $$t ---"; \
	    $(WORK_DIR)/simv +UVM_VERBOSITY=UVM_MEDIUM +UVM_TESTNAME=$$t \
	        -l $(LOG_DIR)/$$t.log; \
	    if grep -qE "UVM_ERROR @|UVM_FATAL @|UVM_ERROR[[:space:]]*:[[:space:]]*[1-9]" $(LOG_DIR)/$$t.log 2>/dev/null; then \
	        echo "  RESULT: FAIL"; fail=$$((fail+1)); \
	    else \
	        echo "  RESULT: PASS"; pass=$$((pass+1)); \
	    fi; \
	done; \
	echo ""; \
	echo "======================================================"; \
	echo " PASSED: $$pass    FAILED: $$fail"; \
	echo "======================================================"

clean:
	@echo "[clean] removing work and logs"
	rm -rf $(WORK_DIR) $(LOG_DIR)
	rm -f ucli.key vc_hdrs.h
	@echo "done"
