















class mode3_double_wrap_inner_up_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_inner_up_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] count_a, count_b, val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE3_INNER_UP", "=== Double Wrap inner region UP test ===", UVM_NONE)
        `uvm_info("MODE3_INNER_UP", "config: mode=10 dir=UP main=0xDC secondary=0x64 num_cycles=6", UVM_NONE)

        
        program_and_enable(
            .mode(2'b10),
            .direction(1'b1),
            .main_load(8'h64),   
            .sec_load(8'hDC),
            .num_cycles(8'd5)
        );

        
        
        wait_clocks(15);
        read_count(count_a);
        `uvm_info("MODE3_INNER_UP", $sformatf("count after 15 clocks = 0x%02h (%0d)", count_a, count_a), UVM_NONE)

        
        if(count_a >= 8'hDC) begin
            `uvm_error("MODE3_INNER_UP", $sformatf(
                "FAIL - count jumped to 0x%02h = secondary_load immediately! (B8 bug)", count_a))
            env.sb.fail_count++;
        end else if(count_a < 8'h64) begin
            `uvm_error("MODE3_INNER_UP", $sformatf(
                "FAIL - count 0x%02h went BELOW main_load 0x64, direction or load wrong", count_a))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE3_INNER_UP",
                "count is just above start value - B8 (jump to secondary) not triggered here", UVM_NONE)
            env.sb.pass_count++;
        end

        
        
        `uvm_info("MODE3_INNER_UP", "letting counter run through inner wrap...", UVM_NONE)
        wait_clocks(800);

        read_count(val);
        `uvm_info("MODE3_INNER_UP", $sformatf("after long run: count = 0x%02h, SB fail=%0d",
            val, env.sb.fail_count), UVM_NONE)

        
        if(val < 8'h64 || val > 8'hDC) begin
            `uvm_error("MODE3_INNER_UP", $sformatf(
                "FAIL - count 0x%02h is outside inner region [0x64, 0xDC]", val))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE3_INNER_UP", "count stayed in inner region - good", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass









class mode3_double_wrap_dir_change_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_dir_change_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE3_DIR_CHG", "=== Double Wrap direction change test ===", UVM_NONE)
        `uvm_info("MODE3_DIR_CHG", "config: mode=10 UP then DOWN at secondary, main=0x0A sec=0x14", UVM_NONE)

        
        program_and_enable(
            .mode(2'b10),
            .direction(1'b1),
            .main_load(8'h0A),
            .sec_load(8'h14),
            .num_cycles(8'd5)
        );

        
        
        wait_clocks(100);
        read_count(val);
        `uvm_info("MODE3_DIR_CHG", $sformatf("count before dir change = 0x%02h (%0d)", val, val), UVM_NONE)

        
        
        `uvm_info("MODE3_DIR_CHG", "changing direction to DOWN now", UVM_NONE)
        write_reg(8'd4, 32'b010); 

        wait_clocks(10);
        read_count(val);
        `uvm_info("MODE3_DIR_CHG", $sformatf("count just after dir change = 0x%02h (%0d)", val, val), UVM_NONE)

        
        if(val == 8'h0A) begin
            `uvm_error("MODE3_DIR_CHG",
                "FAIL - counter jumped to main_load (0x0A) after dir change at secondary_load! (B10 bug)")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE3_DIR_CHG", "did not immediately jump to main_load - good", UVM_NONE)
            env.sb.pass_count++;
        end

        
        wait_clocks(200);
        `uvm_info("MODE3_DIR_CHG", $sformatf("final SB: pass=%0d fail=%0d",
            env.sb.pass_count, env.sb.fail_count), UVM_NONE)

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass








class mode3_double_wrap_equal_loads_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_equal_loads_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] count_early, count_later;
        phase.raise_objection(this);

        `uvm_info("MODE3_EQ_LOAD", "=== Double Wrap equal loads test ===", UVM_NONE)
        `uvm_info("MODE3_EQ_LOAD", "config: mode=10 dir=UP main=0x68 secondary=0x68", UVM_NONE)

        program_and_enable(
            .mode(2'b10),
            .direction(1'b1),
            .main_load(8'h68),
            .sec_load(8'h68),
            .num_cycles(8'd5)
        );

        wait_clocks(30);
        read_count(count_early);
        `uvm_info("MODE3_EQ_LOAD", $sformatf("count_early = 0x%02h", count_early), UVM_NONE)

        wait_clocks(200);
        read_count(count_later);
        `uvm_info("MODE3_EQ_LOAD", $sformatf("count_later = 0x%02h", count_later), UVM_NONE)

        
        
        if(count_early == 8'h68 && count_later == 8'h68) begin
            `uvm_error("MODE3_EQ_LOAD",
                "FAIL - counter stuck at 0x68 with equal loads! (B16 bug)")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE3_EQ_LOAD", "counter is moving with equal loads", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass

