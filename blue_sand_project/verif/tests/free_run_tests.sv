












class mode1_free_run_up_test extends base_test;
    `uvm_component_utils(mode1_free_run_up_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] count_a, count_b, count_c;
        int expected_increments;
        phase.raise_objection(this);

        `uvm_info("MODE1_UP", "=== Free Run UP test starting ===", UVM_NONE)

        
        
        program_and_enable(
            .mode(2'b00),
            .direction(1'b1),
            .main_load(8'hC2),
            .num_cycles(8'd5)   
        );

        `uvm_info("MODE1_UP", "counter enabled, waiting for it to count...", UVM_NONE)

        
        
        read_count(count_a);
        `uvm_info("MODE1_UP", $sformatf("count right after enable = %0d (0x%02h)", count_a, count_a), UVM_NONE)

        wait_clocks(50);
        read_count(count_b);
        `uvm_info("MODE1_UP", $sformatf("count after 50 clocks = %0d (0x%02h)", count_b, count_b), UVM_NONE)

        wait_clocks(100);
        read_count(count_c);
        `uvm_info("MODE1_UP", $sformatf("count after 150 total clocks = %0d (0x%02h)", count_c, count_c), UVM_NONE)

        
        
        if(count_c == 8'hC2) begin
            `uvm_error("MODE1_UP", "FAIL - counter appears stuck at main_load value, never moved")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_UP", "counter moved from start value - good", UVM_NONE)
            env.sb.pass_count++;
        end

        
        
        
        if(count_b <= 8'hC2) begin
            `uvm_error("MODE1_UP", $sformatf(
                "FAIL - after 50 clocks count=%0d should be > 0xC2 (194), direction may be wrong or counter stuck",
                count_b))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_UP", "direction UP confirmed - count went above start value", UVM_NONE)
            env.sb.pass_count++;
        end

        
        write_reg(8'd0, 32'd0);
        wait_clocks(5);

        `uvm_info("MODE1_UP", $sformatf("=== done. SB pass=%0d fail=%0d ===",
            env.sb.pass_count, env.sb.fail_count), UVM_NONE)

        phase.drop_objection(this);
    endtask

endclass








class mode1_free_run_down_test extends base_test;
    `uvm_component_utils(mode1_free_run_down_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] count_early, count_later;
        phase.raise_objection(this);

        `uvm_info("MODE1_DOWN", "=== Free Run DOWN test starting ===", UVM_NONE)

        
        program_and_enable(
            .mode(2'b00),
            .direction(1'b0),
            .main_load(8'hE0),
            .num_cycles(8'd5)
        );

        
        wait_clocks(50);
        read_count(count_early);
        `uvm_info("MODE1_DOWN", $sformatf("count after 50 clocks = %0d (0x%02h)", count_early, count_early), UVM_NONE)

        wait_clocks(50);
        read_count(count_later);
        `uvm_info("MODE1_DOWN", $sformatf("count after 100 total clocks = %0d (0x%02h)", count_later, count_later), UVM_NONE)

        
        
        if(count_later >= count_early) begin
            `uvm_error("MODE1_DOWN", $sformatf(
                "FAIL - count went from %0d to %0d, expected decrease (direction=DOWN broken?)",
                count_early, count_later))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_DOWN", "PASS - counter is decrementing correctly", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);

        `uvm_info("MODE1_DOWN", $sformatf("=== done. SB pass=%0d fail=%0d ===",
            env.sb.pass_count, env.sb.fail_count), UVM_NONE)

        phase.drop_objection(this);
    endtask

endclass







class mode1_free_run_wrap_up_test extends base_test;
    `uvm_component_utils(mode1_free_run_wrap_up_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_low_value;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE1_WRAP_UP", "=== Free Run UP wrap test (255->0) ===", UVM_NONE)

        
        
        program_and_enable(
            .mode(2'b00),
            .direction(1'b1),
            .main_load(8'hFA),
            .num_cycles(8'd0)   
        );

        
        
        saw_low_value = 0;
        for(i = 0; i < 6; i++) begin
            wait_clocks(5);
            read_count(val);
            `uvm_info("MODE1_WRAP_UP", $sformatf("  sample %0d: count = %0d (0x%02h)", i, val, val), UVM_NONE)
            if(val < 8'd50) saw_low_value = 1;
        end

        
        if(!saw_low_value) begin
            `uvm_error("MODE1_WRAP_UP",
                "FAIL - never saw count < 50 after starting at 250, wrap from 255->0 may be broken")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_WRAP_UP", "PASS - saw wrap from 255 to 0 region", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass






class mode1_free_run_wrap_down_test extends base_test;
    `uvm_component_utils(mode1_free_run_wrap_down_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_high_value;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE1_WRAP_DN", "=== Free Run DOWN wrap test (0->255) ===", UVM_NONE)

        
        program_and_enable(
            .mode(2'b00),
            .direction(1'b0),
            .main_load(8'd3),
            .num_cycles(8'd0)
        );

        saw_high_value = 0;
        for(i = 0; i < 6; i++) begin
            wait_clocks(5);
            read_count(val);
            `uvm_info("MODE1_WRAP_DN", $sformatf("  sample %0d: count = %0d", i, val), UVM_NONE)
            if(val > 8'd200) saw_high_value = 1;
        end

        if(!saw_high_value) begin
            `uvm_error("MODE1_WRAP_DN",
                "FAIL - never saw count > 200 after starting at 3 going down, wrap 0->255 may be broken")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_WRAP_DN", "PASS - saw wrap from 0 to 255 region", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass

