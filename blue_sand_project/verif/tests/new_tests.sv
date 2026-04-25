






















class mode1_free_run_large_num_cycles_test extends base_test;
    `uvm_component_utils(mode1_free_run_large_num_cycles_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val_a, val_b;
        phase.raise_objection(this);

        `uvm_info("MODE1_LARGE_NC", "=== free run UP large num_cycles test ===", UVM_NONE)
        `uvm_info("MODE1_LARGE_NC", "config: mode=00 dir=UP main=0x80 num_cycles=10", UVM_NONE)

        
        program_and_enable(
            .mode(2'b00),
            .direction(1'b1),
            .main_load(8'h80),
            .num_cycles(8'd10)
        );

        wait_clocks(60);
        read_count(val_a);
        `uvm_info("MODE1_LARGE_NC", $sformatf("after 60 clocks: count=0x%02h", val_a), UVM_NONE)

        wait_clocks(60);
        read_count(val_b);
        `uvm_info("MODE1_LARGE_NC", $sformatf("after 120 clocks: count=0x%02h", val_b), UVM_NONE)

        if(val_b <= val_a) begin
            `uvm_error("MODE1_LARGE_NC", $sformatf(
                "FAIL - count did not increase: was 0x%02h now 0x%02h", val_a, val_b))
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_LARGE_NC", "PASS - counter incremented with large num_cycles", UVM_NONE)
            env.sb.pass_count++;
        end

        wait_clocks(200);
        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass







