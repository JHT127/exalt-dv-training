





















class mode1_free_run_overflow_intr_test extends base_test;
    `uvm_component_utils(mode1_free_run_overflow_intr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_low;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE1_OVF_INTR", "=== free run UP overflow interrupt test ===", UVM_NONE)
        `uvm_info("MODE1_OVF_INTR", "config: mode=00 UP main=0xF8 num_cycles=0", UVM_NONE)

        program_and_enable(
            .mode(2'b00),
            .direction(1'b1),
            .main_load(8'hF8),
            .num_cycles(8'd0)
        );

        
        saw_low = 0;
        for(i = 0; i < 30; i++) begin
            wait_clocks(1);
            read_count(val);
            `uvm_info("MODE1_OVF_INTR", $sformatf("  sample %0d: count=0x%02h", i, val), UVM_NONE)
            if(val < 8'hF8) saw_low = 1;
        end

        if(!saw_low) begin
            `uvm_error("MODE1_OVF_INTR", "FAIL - counter never wrapped below start value, overflow wrap broken")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_OVF_INTR", "PASS - counter wrapped from 255 to low values correctly", UVM_NONE)
            env.sb.pass_count++;
        end

        if(env.sb.fail_count == 0)
            `uvm_info("MODE1_OVF_INTR", "PASS - scoreboard clean, no mismatches at wrap", UVM_NONE)
        begin
            bit [31:0] intr_v;
            read_reg(8'd7, intr_v);
            if(intr_v == 0) begin
                `uvm_error("MODE1_OVF_INTR", "FAIL - overflow interrupt reg not set after 0xFF wrap")
                env.sb.fail_count++;
            end else
                `uvm_info("MODE1_OVF_INTR", "PASS - overflow interrupt reg set correctly", UVM_NONE)
        end
        begin bit [31:0] intr_v; read_reg(8'd7, intr_v); if(intr_v == 0) begin `uvm_error("MODE1_OVF_INTR", "FAIL - overflow interrupt reg not set after 0xFF wrap") env.sb.fail_count++; end else `uvm_info("MODE1_OVF_INTR", "PASS - overflow interrupt reg set correctly", UVM_NONE) end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE1_OVF_INTR", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass







class mode1_free_run_underflow_intr_test extends base_test;
    `uvm_component_utils(mode1_free_run_underflow_intr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_high;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE1_UNF_INTR", "=== free run DOWN underflow interrupt test ===", UVM_NONE)
        `uvm_info("MODE1_UNF_INTR", "config: mode=00 DOWN main=0x02 num_cycles=0", UVM_NONE)

        program_and_enable(
            .mode(2'b00),
            .direction(1'b0),
            .main_load(8'h02),
            .num_cycles(8'd0)
        );

        
        saw_high = 0;
        for(i = 0; i < 30; i++) begin
            wait_clocks(1);
            read_count(val);
            `uvm_info("MODE1_UNF_INTR", $sformatf("  sample %0d: count=0x%02h", i, val), UVM_NONE)
            if(val > 8'h02) saw_high = 1;
        end

        if(!saw_high) begin
            `uvm_error("MODE1_UNF_INTR", "FAIL - counter never wrapped above start value, underflow wrap broken")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_UNF_INTR", "PASS - counter wrapped from 0 to high values correctly", UVM_NONE)
        begin
            bit [31:0] intr_v;
            read_reg(8'd10, intr_v);
            if(intr_v == 0) begin
                `uvm_error("MODE1_UNF_INTR", "FAIL - underflow interrupt reg not set after 0x00 wrap")
                env.sb.fail_count++;
            end else
                `uvm_info("MODE1_UNF_INTR", "PASS - underflow interrupt reg set correctly", UVM_NONE)
        end
            env.sb.pass_count++;
        end

        if(env.sb.fail_count == 0)
            `uvm_info("MODE1_UNF_INTR", "PASS - scoreboard clean across underflow wrap", UVM_NONE)

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE1_UNF_INTR", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass







class mode1_free_run_wrap_signal_test extends base_test;
    `uvm_component_utils(mode1_free_run_wrap_signal_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int wrap_count, i;
        bit last_was_high;
        phase.raise_objection(this);

        `uvm_info("MODE1_WRAP_SIG", "=== free run UP multi-wrap signal test ===", UVM_NONE)
        `uvm_info("MODE1_WRAP_SIG", "config: mode=00 UP main=0xFA num_cycles=0", UVM_NONE)

        program_and_enable(
            .mode(2'b00),
            .direction(1'b1),
            .main_load(8'hFA),
            .num_cycles(8'd0)
        );

        wrap_count = 0;
        last_was_high = 0;
        for(i = 0; i < 60; i++) begin
            wait_clocks(3);
            read_count(val);
            `uvm_info("MODE1_WRAP_SIG", $sformatf("  sample %0d: 0x%02h", i, val), UVM_NONE)
            if(last_was_high && val < 8'h10)
                wrap_count++;
            last_was_high = (val > 8'hF0);
        end

        `uvm_info("MODE1_WRAP_SIG", $sformatf("detected %0d wrap events", wrap_count), UVM_NONE)

        if(wrap_count < 2) begin
            `uvm_error("MODE1_WRAP_SIG", "FAIL - expected at least 2 wrap events, wrap may be stuck or broken")
            env.sb.fail_count++;
        end else begin
        begin
            bit [31:0] intr_v;
            read_reg(8'd13, intr_v);
            if(intr_v == 0) begin
                `uvm_error("MODE1_WRAP_SIG", "FAIL - wrap interrupt reg not set after free run wrap")
                env.sb.fail_count++;
            end else
                `uvm_info("MODE1_WRAP_SIG", "PASS - wrap interrupt reg set correctly", UVM_NONE)
        end
            `uvm_info("MODE1_WRAP_SIG", "PASS - multiple consistent wraps observed", UVM_NONE)
            env.sb.pass_count++;
        end

        if(env.sb.fail_count == 0)
            `uvm_info("MODE1_WRAP_SIG", "PASS - scoreboard clean across all wraps", UVM_NONE)

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE1_WRAP_SIG", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass







class mode2_single_wrap_region_change_intr_test extends base_test;
    `uvm_component_utils(mode2_single_wrap_region_change_intr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE2_RGN_INTR", "=== single wrap region change interrupt test ===", UVM_NONE)
        `uvm_info("MODE2_RGN_INTR", "config: mode=01 UP main=0xFC num_cycles=0", UVM_NONE)

        program_and_enable(
            .mode(2'b01),
            .direction(1'b1),
            .main_load(8'hFC),
            .num_cycles(8'd0)
        );

        for(i = 0; i < 30; i++) begin
            wait_clocks(10);
            read_count(val);
            `uvm_info("MODE2_RGN_INTR", $sformatf("  sample %0d: count=0x%02h", i, val), UVM_NONE)
        end

        if(env.sb.fail_count == 0) begin
        begin
            bit [31:0] intr_v;
            read_reg(8'd16, intr_v);
            if(intr_v == 0) begin
                `uvm_error("MODE2_RGN_INTR", "FAIL - region changed interrupt reg not set after wrap")
                env.sb.fail_count++;
            end else
                `uvm_info("MODE2_RGN_INTR", "PASS - region changed interrupt reg set correctly", UVM_NONE)
        end
            `uvm_info("MODE2_RGN_INTR", "PASS - scoreboard clean across all region crossings", UVM_NONE)
            env.sb.pass_count++;
        end else begin
            `uvm_error("MODE2_RGN_INTR", "FAIL - scoreboard caught errors at region boundary")
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE2_RGN_INTR", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass







class mode3_double_wrap_region_change_intr_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_region_change_intr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE3_RGN_INTR", "=== double wrap region change interrupt test ===", UVM_NONE)
        `uvm_info("MODE3_RGN_INTR", "config: mode=10 UP main=0x18 sec=0x28 num_cycles=0", UVM_NONE)

        program_and_enable(
            .mode(2'b10),
            .direction(1'b1),
            .main_load(8'h18),
            .sec_load(8'h28),
            .num_cycles(8'd0)
        );

        for(i = 0; i < 40; i++) begin
            wait_clocks(5);
            read_count(val);
            `uvm_info("MODE3_RGN_INTR", $sformatf("  sample %0d: count=0x%02h", i, val), UVM_NONE)
            if(val < 8'h18 || val > 8'h28) begin
                `uvm_error("MODE3_RGN_INTR", $sformatf(
                    "FAIL - count 0x%02h escaped inner region [0x18..0x28]", val))
                env.sb.fail_count++;
            end
        end

        if(env.sb.fail_count == 0) begin
        begin
            bit [31:0] intr_v;
            read_reg(8'd16, intr_v);
            if(intr_v == 0) begin
                `uvm_error("MODE3_RGN_INTR", "FAIL - region changed interrupt reg not set after double wrap")
                env.sb.fail_count++;
            end else
                `uvm_info("MODE3_RGN_INTR", "PASS - region changed interrupt reg set correctly", UVM_NONE)
        end
            `uvm_info("MODE3_RGN_INTR", "PASS - stayed in inner region, both wrap boundaries correct", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE3_RGN_INTR", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass








class mode4_special_wrap_intr_test extends base_test;
    `uvm_component_utils(mode4_special_wrap_intr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_bad_up, saw_bad_down;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE4_INTR", "=== special wrap interrupt test UP and DOWN ===", UVM_NONE)

        
        `uvm_info("MODE4_INTR", "phase 1: UP main=0xA0 nc=5, count must stay >= 0xA0", UVM_NONE)
        program_and_enable(
            .mode(2'b11),
            .direction(1'b1),
            .main_load(8'hA0),
            .num_cycles(8'd5)
        );

        saw_bad_up = 0;
        for(i = 0; i < 20; i++) begin
            wait_clocks(30);
            read_count(val);
            `uvm_info("MODE4_INTR", $sformatf("  UP sample %0d: 0x%02h", i, val), UVM_NONE)
            if(val < 8'hA0) begin
                `uvm_error("MODE4_INTR", $sformatf(
                    "FAIL - UP count 0x%02h went below main_load 0xA0", val))
                env.sb.fail_count++;
                saw_bad_up = 1;
            end
        end

        if(!saw_bad_up) begin
        begin
            bit [31:0] intr_v;
            read_reg(8'd13, intr_v);
            if(intr_v == 0) begin
                `uvm_error("MODE4_INTR", "FAIL - wrap interrupt reg not set after special wrap UP")
                env.sb.fail_count++;
            end else
                `uvm_info("MODE4_INTR", "PASS - wrap interrupt reg set after UP wrap", UVM_NONE)
        end
            `uvm_info("MODE4_INTR", "PASS - UP wrap always returned to main_load correctly", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);

        
        `uvm_info("MODE4_INTR", "phase 2: DOWN main=0x40 nc=5, count must stay <= 0x40", UVM_NONE)
        program_and_enable(
            .mode(2'b11),
            .direction(1'b0),
            .main_load(8'h40),
            .num_cycles(8'd5)
        );

        saw_bad_down = 0;
        for(i = 0; i < 20; i++) begin
            wait_clocks(15);
            read_count(val);
            `uvm_info("MODE4_INTR", $sformatf("  DOWN sample %0d: 0x%02h", i, val), UVM_NONE)
            if(val > 8'h40) begin
                `uvm_error("MODE4_INTR", $sformatf(
                    "FAIL - DOWN count 0x%02h went above main_load 0x40", val))
                env.sb.fail_count++;
                saw_bad_down = 1;
            end
        end

        if(!saw_bad_down) begin
        begin
            bit [31:0] intr_v;
            read_reg(8'd13, intr_v);
            if(intr_v == 0) begin
                `uvm_error("MODE4_INTR", "FAIL - wrap interrupt reg not set after special wrap DOWN")
                env.sb.fail_count++;
            end else
                `uvm_info("MODE4_INTR", "PASS - wrap interrupt reg set after DOWN wrap", UVM_NONE)
        end
            `uvm_info("MODE4_INTR", "PASS - DOWN wrap always returned to main_load correctly", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE4_INTR", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass







class mode3_double_wrap_sec_load_change_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_sec_load_change_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE3_SEC_CHG", "=== double wrap secondary load change test ===", UVM_NONE)
        `uvm_info("MODE3_SEC_CHG", "config: mode=10 UP main=0x50 sec=0xA0 nc=5", UVM_NONE)

        program_and_enable(
            .mode(2'b10),
            .direction(1'b1),
            .main_load(8'h50),
            .sec_load(8'hA0),
            .num_cycles(8'd5)
        );

        wait_clocks(100);
        read_count(val);
        `uvm_info("MODE3_SEC_CHG", $sformatf("before sec_load change: count=0x%02h", val), UVM_NONE)

        `uvm_info("MODE3_SEC_CHG", "writing new sec_load=0x60 (reg addr=2)", UVM_NONE)
        write_reg(8'd2, 32'h60);

        for(i = 0; i < 10; i++) begin
            wait_clocks(50);
            read_count(val);
            `uvm_info("MODE3_SEC_CHG", $sformatf("  post-change sample %0d: count=0x%02h", i, val), UVM_NONE)
        end

        if(env.sb.fail_count == 0) begin
            `uvm_info("MODE3_SEC_CHG", "PASS - scoreboard clean after secondary load change", UVM_NONE)
            env.sb.pass_count++;
        end else begin
            `uvm_error("MODE3_SEC_CHG", "FAIL - scoreboard errors after secondary load change")
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE3_SEC_CHG", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass








class mode2_single_wrap_cycle_accuracy_test extends base_test;
    `uvm_component_utils(mode2_single_wrap_cycle_accuracy_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val_start, val_end;
        int increments;
        phase.raise_objection(this);

        `uvm_info("MODE2_CYC_ACC", "=== single wrap cycle count accuracy test ===", UVM_NONE)
        `uvm_info("MODE2_CYC_ACC", "config: mode=01 UP main=0x80 num_cycles=9 (10 clks/step)", UVM_NONE)

        program_and_enable(
            .mode(2'b01),
            .direction(1'b1),
            .main_load(8'h80),
            .num_cycles(8'd9)
        );

        wait_clocks(2);
        read_count(val_start);
        `uvm_info("MODE2_CYC_ACC", $sformatf("start count = 0x%02h (%0d)", val_start, val_start), UVM_NONE)

        wait_clocks(100);
        read_count(val_end);
        `uvm_info("MODE2_CYC_ACC", $sformatf("end count = 0x%02h (%0d)", val_end, val_end), UVM_NONE)

        increments = int'(val_end) - int'(val_start);
        `uvm_info("MODE2_CYC_ACC", $sformatf("observed increments = %0d (expected ~10)", increments), UVM_NONE)

        if(increments < 9 || increments > 11) begin
            `uvm_error("MODE2_CYC_ACC", $sformatf(
                "FAIL - expected ~10 increments in 100 clocks with nc=9, got %0d", increments))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE2_CYC_ACC", "PASS - cycle count accuracy correct", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE2_CYC_ACC", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass



































































class mode3_double_wrap_outer_wrap_signal_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_outer_wrap_signal_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE3_OUTER_SIG", "=== double wrap outer region wrap signal test ===", UVM_NONE)
        `uvm_info("MODE3_OUTER_SIG", "config: mode=10 UP main=0x10 sec=0x20 nc=0", UVM_NONE)

        program_and_enable(
            .mode(2'b10),
            .direction(1'b1),
            .main_load(8'h10),
            .sec_load(8'h20),
            .num_cycles(8'd0)
        );

        for(i = 0; i < 50; i++) begin
            wait_clocks(6);
            read_count(val);
            `uvm_info("MODE3_OUTER_SIG", $sformatf("  sample %0d: count=0x%02h", i, val), UVM_NONE)
        end

        if(env.sb.fail_count == 0) begin
            `uvm_info("MODE3_OUTER_SIG", "PASS - scoreboard clean across outer region wrap", UVM_NONE)
            env.sb.pass_count++;
        end else begin
            `uvm_error("MODE3_OUTER_SIG", "FAIL - scoreboard caught errors in outer region")
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE3_OUTER_SIG", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass

