`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "apb_if.sv"
`include "counter_if.sv"
`include "counter_verif_pkg.sv"
module tb;
    logic pclk;
    logic presetn;


    import arbitration_pkg::*;
    request_t [15:0] arb_sources;
    logic     [15:0] arb_push;
    logic     [15:0] arb_push_ready;
    request_t        arb_req_out;
    logic            arb_pull;
    logic            arb_pull_ready;
    request_t [1:0]  arb_stage3_reqs;
    logic     [16:0] arb_threshold;

    initial pclk = 0;
    always #5 pclk = ~pclk;


    initial begin
        apb_bus.presetn = 0;
        repeat(5) @(posedge pclk);
        @(negedge pclk);
        apb_bus.presetn = 1;
    end
    apb_if     apb_bus  (.pclk(pclk));
    counter_if cntr_bus (.pclk(pclk));


    blue_sand #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32),
        .COUNT_WIDTH(8)
    ) dut (
        .pclk      (pclk),
        .presetn   (apb_bus.presetn),

        .psel      (apb_bus.psel),
        .penable   (apb_bus.penable),
        .pwrite    (apb_bus.pwrite),
        .paddr     (apb_bus.paddr),
        .pwdata    (apb_bus.pwdata),
        .pready    (apb_bus.pready),
        .prdata    (apb_bus.prdata),
        .pslverr   (apb_bus.pslverr),

        .count     (cntr_bus.count),

        .arbitration_req_sources          (arb_sources),
        .arbitration_push                 (arb_push),
        .arbitration_push_ready           (arb_push_ready),
        .arbitration_req_output           (arb_req_out),
        .arbitration_pull                 (arb_pull),
        .arbitration_pull_ready           (arb_pull_ready),
        .arbitration_stage3_input_requests(arb_stage3_reqs),
        .arbitration_threshold_val        (arb_threshold),

        .main_interrupt (),
        .pwm_port_sig   (),
        .boot_done      (),
        .fatal_error    ()
    );
    initial begin
        arb_push      = 0;
        arb_pull      = 0;
        arb_threshold = 0;
        for(int i = 0; i < 16; i++)
            arb_sources[i] = '0;
    end


    initial begin
        uvm_config_db #(virtual apb_if)::set(
            null, "uvm_test_top.*", "apb_vif", apb_bus);
        uvm_config_db #(virtual counter_if #(8))::set(
            null, "uvm_test_top.*", "cntr_vif", cntr_bus);
        run_test();
    end
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb);
    end

endmodule
