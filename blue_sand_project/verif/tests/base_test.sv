class base_test extends uvm_test;
    `uvm_component_utils(base_test)


    counter_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = counter_env::type_id::create("env", this);
    endfunction


    task write_reg(bit [7:0] addr, bit [31:0] data);
        apb_write_seq wr = apb_write_seq::type_id::create("wr");
        wr.addr = addr;
        wr.data = data;
        wr.start(env.apb_agt.seqr);
    endtask
    task read_reg(bit [7:0] addr, output bit [31:0] data);
        apb_read_seq rd = apb_read_seq::type_id::create("rd");
        rd.addr = addr;
        rd.start(env.apb_agt.seqr);
        data = rd.data;
    endtask


    task program_and_enable(
        input bit [1:0] mode,
        input bit       direction,
        input bit [7:0] main_load,
        input bit [7:0] num_cycles = 8'd0,
        input bit [7:0] sec_load   = 8'd0
    );
        counter_program_seq prog = counter_program_seq::type_id::create("prog");
        counter_enable_seq  en   = counter_enable_seq::type_id::create("en");

        prog.mode          = mode;
        prog.direction     = direction;
        prog.main_load     = main_load;
        prog.num_cycles    = num_cycles;
        prog.sec_load      = sec_load;
        prog.is_double_wrap= (mode == 2'b10);
        prog.start(env.apb_agt.seqr);

        en.start(env.apb_agt.seqr);
    endtask

    task wait_clocks(int n);
        repeat(n) @(posedge env.apb_agt.drv.vif.pclk);
    endtask

    task read_count(output bit [7:0] val);
        bit [31:0] raw;
        read_reg(8'd5, raw);
        val = raw[7:0];
    endtask

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        #100;
        phase.drop_objection(this);
    endtask

endclass
