class apb_driver extends uvm_driver #(apb_seq_item);

    `uvm_component_utils(apb_driver)

    virtual apb_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "apb_vif", vif))
            `uvm_fatal("NO_VIF", "apb_driver: could not get apb_vif")
    endfunction

    task run_phase(uvm_phase phase);
        apb_seq_item req;

        vif.psel    = 0;
        vif.penable = 0;
        vif.pwrite  = 0;
        vif.paddr   = 0;
        vif.pwdata  = 0;

        @(posedge vif.pclk iff vif.presetn === 1'b1);
        @(posedge vif.pclk);

        forever begin
            seq_item_port.get_next_item(req);
            do_transfer(req);
            seq_item_port.item_done();
        end
    endtask

    task do_transfer(apb_seq_item item);
        @(posedge vif.pclk);
        vif.psel    = 1;
        vif.penable = 0;
        vif.pwrite  = item.write;
        vif.paddr   = item.addr;
        if(item.write)
            vif.pwdata = item.data;

        @(posedge vif.pclk);
        vif.penable = 1;

        @(posedge vif.pclk iff vif.pready === 1'b1);

        if(!item.write)
            item.data = vif.prdata;

        vif.psel    = 0;
        vif.penable = 0;
    endtask




endclass
