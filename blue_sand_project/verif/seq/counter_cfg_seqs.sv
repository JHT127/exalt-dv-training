
class counter_disable_seq extends uvm_sequence #(apb_seq_item);
   
   
    `uvm_object_utils(counter_disable_seq)


    function new(string name = "counter_disable_seq");
        super.new(name);
    endfunction



    task body();
        apb_write_seq wr = apb_write_seq::type_id::create("wr");
        wr.addr = 8'd0;
        wr.data = 32'd0;
        wr.start(m_sequencer);
    endtask

endclass
class counter_enable_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(counter_enable_seq)

    function new(string name = "counter_enable_seq");
        super.new(name);
    endfunction

    task body();
        apb_write_seq wr = apb_write_seq::type_id::create("wr");
        wr.addr = 8'd0;
        wr.data = 32'd1;
        wr.start(m_sequencer);
    endtask

endclass



class counter_load_main_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(counter_load_main_seq)

    bit [7:0] load_val;

    function new(string name = "counter_load_main_seq");
        super.new(name);
    endfunction

    task body();
        apb_write_seq wr = apb_write_seq::type_id::create("wr");
        wr.addr = 8'd1;
        wr.data = {24'd0, load_val};
        wr.start(m_sequencer);
    endtask

endclass
class counter_load_secondary_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(counter_load_secondary_seq)

    bit [7:0] load_val;

    function new(string name = "counter_load_secondary_seq");
        super.new(name);
    endfunction

    task body();
        apb_write_seq wr = apb_write_seq::type_id::create("wr");
        wr.addr = 8'd2;
        wr.data = {24'd0, load_val};
        wr.start(m_sequencer);
    endtask

endclass
class counter_set_cycles_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(counter_set_cycles_seq)

    bit [7:0] num_cycles;

    function new(string name = "counter_set_cycles_seq");
        super.new(name);
    endfunction

    task body();
        apb_write_seq wr = apb_write_seq::type_id::create("wr");
        wr.addr = 8'd3;
        wr.data = {24'd0, num_cycles};
        wr.start(m_sequencer);
    endtask

endclass
class counter_set_mode_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(counter_set_mode_seq)

    bit [1:0] mode;
    bit       direction;

    function new(string name = "counter_set_mode_seq");
        super.new(name);
    endfunction

    task body();
        apb_write_seq wr = apb_write_seq::type_id::create("wr");
        wr.addr = 8'd4;
        wr.data = {29'd0, direction, mode};
        wr.start(m_sequencer);
    endtask

endclass




class counter_read_count_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(counter_read_count_seq)

    bit [7:0] count_val;

    function new(string name = "counter_read_count_seq");
        super.new(name);
    endfunction

    task body();
        apb_read_seq rd = apb_read_seq::type_id::create("rd");
        rd.addr = 8'd5;
        rd.start(m_sequencer);
        count_val = rd.data[7:0];
    endtask

endclass
class counter_wait_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(counter_wait_seq)

    int unsigned num_clocks = 10;

    function new(string name = "counter_wait_seq");
        super.new(name);
    endfunction

    task body();
        #(num_clocks * 10);
    endtask

endclass
