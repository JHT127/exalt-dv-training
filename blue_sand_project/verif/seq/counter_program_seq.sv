class counter_program_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(counter_program_seq)

    bit [1:0] mode          = 2'b00;
    bit       direction     = 1'b1;
    bit [7:0] main_load     = 8'd0;
    bit [7:0] sec_load      = 8'd0;
    bit [7:0] num_cycles    = 8'd0;
    bit       is_double_wrap = 0;



    function new(string name = "counter_program_seq");
        super.new(name);
    endfunction

    task body();
        counter_disable_seq        dis;
        counter_set_cycles_seq     cyc;
        counter_set_mode_seq       mod;
        counter_load_main_seq      mld;
        counter_load_secondary_seq sld;

        dis = counter_disable_seq::type_id::create("dis");
        dis.start(m_sequencer);

        cyc = counter_set_cycles_seq::type_id::create("cyc");
        cyc.num_cycles = num_cycles;
        cyc.start(m_sequencer);

        mod = counter_set_mode_seq::type_id::create("mod");
        mod.mode      = mode;
        mod.direction = direction;
        mod.start(m_sequencer);

        mld = counter_load_main_seq::type_id::create("mld");
        mld.load_val = main_load;
        mld.start(m_sequencer);



        if(is_double_wrap) begin
            sld = counter_load_secondary_seq::type_id::create("sld");
            sld.load_val = sec_load;
            sld.start(m_sequencer);
        end
    endtask




endclass
