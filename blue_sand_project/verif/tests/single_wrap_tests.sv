


class mode2_single_wrap_up_test extends base_test;
    `uvm_component_utils(mode2_single_wrap_up_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        bit [7:0] count_a, count_b, val;
        phase.raise_objection(this);
        `uvm_info("MODE2_UP", "=== Single Wrap UP test ===", UVM_NONE)
        program_and_enable(.mode(2'b01), .direction(1'b1), .main_load(8'h64), .num_cycles(8'd5));
        wait_clocks(20);
        read_count(count_a);
        `uvm_info("MODE2_UP", $sformatf("count_a = 0x%02h", count_a), UVM_NONE)
        wait_clocks(20);
        read_count(count_b);
        `uvm_info("MODE2_UP", $sformatf("count_b = 0x%02h", count_b), UVM_NONE)
        if(count_b <= count_a) begin
            `uvm_error("MODE2_UP", "FAIL - not incrementing")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE2_UP", "PASS - going UP", UVM_NONE)
            env.sb.pass_count++;
        end
        wait_clocks(600);
        read_count(val);
        `uvm_info("MODE2_UP", $sformatf("final count=0x%02h SB_fail=%0d", val, env.sb.fail_count), UVM_NONE)
        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask
endclass


class mode2_single_wrap_down_test extends base_test;
    `uvm_component_utils(mode2_single_wrap_down_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        bit [7:0] count_a, count_b, val;
        phase.raise_objection(this);
        `uvm_info("MODE2_DOWN", "=== Single Wrap DOWN test ===", UVM_NONE)
        program_and_enable(.mode(2'b01), .direction(1'b0), .main_load(8'h50), .num_cycles(8'd5));
        wait_clocks(20);
        read_count(count_a);
        `uvm_info("MODE2_DOWN", $sformatf("count_a = 0x%02h", count_a), UVM_NONE)
        wait_clocks(20);
        read_count(count_b);
        `uvm_info("MODE2_DOWN", $sformatf("count_b = 0x%02h", count_b), UVM_NONE)
        if(count_b >= count_a) begin
            `uvm_error("MODE2_DOWN", "FAIL - not decrementing")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE2_DOWN", "PASS - going DOWN", UVM_NONE)
            env.sb.pass_count++;
        end
        wait_clocks(400);
        read_count(val);
        `uvm_info("MODE2_DOWN", $sformatf("final count=0x%02h SB_fail=%0d", val, env.sb.fail_count), UVM_NONE)
        if(val > 8'h50) begin
            `uvm_error("MODE2_DOWN", "FAIL - count above main_load, wrap went wrong")
            env.sb.fail_count++;
        end else begin
            `uvm_info("MODE2_DOWN", "PASS - stayed in lower region", UVM_NONE)
            env.sb.pass_count++;
        end
        write_reg(8'd0, 32'd0);
        wait_clocks(5);
        phase.drop_objection(this);
    endtask
endclass

