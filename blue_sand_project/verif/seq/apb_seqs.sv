class apb_write_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(apb_write_seq)

    bit [7:0]  addr;
    bit [31:0] data;

    function new(string name = "apb_write_seq");
        super.new(name);
    endfunction

    task body();
        apb_seq_item item = apb_seq_item::type_id::create("item");
        start_item(item);
        item.write = 1;
        item.addr  = addr;
        item.data  = data;
        finish_item(item);
    endtask

endclass


class apb_read_seq extends uvm_sequence #(apb_seq_item);


    `uvm_object_utils(apb_read_seq)

    bit [7:0]  addr;
    bit [31:0] data;

    function new(string name = "apb_read_seq");
        super.new(name);
    endfunction

    task body();
        apb_seq_item item = apb_seq_item::type_id::create("item");
        start_item(item);
        item.write = 0;
        item.addr  = addr;
        finish_item(item);
        data = item.data;
    endtask



endclass
