class counter_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(counter_scoreboard)

    uvm_analysis_imp_apb  #(apb_seq_item,     counter_scoreboard) apb_export;
    uvm_analysis_imp_cntr #(counter_seq_item, counter_scoreboard) cntr_export;

    bit        r_enable;
    bit        r_direction;
    bit [1:0]  r_mode;
    bit [7:0]  r_main_load;
    bit [7:0]  r_secondary_load;
    bit [7:0]  r_num_cycles;

    logic [7:0] expected_count;
    int         cycles_waited;
    bit         loaded;
    bit         enabled_flag;
    bit         first_load;
    bit         first_load_mode3;

    int pass_count;
    int fail_count;

    virtual apb_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        apb_export  = new("apb_export",  this);
        cntr_export = new("cntr_export", this);
        reset_model();
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "apb_vif", vif))
            `uvm_fatal("NO_VIF", "counter_scoreboard: could not get apb_vif")
    endfunction

    function void reset_model();
        r_enable        = 0;
        r_direction     = 0;
        r_mode          = 0;
        r_main_load     = 0;
        r_secondary_load= 0;
        r_num_cycles    = 0;
        expected_count  = 0;
        cycles_waited   = 0;
        loaded          = 0;
        enabled_flag    = 0;
        first_load      = 1;
        first_load_mode3= 1;
    endfunction

    function void write_apb(apb_seq_item item);
        if(!item.write) return;

        case(item.addr)
            8'd0: begin
                r_enable     = item.data[0];
                enabled_flag = 1;
                `uvm_info("SB", $sformatf("enable = %0b", r_enable), UVM_MEDIUM)
            end
            8'd1: begin
                r_main_load = item.data[7:0];
                loaded      = 1;
                first_load      = 1;
                first_load_mode3= 1;
                `uvm_info("SB", $sformatf("main_load = %0d", r_main_load), UVM_MEDIUM)
            end
            8'd2: begin
                r_secondary_load = item.data[7:0];
                `uvm_info("SB", $sformatf("secondary_load = %0d", r_secondary_load), UVM_MEDIUM)
            end
            8'd3: begin
                r_num_cycles = item.data[7:0];
                `uvm_info("SB", $sformatf("num_cycles = %0d", r_num_cycles), UVM_MEDIUM)
            end
            8'd4: begin
                if(r_enable && (r_direction !== item.data[2])) begin
                    first_load      = 1;
                    first_load_mode3= 1;
                end
                r_direction = item.data[2];
                r_mode      = item.data[1:0];
                `uvm_info("SB", $sformatf("mode=%02b dir=%0b", r_mode, r_direction), UVM_MEDIUM)
            end
            default: ;
        endcase
    endfunction

    function void write_cntr(counter_seq_item item);
        if(vif.presetn === 1'b0) begin
            reset_model();
            return;
        end

        if(enabled_flag) begin
            enabled_flag = 0;
            expected_count = item.count;
            return;
        end

        if(loaded) begin
            expected_count = r_main_load;
            cycles_waited  = 0;
            loaded         = 0;
            return;
        end

        if(item.count !== expected_count) begin
            fail_count++;
            `uvm_error("SB", $sformatf("COUNT MISMATCH: expected=%0d  got=%0d  (en=%0b mode=%02b dir=%0b)",
                       expected_count, item.count, r_enable, r_mode, r_direction))
        end else begin
            pass_count++;
            `uvm_info("SB", $sformatf("count OK = %0d", item.count), UVM_HIGH)
        end
        tick_ref_model();
    endfunction

    function void tick_ref_model();

        if(!r_enable) begin
            cycles_waited    = 0;
            first_load       = 1;
            first_load_mode3 = 1;
            return;
        end

        if(cycles_waited != r_num_cycles) begin
            cycles_waited++;
            return;
        end

        cycles_waited = 0;

        case(r_mode)
            2'b00: begin
                if(r_direction) expected_count = expected_count + 1;
                else            expected_count = expected_count - 1;
            end

            2'b01: begin
                if(r_direction) begin
                    if(expected_count == 8'd255) begin
                        expected_count = r_main_load;
                        first_load = 1;
                    end else if(expected_count == r_main_load && !first_load)
                        expected_count = 0;
                    else begin
                        expected_count = expected_count + 1;
                        first_load = 0;
                    end
                end else begin
                    if(expected_count == 8'd0) begin
                        expected_count = r_main_load;
                        first_load = 1;
                    end else if(expected_count == r_main_load && !first_load)
                        expected_count = 8'd255;
                    else begin
                        expected_count = expected_count - 1;
                        first_load = 0;
                    end
                end
            end

            2'b10: begin
                if(expected_count == r_main_load && !first_load_mode3) begin
                    expected_count   = r_secondary_load;
                    first_load_mode3 = 1;
                end else if(expected_count == r_secondary_load && !first_load_mode3) begin
                    expected_count   = r_main_load;
                    first_load_mode3 = 1;
                end else if(r_direction) begin
                    expected_count   = expected_count + 1;
                    first_load_mode3 = 0;
                end else begin
                    expected_count   = expected_count - 1;
                    first_load_mode3 = 0;
                end
            end

            2'b11: begin
                if(r_direction) begin
                    if(expected_count == 8'd255) expected_count = r_main_load;
                    else                         expected_count = expected_count + 1;
                end else begin
                    if(expected_count == 8'd0) expected_count = r_main_load;
                    else                       expected_count = expected_count - 1;
                end
            end
        endcase
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", $sformatf("\n===== Scoreboard Summary =====\n  PASS: %0d\n  FAIL: %0d\n",
                  pass_count, fail_count), UVM_NONE)
        if(fail_count > 0)
            `uvm_error("SB", "*** TEST FAILED ***")
    endfunction

endclass
