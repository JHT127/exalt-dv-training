class apb_seq_item extends uvm_sequence_item;

    `uvm_object_utils(apb_seq_item)

    rand bit [7:0]  addr;
    rand bit [31:0] data;
    rand bit        write;

    function new(string name = "apb_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("APB %s addr=0x%02h data=0x%08h",
                         write ? "WR" : "RD", addr, data);
    endfunction

endclass
