class counter_env extends uvm_env;
    `uvm_component_utils(counter_env)


    apb_agent          apb_agt;
    counter_agent      cntr_agt;
    counter_scoreboard sb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        apb_agt  = apb_agent::type_id::create("apb_agt",  this);
        cntr_agt = counter_agent::type_id::create("cntr_agt", this);
        sb       = counter_scoreboard::type_id::create("sb", this);
    endfunction


    function void connect_phase(uvm_phase phase);
        apb_agt.mon.ap.connect(sb.apb_export);
        cntr_agt.mon.ap.connect(sb.cntr_export);
    endfunction

endclass
