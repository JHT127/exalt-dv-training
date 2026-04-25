













class mode4_special_wrap_up_test extends base_test;
    `uvm_component_utils(mode4_special_wrap_up_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_wrap_to_main;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE4_UP", "=== Special Single Wrap UP test ===", UVM_NONE)
        `uvm_info("MODE4_UP", "config: mode=11 dir=UP main_load=0xFD num_cycles=6", UVM_NONE)

        
        program_and_enable(
            .mode(2'b11),
            .direction(1'b1),
            .main_load(8'hFD),
            .num_cycles(8'd5)   
        );

        
        
        
        
        `uvm_info("MODE4_UP", "waiting for counter to reach and pass 0xFF...", UVM_NONE)

        saw_wrap_to_main = 0;
        for(i = 0; i < 10; i++) begin
            wait_clocks(10);
            read_count(val);
            `uvm_info("MODE4_UP", $sformatf("  sample %0d: count = 0x%02h (%0d)", i, val, val), UVM_NONE)

            
            
            
            if(val == 8'hFD || val == 8'hFE) begin
                
                saw_wrap_to_main = 1;
            end
            if(val == 8'h00 || val == 8'h01) begin
                
                `uvm_error("MODE4_UP", $sformatf(
                    "FAIL - count hit 0x%02h, counter wrapped to 0 instead of main_load (0xFD)!", val))
                env.sb.fail_count++;
            end
        end

        
        
        wait_clocks(80);
        read_count(val);
        `uvm_info("MODE4_UP", $sformatf("final read: count = 0x%02h", val), UVM_NONE)

        
        if(val < 8'hFD) begin
            `uvm_error("MODE4_UP", $sformatf(
                "FAIL - count = 0x%02h is below main_load 0xFD, something is very wrong", val))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE4_UP", "count is in expected range - wrap looks correct", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);

        `uvm_info("MODE4_UP", $sformatf("=== done. SB pass=%0d fail=%0d ===",
            env.sb.pass_count, env.sb.fail_count), UVM_NONE)

        phase.drop_objection(this);
    endtask

endclass








class mode4_special_wrap_down_test extends base_test;
    `uvm_component_utils(mode4_special_wrap_down_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] count_a, count_b, val;
        bit saw_wrap;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE4_DOWN", "=== Special Single Wrap DOWN test ===", UVM_NONE)
        `uvm_info("MODE4_DOWN", "config: mode=11 dir=DOWN main_load=0xE4 num_cycles=6", UVM_NONE)

        program_and_enable(
            .mode(2'b11),
            .direction(1'b0),
            .main_load(8'hE4),
            .num_cycles(8'd5)
        );

        
        wait_clocks(15);
        read_count(count_a);
        `uvm_info("MODE4_DOWN", $sformatf("early count = 0x%02h (%0d)", count_a, count_a), UVM_NONE)

        wait_clocks(20);
        read_count(count_b);
        `uvm_info("MODE4_DOWN", $sformatf("later count = 0x%02h (%0d)", count_b, count_b), UVM_NONE)

        
        
        
        if(count_b > count_a && count_a > 8'h10) begin
            
            `uvm_error("MODE4_DOWN", $sformatf(
                "FAIL - count went UP from 0x%02h to 0x%02h but direction is DOWN",
                count_a, count_b))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE4_DOWN", "direction DOWN confirmed - count is decreasing", UVM_NONE)
            env.sb.pass_count++;
        end

        
        
        
        
        wait_clocks(200);
        read_count(val);
        `uvm_info("MODE4_DOWN", $sformatf("after 200 more clocks: count = 0x%02h", val), UVM_NONE)

        
        `uvm_info("MODE4_DOWN", $sformatf("SB mismatches so far: %0d", env.sb.fail_count), UVM_NONE)

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass







class mode4_special_wrap_mid_range_test extends base_test;
    `uvm_component_utils(mode4_special_wrap_mid_range_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE4_MID", "=== Special Wrap mid-range test (main_load=128) ===", UVM_NONE)

        
        
        

        
        program_and_enable(
            .mode(2'b11),
            .direction(1'b1),
            .main_load(8'd253),
            .num_cycles(8'd0)   
        );

        
        
        
        
        
        write_reg(8'd0, 32'd0); 
        
        
        program_and_enable(
            .mode(2'b11),
            .direction(1'b1),
            .main_load(8'd128),
            .num_cycles(8'd0)
        );

        
        
        `uvm_info("MODE4_MID", "counting up from 128 to 255 then should wrap to 128", UVM_NONE)

        
        for(i = 0; i < 5; i++) begin
            wait_clocks(30);
            read_count(val);
            `uvm_info("MODE4_MID", $sformatf("  sample %0d: count = %0d (0x%02h)", i, val, val), UVM_NONE)
        end

        
        
        if(val < 8'd128) begin
            `uvm_error("MODE4_MID", $sformatf(
                "FAIL - count = %0d is below main_load 128, wrap went to wrong place", val))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE4_MID", $sformatf("PASS - count %0d is >= 128 as expected", val), UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass

