class counter_seq_item extends uvm_sequence_item;

    `uvm_object_utils(counter_seq_item)

    logic [7:0] count;

    function new(string name = "counter_seq_item");
        super.new(name);
    endfunction

endclass
