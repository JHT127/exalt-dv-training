// SIPO Testbench Module

//`include "SIPO.v"

module SIPO_tb;
  
  //Declaring---------------
  reg clk;
  reg rst;
  reg s_in;
  reg start;
  reg [7:0] num_of_cycles_input;
  reg [7:0] num_of_cycles_start;
  reg [9:0] reset_cycles;
  reg [8:0] expected_p_out;
  reg active;
  reg [3:0] counter;
  reg [8:0] data;
  reg active_at_start_of_cycle;
  integer pass_count;
  integer fail_count;
  integer reset_during_shift_count;
  integer start_during_shift_count;
  localparam shift_cycle_count = 9;
  wire [8:0] p_out;
  
  
  //DUT Instantiation---------------
  SIPO dut(.clk(clk), .rst(rst), .s_in(s_in), .start(start), .p_out(p_out));
  
  
  //Generating the clock---------------
  initial begin
    forever begin
      #5 clk <= ~clk;
    end
  end
  
  
  //Initialization---------------
  initial begin
    clk = 0;
    rst = 0;
    s_in = 0;
    start = 0;
    pass_count = 0;
    fail_count = 0;
    num_of_cycles_input = 2;
    num_of_cycles_start = 2;
    reset_cycles = 5;
    expected_p_out = 0;
    active = 0;
    active_at_start_of_cycle = 0;
    counter = 0;
    data = 0;
    reset_during_shift_count = 0;
    start_during_shift_count = 0;
  end
  
  
  //Initial Reset---------------
  initial begin
    rst <= 1;
    repeat($urandom_range(2,4)) @(posedge clk);
    rst <= 0;
  end
  
  
  //Driving---------------
  
    //Driving the s_in input
    initial begin
      forever begin
        repeat(num_of_cycles_input) @(posedge clk);
        num_of_cycles_input <= $urandom_range(1, 5);
        s_in <= $urandom_range(0, 1);
      end 
    end

  
    //Driving the start input
    initial begin
      forever begin
        
        //Normal operation
        repeat(num_of_cycles_start) @(posedge clk);
        num_of_cycles_start <= $urandom_range(10, 30);
        start <= 1;
        
        //On-the-fly toggle test
        if ($urandom_range(0,1) == 1) begin
          repeat($urandom_range(2, 5)) @(posedge clk);
          start <= 0;
          @(posedge clk);
          start <= 1;
        end
        
        repeat($urandom_range(10,15)) @(posedge clk);
        start <= 0;
        repeat($urandom_range(5,10)) @(posedge clk);
        
        //Extended HIGH hold test for the start 
        repeat($urandom_range(10, 20)) @(posedge clk);
        start <= 1;
        repeat($urandom_range(15, 25)) @(posedge clk); 
        start <= 0;
        repeat($urandom_range(5,10)) @(posedge clk);
        
        //Rapid toggle test
        repeat($urandom_range(10, 20)) @(posedge clk); 
        start <= 1;
        repeat(shift_cycle_count) @(posedge clk);
        start <= 0;
        repeat($urandom_range(3,7)) @(posedge clk);
        start <= 1;
        repeat($urandom_range(10,15)) @(posedge clk); 
        start <= 0;
        
      end 
    end
  

    //Driving the rst 
    initial begin 
      forever begin
        repeat(reset_cycles) @(posedge clk);
        reset_cycles <= $urandom_range(200, 300);
        rst <= 1;
        repeat($urandom_range(100,150)) @(posedge clk);
        rst <= 0;
      end
    end

  
  //Waveform---------------
  initial begin
    $dumpfile("waveform_sipo.vcd");
    $dumpvars(0, SIPO_tb);
  end  
  
  
  //Finish and Test Status---------------
  initial begin
    #20000 
    $display("\n\n=====Test Summary=====");
    $display("%0d Tests Passed", pass_count);
    $display("%0d Tests Failed", fail_count);
    $display("\n=====Corner Cases Detected=====");
    $display("%0d 'start' Toggles During Shift (Non-Retriggerable)", start_during_shift_count);
    $display("%0d Resets During Shift", reset_during_shift_count);
    $display("\n=====Final Result=====");
    if(fail_count == 0) begin
      $display("PASS\n\n");
    end
    else begin
      $display("FAIL\n\n");
    end
    $finish;
  end
  
  
  //Checker----------------------------------------
  initial begin
    
    @(posedge rst);
    @(posedge clk iff rst == 0);
    
    forever begin     
      
      //Reference Model
      if(rst) begin
        if (active) begin 
          $display("-----------------RESET DURING SHIFT-----------------");
          reset_during_shift_count = reset_during_shift_count + 1;
        end
        data = 9'b0;
        counter = 4'b0;
        active = 0;
        expected_p_out = 9'b0;
      end
      
      else begin
        active_at_start_of_cycle = active;
        
        if (start && active_at_start_of_cycle) begin
          $display("-----------------'start' TOGGLED DURING SHIFT (IGNORED)-----------------");
          start_during_shift_count = start_during_shift_count + 1;
        end
        
        if (start && !active_at_start_of_cycle) begin
          active = 1;
          counter = counter + 1;
          data = {s_in, data[8:1]};
        end
        
        if (active_at_start_of_cycle) begin
          if (counter == 8) begin
            active = 0;
            counter = 0;
            expected_p_out = {s_in, data[8:1]}; 
          end
          else begin
            counter = counter + 1;
            data = {s_in, data[8:1]};
          end
        end
      end
      
      
      //wait for dut to update
      @(posedge clk);
      
      
      //checking
      if (p_out === expected_p_out) begin
        $display("PASS: Time=%0t | rst=%b | p_out=%d | expected=%d | start=%b | s_in=%b", 
                 $time, rst, p_out, expected_p_out, start, s_in);
        pass_count = pass_count + 1;
      end 
      else begin
        $display("FAIL: Time=%0t | rst=%b | p_out=%d | expected=%d | start=%b | s_in=%b | data=%d | counter=%d", 
                 $time, rst, p_out, expected_p_out, start, s_in, data, counter);
        fail_count = fail_count + 1;
      end
    end    
  end
    
endmodule