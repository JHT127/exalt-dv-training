// FSM Full Adder Testbench Module

//`include "fsm_full_adder.v"

module fsm_full_adder_tb;
  
  //Declaring---------------
  reg clk;
  reg rst;
  reg in_1;
  reg in_2;
  reg [7:0] num_of_cycles_in1;
  reg [7:0] num_of_cycles_in2;
  reg [9:0] reset_cycles;
  reg expected_sum;
  reg expected_carry;
  reg [1:0] expected_state;
  integer pass_count;
  integer fail_count;
  integer reset_during_compute_count;
  
  localparam IDLE = 2'b00;
  localparam COMPUTE = 2'b01;
  
  wire sum;
  
  
  //DUT Instantiation---------------
  fsm_full_adder dut(.clk(clk), .rst(rst), .in_1(in_1), .in_2(in_2), .sum(sum));
  
  
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
    in_1 = 0;
    in_2 = 0;
    pass_count = 0;
    fail_count = 0;
    num_of_cycles_in1 = 2;
    num_of_cycles_in2 = 3;
    reset_cycles = 50;
    expected_sum = 0;
    expected_carry = 0;
    expected_state = IDLE;
    reset_during_compute_count = 0;
  end
  
  
  //Initial Reset---------------
  initial begin
    rst <= 1;
    repeat($urandom_range(2,4)) @(posedge clk);
    rst <= 0;
  end
  
  
  //Driving---------------
  
    //Driving the in_1 input
    initial begin
      forever begin
        repeat(num_of_cycles_in1) @(posedge clk);
        num_of_cycles_in1 <= $urandom_range(1, 10);
        in_1 <= $urandom_range(0, 1);
      end 
    end

  
    //Driving the in_2 input
    initial begin
      forever begin
        repeat(num_of_cycles_in2) @(posedge clk);
        num_of_cycles_in2 <= $urandom_range(1, 10);
        in_2 <= $urandom_range(0, 1);
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
    $dumpfile("waveform_fsm_adder.vcd");
    $dumpvars(0, fsm_full_adder_tb);
  end  
  
  
  //Finish and Test Status---------------
  initial begin
    #20000 
    $display("\n\n=====Test Summary=====");
    $display("%0d Tests Passed", pass_count);
    $display("%0d Tests Failed", fail_count);
    $display("\n=====Corner Cases Detected=====");
    $display("%0d Resets During Compute State", reset_during_compute_count);
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
        if (expected_state == COMPUTE) begin 
          $display("-----------------RESET DURING COMPUTE-----------------");
          reset_during_compute_count = reset_during_compute_count + 1;
        end
        expected_state = IDLE;
        expected_carry = 0;
        expected_sum = 0;
      end
      
      else begin
        case (expected_state)
          IDLE: begin
            expected_state = COMPUTE;
            expected_sum = 0;
            expected_carry = 0;
          end
          
          COMPUTE: begin
            expected_state = COMPUTE;
            {expected_carry, expected_sum} = in_1 + in_2 + expected_carry;
          end
          
          default: begin
            expected_state = IDLE;
            expected_sum = 0;
            expected_carry = 0;
          end
        endcase
      end
      
      
      //wait for dut to update
      @(posedge clk);
      
      
      //checking
      if (sum === expected_sum) begin
        $display("PASS: Time=%0t | rst=%b | in_1=%b | in_2=%b | C_in=%b | sum=%b | expected=%b", 
                 $time, rst, in_1, in_2, expected_carry, sum, expected_sum);
        pass_count = pass_count + 1;
      end 
      else begin
        $display("FAIL: Time=%0t | rst=%b | in_1=%b | in_2=%b | C_in=%b | sum=%b | expected=%b", 
                 $time, rst, in_1, in_2, expected_carry, sum, expected_sum);
        fail_count = fail_count + 1;
      end
    end    
  end
    
endmodule