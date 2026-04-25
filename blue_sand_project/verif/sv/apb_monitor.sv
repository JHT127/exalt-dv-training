class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;
    uvm_analysis_port #(apb_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "apb_vif", vif))
            `uvm_fatal("NO_VIF", "apb_monitor: could not get apb_vif")
    endfunction

    task run_phase(uvm_phase phase);
        apb_seq_item seen;
        forever begin
            @(posedge vif.pclk);
            if(vif.psel === 1 && vif.penable === 1 && vif.pready === 1) begin
                seen = apb_seq_item::type_id::create("seen");
                seen.addr  = vif.paddr;
                seen.write = vif.pwrite;
                seen.data  = vif.pwrite ? vif.pwdata : vif.prdata;
                ap.write(seen);
                `uvm_info("APB_MON", seen.convert2string(), UVM_HIGH)
            end
        end
    endtask





endclass
