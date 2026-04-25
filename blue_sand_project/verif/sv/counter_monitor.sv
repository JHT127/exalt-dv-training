class counter_monitor extends uvm_monitor;

    `uvm_component_utils(counter_monitor)

    virtual counter_if #(8) vif;
    uvm_analysis_port #(counter_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if(!uvm_config_db #(virtual counter_if #(8))::get(this, "", "cntr_vif", vif))
            `uvm_fatal("NO_VIF", "counter_monitor: could not get cntr_vif")
    endfunction

    task run_phase(uvm_phase phase);
        counter_seq_item item;
        forever begin
            @(posedge vif.pclk);
            item = counter_seq_item::type_id::create("item");
            item.count = vif.count;
            ap.write(item);
        end
    endtask

endclass
