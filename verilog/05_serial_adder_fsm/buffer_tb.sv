//Buffer Testbench Module

//`include "buffer.v"

module buffer_tb;
  
  
  //Declaring---------------
  reg clk;
  reg rst;
  reg in;
  reg [7:0] num_of_cycles_input;
  reg [9:0] reset_cycles;
  reg expected_out;
  integer pass_count;
  integer fail_count;
  integer reset_count;
  wire out;
    
  
  //DUT Instantiation---------------
  buffer dut(.clk(clk), .rst(rst), .in(in), .out(out));
    
                                    
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
    in = 0;
    pass_count = 0;
    fail_count = 0;
    num_of_cycles_input = 2;
    reset_cycles = 5;
    expected_out = 0;
    reset_count = 0;
  end
  
  
  //Initial Reset---------------
  initial begin
    rst <= 1;
    repeat(2) @(posedge clk);
    rst <= 0;
  end
                                    
  
  //Driving---------------
  
    //Driving the in input
    initial begin
      forever begin
        repeat(num_of_cycles_input) begin
          @(posedge clk);
        end 
        num_of_cycles_input <= $urandom_range(5, 15);
        in <= $urandom_range(0, 1);
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
    $dumpfile("waveform_buffer.vcd");
    $dumpvars(0, buffer_tb);
  end  
       
  
                                    
  //Finish and Test Status---------------
  initial begin
    #20000 
    $display("\n\n=====Test Summary=====");
    $display("%0d Tests Passed", pass_count);
    $display("%0d Tests Failed", fail_count);
    $display("\n=====Final Result=====");
    if(fail_count == 0) begin
      $display("PASS\n\n");
    end
    else begin
      $display("FAIL\n\n");
    end
    $finish;
  end
                                    
                                    
  //Checker and Reference Model---------------
  initial begin
    
    @(posedge rst);
    @(posedge clk iff rst == 0);
    
    forever begin     
       
      //Reference Model Logic (calculates expected values)
      if(rst) begin
        //corner case checking - reset detected
        reset_count = reset_count + 1;
        expected_out = 0;
        $display("-----------------RESET DETECTED-----------------");
      end
      else begin
        //normal operation - output follows input with one clock delay
        expected_out = in;
      end
       
      
      
      //wait for DUT to update
      @(posedge clk);
      
      
      
      //Comparison Logic
      if(out === expected_out) begin
        $display("PASS: Time=%0t | rst=%b | in=%b | out=%b | expected=%b", 
                   $time, rst, in, out, expected_out);
        pass_count = pass_count + 1;
      end 
      else begin
        $display("FAIL: Time=%0t | rst=%b | in=%b | out=%b | expected=%b", 
                   $time, rst, in, out, expected_out);
        fail_count = fail_count + 1;
      end
      
    end   
  end
     
endmodule