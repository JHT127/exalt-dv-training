`include "one_bit_comparator.v"

// One-Bit Comparator Testbench Module 
module one_bit_comparator_tb;
  
  //Declaring---------------
  reg clk;  
  reg x;
  reg y;
  reg gt;
  reg lt;
  reg eq;
  reg expected_gt;
  reg expected_lt;
  reg expected_eq;
  reg [5:0]num_of_cycles;
  reg [5:0]num_of_cycles2;
  integer pass_count;
  integer fail_count;
  wire x_gt_y;
  wire x_lt_y;
  wire x_eq_y;
  
  
  //DUT Instantiation--------------- 
  one_bit_comparator dut(
    .x(x),
    .y(y),
    .gt(gt),
    .lt(lt),
    .eq(eq),
    .x_gt_y(x_gt_y),
    .x_lt_y(x_lt_y),
    .x_eq_y(x_eq_y)
  );
  
  
  //Generating the clock--------------- 
  initial begin
    clk = 0;
    forever begin
      #5 clk <= ~clk;
    end
  end
  
  
  //Initialisation---------------
  initial begin
    x = 0;
    y = 0;
    gt = 0;
    lt = 0;
    eq = 0;
    pass_count = 0;
    fail_count = 0;
    expected_gt = 0;
    expected_lt = 0;
    expected_eq = 0;
    num_of_cycles = $urandom_range(20,30);
    num_of_cycles2 = $urandom_range(70,80);
  end
  
  
  //Driving---------------
  
    //Random testing 
    initial begin
      forever begin
        repeat(num_of_cycles) begin
          @(posedge clk);
        end 
        num_of_cycles <= $urandom_range(40,50);
        x <= $urandom_range(0,1);
        y <= $urandom_range(0,1);
        gt <= $urandom_range(0,1);
        lt <= $urandom_range(0,1);
        eq <= $urandom_range(0,1);
      end
    end
  
    //Exhaustive testing (all combinations)
    initial begin
      repeat(10) begin
        @(posedge clk);
      end 
      gt <= 0;
      lt <= 0;
      eq <= 0;
      x <= 0;
      y <= 0;
      @(posedge clk);
      x <= 0;
      y <= 1;
      @(posedge clk);
      x <= 1;
      y <= 0;
      @(posedge clk);
      x <= 1;
      y <= 1;
    end
  
    //Cascade input edge cases
    initial begin
      forever begin
        repeat(num_of_cycles2) begin
          @(posedge clk);
        end 
        num_of_cycles2 <= $urandom_range(110,120);
        x <= $urandom_range(0,1);
        y <= x;
        gt <= 1;
        lt <= 0;
        eq <= 0;
        @(posedge clk);
        gt <= 0;
        lt <= 1;
        eq <= 0;
        @(posedge clk);
        gt <= 0;
        lt <= 0;
        eq <= 1;
        @(posedge clk);
        gt <= 0;
        lt <= 0;
        eq <= 0;
      end
    end
  
    
  
  //Waveform---------------
  initial begin
    $dumpfile("waveform_1bit.vcd");
    $dumpvars(0, one_bit_comparator_tb);
  end
  
  
  //Finish and Test Status---------------
  initial begin
    //repeat the simulation 300 cycles
    repeat(300) begin
      @(posedge clk);
    end 
    //Displaying Results
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
  
  
  //Checker---------------
  initial begin
    forever begin
    	@(posedge clk);
    
    //Reference Model 
    expected_gt = 0;
    expected_lt = 0;
    expected_eq = 0;
      
    if((x>y )|| ((x==y) && gt)) begin
       expected_gt=1;
    end
    if((x<y )|| ((x==y) && lt)) begin
       expected_lt=1;
    end
    if(x==y && eq)begin
       expected_eq=1;
    end
    
    
    //Comparison Logic
    if (x_gt_y === expected_gt && x_lt_y === expected_lt && x_eq_y === expected_eq) begin
      $display("PASS: Time=%0t | x=%b y=%b | Outputs: gt=%b lt=%b eq=%b", 
               $time, x, y, x_gt_y, x_lt_y, x_eq_y);
      pass_count = pass_count + 1;
    end
    else begin
      $display("FAIL: Time=%0t | x=%b y=%b", 
               $time, x, y);
      $display("      Expected: gt=%b lt=%b eq=%b | Got: gt=%b lt=%b eq=%b",
               expected_gt, expected_lt, expected_eq, x_gt_y, x_lt_y, x_eq_y);
      fail_count = fail_count + 1;
    end
  end
  end
      
endmodule