class mode1_free_run_disable_reenable_test extends base_test;
    `uvm_component_utils(mode1_free_run_disable_reenable_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] before_dis, after_dis_a, after_dis_b, after_reen;
        phase.raise_objection(this);

        `uvm_info("MODE1_DIS_REEN", "=== free run disable/re-enable test ===", UVM_NONE)

        program_and_enable(
            .mode(2'b00),
            .direction(1'b1),
            .main_load(8'hA0),
            .num_cycles(8'd5)
        );

        wait_clocks(50);
        read_count(before_dis);
        `uvm_info("MODE1_DIS_REEN", $sformatf("count before disable = 0x%02h", before_dis), UVM_NONE)

        write_reg(8'd0, 32'd0);  

        wait_clocks(5);
        read_count(after_dis_a);
        wait_clocks(30);
        read_count(after_dis_b);

        `uvm_info("MODE1_DIS_REEN", $sformatf("disabled: first=0x%02h second=0x%02h (should match)",
            after_dis_a, after_dis_b), UVM_NONE)

        if(after_dis_a != after_dis_b) begin
            `uvm_error("MODE1_DIS_REEN", "FAIL - count changed while disabled, should be frozen")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_DIS_REEN", "PASS - count held steady while disabled", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd1);  

        wait_clocks(50);
        read_count(after_reen);
        `uvm_info("MODE1_DIS_REEN", $sformatf("after re-enable: count=0x%02h", after_reen), UVM_NONE)

        if(after_reen == after_dis_b) begin
            `uvm_error("MODE1_DIS_REEN", "FAIL - counter stuck after re-enable")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE1_DIS_REEN", "PASS - counter resumed after re-enable", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass








class mode2_single_wrap_at_max_up_test extends base_test;
    `uvm_component_utils(mode2_single_wrap_at_max_up_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_ff, saw_bad;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE2_MAX_UP", "=== single wrap UP 0xFF -> main_load=0xE0 ===", UVM_NONE)

        
        program_and_enable(
            .mode(2'b01),
            .direction(1'b1),
            .main_load(8'hE0),
            .num_cycles(8'd5)
        );

        saw_bad = 0;
        for(i = 0; i < 28; i++) begin
            wait_clocks(15);
            read_count(val);
            `uvm_info("MODE2_MAX_UP", $sformatf("  sample %0d: 0x%02h", i, val), UVM_NONE)
            if(val < 8'hE0) begin
                `uvm_error("MODE2_MAX_UP", $sformatf(
                    "FAIL - count 0x%02h went below main_load 0xE0", val))
                env.sb.fail_count++;
                saw_bad = 1;
            end
        end

        if(!saw_bad) begin
            `uvm_info("MODE2_MAX_UP", "PASS - count stayed >= main_load across all samples", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE2_MAX_UP", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass







class mode2_single_wrap_at_zero_down_test extends base_test;
    `uvm_component_utils(mode2_single_wrap_at_zero_down_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_zero, saw_bad;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE2_ZERO_DN", "=== single wrap DOWN 0x00 -> main_load=0x10 ===", UVM_NONE)

        
        program_and_enable(
            .mode(2'b01),
            .direction(1'b0),
            .main_load(8'h10),
            .num_cycles(8'd5)
        );

        saw_zero = 0;
        saw_bad  = 0;
        for(i = 0; i < 14; i++) begin
            wait_clocks(10);
            read_count(val);
            `uvm_info("MODE2_ZERO_DN", $sformatf("  sample %0d: 0x%02h", i, val), UVM_NONE)
            if(val == 8'h00) saw_zero = 1;
            
            if(saw_zero && val > 8'h10) begin
                `uvm_error("MODE2_ZERO_DN", $sformatf(
                    "FAIL - after 0x00 count went to 0x%02h, should wrap to 0x10 not 255", val))
                env.sb.fail_count++;
                saw_bad = 1;
            end
        end

        if(!saw_bad && saw_zero) begin
            `uvm_info("MODE2_ZERO_DN", "PASS - wrap from 0x00 stayed at or below main_load", UVM_NONE)
            env.sb.pass_count++;
        end
        if(!saw_zero) begin
            `uvm_error("MODE2_ZERO_DN", "FAIL - counter never reached 0x00")
            env.sb.fail_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE2_ZERO_DN", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass









class mode2_single_wrap_at_main_up_test extends base_test;
    `uvm_component_utils(mode2_single_wrap_at_main_up_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_zero;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE2_MAIN_UP", "=== single wrap UP - wrap at main_load=0xF8 -> 0 ===", UVM_NONE)

        
        
        program_and_enable(
            .mode(2'b01),
            .direction(1'b1),
            .main_load(8'hF8),
            .num_cycles(8'd5)
        );

        for(i = 0; i < 30; i++) begin
            wait_clocks(10);
            read_count(val);
            `uvm_info("MODE2_MAIN_UP", $sformatf("  sample %0d: 0x%02h", i, val), UVM_NONE)
        end

        if(env.sb.fail_count == 0) begin
            `uvm_info("MODE2_MAIN_UP", "PASS - scoreboard confirmed wrap correct", UVM_NONE)
            env.sb.pass_count++;
        end else begin
            `uvm_error("MODE2_MAIN_UP", "FAIL - scoreboard caught wrap errors")
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE2_MAIN_UP", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass









class mode2_single_wrap_at_main_down_test extends base_test;
    `uvm_component_utils(mode2_single_wrap_at_main_down_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        bit saw_max;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE2_MAIN_DN", "=== single wrap DOWN - wrap at main_load=0x08 -> 255 ===", UVM_NONE)

        
        
        program_and_enable(
            .mode(2'b01),
            .direction(1'b0),
            .main_load(8'h08),
            .num_cycles(8'd5)
        );

        for(i = 0; i < 35; i++) begin
            wait_clocks(10);
            read_count(val);
            `uvm_info("MODE2_MAIN_DN", $sformatf("  sample %0d: 0x%02h", i, val), UVM_NONE)
        end

        if(env.sb.fail_count == 0) begin
            `uvm_info("MODE2_MAIN_DN", "PASS - scoreboard confirmed wrap correct", UVM_NONE)
            env.sb.pass_count++;
        end else begin
            `uvm_error("MODE2_MAIN_DN", "FAIL - scoreboard caught wrap errors")
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE2_MAIN_DN", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass







class mode3_double_wrap_inner_down_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_inner_down_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE3_INNER_DN", "=== double wrap inner region DOWN ===", UVM_NONE)
        `uvm_info("MODE3_INNER_DN", "config: mode=10 DOWN main=0x20 sec=0x60 nc=5", UVM_NONE)

        program_and_enable(
            .mode(2'b10),
            .direction(1'b0),
            .main_load(8'h20),
            .sec_load(8'h60),
            .num_cycles(8'd5)
        );

        
        for(i = 0; i < 6; i++) begin
            wait_clocks(200);
            read_count(val);
            `uvm_info("MODE3_INNER_DN", $sformatf("  sample %0d: count=0x%02h (%0d)", i, val, val), UVM_NONE)
        end

        `uvm_info("MODE3_INNER_DN", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass








class mode3_double_wrap_outer_region_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_outer_region_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE3_OUTER", "=== double wrap outer region UP ===", UVM_NONE)
        `uvm_info("MODE3_OUTER", "config: mode=10 UP main=0x10 sec=0x80 nc=5", UVM_NONE)

        program_and_enable(
            .mode(2'b10),
            .direction(1'b1),
            .main_load(8'h10),
            .sec_load(8'h80),
            .num_cycles(8'd5)
        );

        for(i = 0; i < 8; i++) begin
            wait_clocks(100);
            read_count(val);
            `uvm_info("MODE3_OUTER", $sformatf("  sample %0d: count=0x%02h", i, val), UVM_NONE)
        end

        `uvm_info("MODE3_OUTER", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass







class mode3_double_wrap_reenable_test extends base_test;
    `uvm_component_utils(mode3_double_wrap_reenable_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val_before, val_dis_a, val_dis_b, val_after;
        phase.raise_objection(this);

        `uvm_info("MODE3_REEN", "=== double wrap disable/re-enable test ===", UVM_NONE)

        program_and_enable(
            .mode(2'b10),
            .direction(1'b1),
            .main_load(8'h30),
            .sec_load(8'h90),
            .num_cycles(8'd5)
        );

        wait_clocks(80);
        read_count(val_before);
        `uvm_info("MODE3_REEN", $sformatf("before disable: count=0x%02h", val_before), UVM_NONE)

        write_reg(8'd0, 32'd0);  

        wait_clocks(5);
        read_count(val_dis_a);
        wait_clocks(40);
        read_count(val_dis_b);

        `uvm_info("MODE3_REEN", $sformatf("disabled: 0x%02h then 0x%02h", val_dis_a, val_dis_b), UVM_NONE)

        if(val_dis_a != val_dis_b) begin
            `uvm_error("MODE3_REEN", "FAIL - count moved while disabled!")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE3_REEN", "PASS - count frozen while disabled", UVM_NONE)
            env.sb.pass_count++;
        end

        write_reg(8'd0, 32'd1);  

        wait_clocks(100);
        read_count(val_after);
        `uvm_info("MODE3_REEN", $sformatf("after re-enable: count=0x%02h", val_after), UVM_NONE)

        if(val_after == val_dis_b) begin
            `uvm_error("MODE3_REEN", "FAIL - counter did not resume after re-enable")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE3_REEN", "PASS - counter resumed after re-enable", UVM_NONE)
            env.sb.pass_count++;
        end

        wait_clocks(400);
        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE3_REEN", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass








class mode4_special_wrap_reenable_test extends base_test;
    `uvm_component_utils(mode4_special_wrap_reenable_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] before_dis, after_dis_a, after_dis_b, after_en;
        phase.raise_objection(this);

        `uvm_info("MODE4_REEN", "=== special wrap disable/re-enable test ===", UVM_NONE)
        `uvm_info("MODE4_REEN", "config: mode=11 dir=UP main=0xC0 num_cycles=5", UVM_NONE)

        program_and_enable(
            .mode(2'b11),
            .direction(1'b1),
            .main_load(8'hC0),
            .num_cycles(8'd5)
        );

        wait_clocks(50);
        read_count(before_dis);
        `uvm_info("MODE4_REEN", $sformatf("count before disable = 0x%02h", before_dis), UVM_NONE)

        write_reg(8'd0, 32'd0);  

        wait_clocks(5);
        read_count(after_dis_a);
        wait_clocks(30);
        read_count(after_dis_b);

        `uvm_info("MODE4_REEN", $sformatf("disabled: 0x%02h then 0x%02h (should match)",
            after_dis_a, after_dis_b), UVM_NONE)

        if(after_dis_a != after_dis_b) begin
            `uvm_error("MODE4_REEN", "FAIL - count changed while disabled!")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE4_REEN", "PASS - count held while disabled", UVM_NONE)
            env.sb.pass_count++;
        end

        
        write_reg(8'd0, 32'd1);

        wait_clocks(80);
        read_count(after_en);
        `uvm_info("MODE4_REEN", $sformatf("after re-enable: count=0x%02h", after_en), UVM_NONE)

        if(after_en == after_dis_b) begin
            `uvm_error("MODE4_REEN", "FAIL - counter did not resume after re-enable!")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE4_REEN", "PASS - counter resumed", UVM_NONE)
            env.sb.pass_count++;
        end

        
        if(after_en < 8'hC0) begin
            `uvm_error("MODE4_REEN", $sformatf(
                "FAIL - count 0x%02h went below main_load 0xC0 after re-enable", after_en))
            env.sb.fail_count++;
        end

        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        `uvm_info("MODE4_REEN", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        phase.drop_objection(this);
    endtask

endclass








class mode4_special_wrap_num_cycles_test extends base_test;
    `uvm_component_utils(mode4_special_wrap_num_cycles_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] val;
        int i;
        phase.raise_objection(this);

        `uvm_info("MODE4_NC", "=== special wrap with num_cycles=3 ===", UVM_NONE)
        `uvm_info("MODE4_NC", "config: mode=11 UP main=0xF8 num_cycles=3", UVM_NONE)

        program_and_enable(
            .mode(2'b11),
            .direction(1'b1),
            .main_load(8'hF8),
            .num_cycles(8'd3)
        );

        for(i = 0; i < 8; i++) begin
            wait_clocks(20);
            read_count(val);
            `uvm_info("MODE4_NC", $sformatf("  sample %0d: count=0x%02h (%0d)", i, val, val), UVM_NONE)

            
            if(val < 8'hF8) begin
                `uvm_error("MODE4_NC", $sformatf(
                    "FAIL - count 0x%02h went below main_load 0xF8, wrap went wrong", val))
                env.sb.fail_count++;
            end
        end

        `uvm_info("MODE4_NC", $sformatf("done. SB fail=%0d", env.sb.fail_count), UVM_NONE)
        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask

endclass

