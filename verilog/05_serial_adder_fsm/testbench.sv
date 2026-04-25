// Serial Adder Top Module Testbench

//`include "serial_adder.v"

module serial_adder_tb;
  
  //Declaring---------------
  reg clk;
  reg rst;
  reg [7:0] A;
  reg [7:0] B;
  reg shift_load;
  reg [7:0] num_of_cycles_input_A;
  reg [7:0] num_of_cycles_input_B;
  reg [7:0] num_of_cycles_shift;
  reg [9:0] reset_cycles; 
  reg [8:0] expected_sum;
  reg [7:0] A_checker;
  reg [7:0] B_checker;
  reg is_shifting;
  reg [3:0] cycle_counter;
  reg check_now; //flag to check if checking is valid 
  integer pass_count;
  integer fail_count; 
  integer reset_during_shift_count;
  integer retrigger_during_shift_count;
  wire [8:0] summation;
  
  
  //DUT Instantiation---------------
  serial_adder dut(
    .clk(clk),
    .rst(rst),
    .A(A),
    .B(B),
    .shift_load(shift_load),
    .summation(summation)
  );
  
  
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
    A = 0;
    B = 0;
    shift_load = 0;
    pass_count = 0;
    fail_count = 0;
    num_of_cycles_input_A = 2;
    num_of_cycles_input_B = 3;
    num_of_cycles_shift = 20;
    reset_cycles = 50;
    expected_sum = 0;
    A_checker = 0;
    B_checker = 0;
    is_shifting = 0;
    cycle_counter = 0;
    reset_during_shift_count = 0;;
    retrigger_during_shift_count = 0;
    check_now = 0;
  end
  
  
  //Initial Reset---------------
  initial begin
    rst <= 1;
    repeat($urandom_range(2,4)) @(posedge clk);
    rst <= 0;
  end
  
  
  //Driving---------------
  
    //Driving the A input
    initial begin
      forever begin
        repeat(num_of_cycles_input_A) @(posedge clk);
        num_of_cycles_input_A <= $urandom_range(5, 15);
        A <= $urandom_range(8'h00, 8'hFF);
      end 
    end

  
    //Driving the B input
    initial begin
      forever begin
        repeat(num_of_cycles_input_B) @(posedge clk);
        num_of_cycles_input_B <= $urandom_range(5, 15);
        B <= $urandom_range(8'h00, 8'hFF);
      end 
    end
  
  
    //Driving the shift_load input 
    initial begin
      forever begin
        repeat(num_of_cycles_shift) @(posedge clk);
        num_of_cycles_shift <= $urandom_range(8, 40); 
        shift_load <= 1;
        @(posedge clk);
        shift_load <= 0;
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
    $dumpfile("waveform_serial_adder.vcd");
    $dumpvars(0, serial_adder_tb);
  end  
  
  
  //Finish and Test Status---------------
  initial begin
    #20000
    $display("\n\n=====Test Summary=====");
    $display("%0d Tests Passed", pass_count);
    $display("%0d Tests Failed", fail_count);
    $display("\n=====Corner Cases Detected=====");
    $display("%0d Resets During Shift", reset_during_shift_count);
    $display("%0d Retriggers During Shift (Ignored)", retrigger_during_shift_count);
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
      check_now = 0;
      
      if(rst) begin
        if (is_shifting) begin
          $display("-----------------RESET DURING SHIFT-----------------");
          reset_during_shift_count = reset_during_shift_count + 1;
        end
        is_shifting = 0;
        cycle_counter = 0;
        expected_sum = 0;
        check_now = 0;
      end
      
      else begin
        // Corner Case: shift_load pulsed while already shifting
        if (shift_load && is_shifting) begin
          $display("-----------------RETRIGGER DURING SHIFT (IGNORED)-----------------");
          retrigger_during_shift_count = retrigger_during_shift_count + 1;
        end

        // Capture A and B before shift_load is asserted
        if (!shift_load && !is_shifting) begin
          A_checker = A;
          B_checker = B;
        end
        
        // Start of a new calculation
        if (shift_load && !is_shifting) begin
          is_shifting = 1;
          cycle_counter = 0;
          expected_sum = A_checker + B_checker; 
        end
        
        // Calculation in progress
        else if (is_shifting) begin
          if (cycle_counter == 11) begin
            is_shifting = 0;
            cycle_counter = 0;
            check_now = 1; // Set flag to check the output after the clock tick
          end
          else begin
            cycle_counter = cycle_counter + 1;
          end
        end
      end
      
      
      //wait for dut to update
      @(posedge clk);
      
      
      //checking
      if (check_now) begin
        if (summation === expected_sum) begin
          $display("PASS: Time=%0t | rst:%0b | A=%d, B=%d | Sum=%d", 
                   $time, rst, A_checker, B_checker, expected_sum);
          pass_count = pass_count + 1;
        end 
        else begin
          $display("FAIL: Time=%0t | rst:%0b | A=%d, B=%d | Expected Sum=%d | Got=%d", 
                   $time, rst, A_checker, B_checker, expected_sum, summation);
          fail_count = fail_count + 1;
        end
      end
    end    
  end
    
endmodule