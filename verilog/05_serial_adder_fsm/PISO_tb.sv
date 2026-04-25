// PISO Testbench Module

//`include "PISO.v"

module PISO_tb;
  
  //Declaring---------------
  reg clk;
  reg rst;
  reg shift_load;
  reg [7:0] p_in;
  reg [7:0] num_of_cycles_input;
  reg [7:0] num_of_cycles_shift;
  reg [9:0] reset_cycles;
  reg expected_out;
  reg active;
  reg [2:0] counter;
  reg [7:0] data;
  integer pass_count;
  integer fail_count;
  integer reset_during_shift_count;
  integer retrigger_during_shift_count;
  localparam shift_cycle_count = 8;
  wire s_out;
    
  
  //DUT Instantiation---------------
  PISO dut(.clk(clk), .rst(rst), .p_in(p_in), .shift_load(shift_load), .s_out(s_out));
    
                                    
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
    shift_load = 0;
    p_in = 0;
    pass_count = 0;
    fail_count = 0;
    num_of_cycles_input = 2;
    num_of_cycles_shift = 2;
    reset_cycles = 5;
    expected_out = 0;
    active = 0;
    counter = 0;
    data = 0;
    reset_during_shift_count = 0;
    retrigger_during_shift_count = 0;
  end
  
  
  //Initial Reset---------------
  initial begin
    rst <= 1;
    repeat($urandom_range(2,4)) @(posedge clk);
    rst <= 0;
  end
                                    
  
  //Driving---------------
  
    //Driving the p_in input
    initial begin
      forever begin
        repeat(num_of_cycles_input) begin
          @(posedge clk);
        end 
        num_of_cycles_input <= $urandom_range(5, 15);
        p_in <= $urandom_range(8'h00, 8'hFF);
      end 
    end

  
    //Driving the shift_load input
    initial begin
      forever begin
        
        //Normal operation
        repeat(num_of_cycles_shift) @(posedge clk);
        num_of_cycles_shift <= $urandom_range(10, 30);
        shift_load <= 1;
        
        //On-the-fly toggle test
        if ($urandom_range(0,1) == 1) begin
          repeat($urandom_range(2, 5)) @(posedge clk);
          shift_load <= 0;
          @(posedge clk);
          shift_load <= 1;
        end
        
        repeat($urandom_range(10,15)) @(posedge clk);
        shift_load <= 0;
        repeat($urandom_range(5,10)) @(posedge clk);
        
        //Extended HIGH hold test for the shift_load 
        repeat($urandom_range(10, 20)) @(posedge clk);
        shift_load <= 1; 
        repeat($urandom_range(15, 25)) @(posedge clk); 
        shift_load <= 0; 
        repeat($urandom_range(5,10)) @(posedge clk);
        
        //Rapid toggle test
        repeat($urandom_range(10, 20)) @(posedge clk); 
        shift_load <= 1;
        repeat(shift_cycle_count) @(posedge clk);
        shift_load <= 0;
        repeat($urandom_range(3,7)) @(posedge clk);
        shift_load <= 1;
        repeat($urandom_range(10,15)) @(posedge clk); 
        shift_load <= 0;
        
      end 
    end
  

    //Driving the rst 
    initial begin 
      forever begin
        repeat(reset_cycles) @(posedge clk);
        reset_cycles <= $urandom_range(10,60);
        rst <= 1;
        repeat($urandom_range(100,150)) @(posedge clk);
        rst <= 0;
      end
    end

                                    
  //Waveform---------------
  initial begin
    $dumpfile("waveform_piso.vcd");
    $dumpvars(0, PISO_tb);
  end  
                                    
                                    
  //Finish and Test Status---------------
  initial begin
    #20000 
    $display("\n\n=====Test Summary=====");
    $display("%0d Tests Passed", pass_count);
    $display("%0d Tests Failed", fail_count);
    $display("\n=====Corner Cases Detected=====");
    $display("%0d shift_load Toggles During Shift (Non-Retriggerable)", retrigger_during_shift_count);
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
        data = 8'b0;
        counter = 0;
        active = 0;
        expected_out = 0;
      end
      
      else begin
        if (shift_load && active && counter < shift_cycle_count - 1) begin
          $display("-----------------SHIFT_LOAD TOGGLED DURING SHIFT (IGNORED)-----------------");
          retrigger_during_shift_count = retrigger_during_shift_count + 1;
        end
       
        expected_out = 0;
        
        if (!shift_load && !active) begin
          data = p_in;
          counter = 0;
        end
        else if (shift_load && !active) begin
          active = 1;
          expected_out = data[0];
          data = {1'b0, data[7:1]};
          counter = counter + 1;
        end
        else if (active) begin
          expected_out = data[0];
          data = {1'b0, data[7:1]};
          if (counter == 7) begin
            active = 0;
          end
          counter = counter + 1;
        end
      end
         
      
      //wait for dut to update
      @(posedge clk);
      
      
      
      //checking
      if (s_out === expected_out) begin
        $display("PASS: Time=%0t | rst=%b | s_out=%b | expected=%b | shift_load=%b | p_in=%d | data=%d | counter=%d", 
                   $time, rst, s_out, expected_out, shift_load, p_in, data, counter);
        pass_count = pass_count + 1;
      end 
      else begin
        $display("FAIL: Time=%0t | rst=%b | s_out=%b | expected=%b | shift_load=%b | p_in=%d | data=%d | counter=%d", 
                   $time, rst, s_out, expected_out, shift_load, p_in, data, counter);
        fail_count = fail_count + 1;
      end
    end   
  end
     
endmodule
