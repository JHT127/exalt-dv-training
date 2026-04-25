
// N-Bit Comparator Testbench Module 
module n_bit_comparator_tb;
  
  //Putting parameter to 4 for 4 bit comparator
  parameter n= 4;
 
  //Declaring---------------
  reg clk;  
  reg [n-1:0] x;
  reg [n-1:0] y;
  reg gt;
  reg lt;
  reg eq;
  reg expected_gt;
  reg expected_lt;
  reg expected_eq;
  reg [5:0]num_of_cycles;
  reg [5:0]num_of_cycles2;
  reg [5:0]num_of_cycles3;
  reg [5:0]num_of_cycles4;
  reg [5:0]num_of_cycles5;
  reg [n-1:0]eq_check_num;
  reg [n-1:0]adj_check_num;
  reg [n-1:0]cascade_check_num;
  integer pass_count;
  integer fail_count;
  integer i;
  wire x_gt_y;
  wire x_lt_y;
  wire x_eq_y;
  
  
  //DUT Instantiation--------------- 
  n_bit_comparator#(.n(n)) dut(
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
    eq_check_num = $urandom_range(0,2**n- 1);
    adj_check_num = $urandom_range(0,2**n- 2);
    cascade_check_num = $urandom_range(0,2**n- 1);
    num_of_cycles = $urandom_range(20,30);
    num_of_cycles2 = $urandom_range(70,80);
    num_of_cycles3 = $urandom_range(90,100);
    num_of_cycles4 = $urandom_range(110,120);
    num_of_cycles5 = $urandom_range(130,140);
  end
  
  
  //Driving---------------
  
    //Random testing 
    initial begin
      $display("\n======Starting Random Testing======");
      forever begin
        repeat(num_of_cycles) begin
          @(posedge clk);
        end 
        num_of_cycles <= $urandom_range(40,50);
        x <= $urandom_range(0,2**n- 1);
        y <= $urandom_range(0,2**n- 1);
        gt <= $urandom_range(0,1);
        lt <= $urandom_range(0,1);
        eq <= $urandom_range(0,1);
      end
    end
  
    //Random equality testing
    initial begin
      $display("======Starting Random Equality Testing======");
      forever begin
        eq_check_num <= $urandom_range(0,2**n- 1);
        repeat(num_of_cycles2)  begin
          @(posedge clk);
        end 
        num_of_cycles2 <= $urandom_range(70,80);
        eq <= 1;
        gt <= 0;
        lt <= 0;
        x <= eq_check_num;
        y <= eq_check_num;
        eq_check_num <= $urandom_range(0,2**n- 1);
      end
    end
  
    //All zeros test
    initial begin
      repeat(10) begin
        @(posedge clk);
      end
      $display("======Testing All Zeros (x=0, y=0)======");
      x <= 0;
      y <= 0;
      eq <= 1;
      gt <= 0;
      lt <= 0;
    end
  
    //All ones (maximum value) test
    initial begin
      repeat(15) begin
        @(posedge clk);
      end
      $display("======Testing All Ones (x=%0d, y=%0d)======", 2**n-1, 2**n-1);
      x <= 2**n - 1;
      y <= 2**n - 1;
      eq <= 1;
      gt <= 0;
      lt <= 0;
    end
  
    //Boundary tests (min vs max)
    initial begin
      repeat(25) begin
        @(posedge clk);
      end
      $display("======Testing Boundary (Min vs Max)======");
      x <= 0;
      y <= 2**n - 1;
      gt <= 0;
      lt <= 0;
      eq <= 0;
      @(posedge clk);
      x <= 2**n - 1;
      y <= 0;
    end
  
    //Adjacent values test
    initial begin
      $display("======Starting Adjacent Values Testing======");
      forever begin
        adj_check_num <= $urandom_range(0,2**n- 2);
        repeat(num_of_cycles3) begin
          @(posedge clk);
        end 
        num_of_cycles3 <= $urandom_range(90,100);
        x <= adj_check_num;
        y <= adj_check_num + 1;
        gt <= 0;
        lt <= 0;
        eq <= 0;
        @(posedge clk);
        x <= adj_check_num + 1;
        y <= adj_check_num;
        adj_check_num <= $urandom_range(0,2**n- 2);
      end
    end
  
    //Cascade input edge cases
    initial begin
      $display("======Starting Cascade Input Edge Cases Testing======");
      forever begin
        cascade_check_num <= $urandom_range(0,2**n- 1);
        repeat(num_of_cycles4) begin
          @(posedge clk);
        end 
        num_of_cycles4 <= $urandom_range(110,120);
        x <= cascade_check_num;
        y <= cascade_check_num;
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
        gt <= 1;
        @(posedge clk);
        gt <= 1;
    	lt <= 0;
    	eq <= 1;  // Both gt and eq high
        @(posedge clk);
        gt <= 0;
        lt <= 1;
        eq <= 1;  // Both lt and eq high
        @(posedge clk);
        cascade_check_num <= $urandom_range(0,2**n- 1);
      end
    end
  
    //Power-of-2 values test
    initial begin
      $display("======Starting Power-of-2 Values Testing======");
      forever begin
        repeat(num_of_cycles5) begin
          @(posedge clk);
        end 
        num_of_cycles5 <= $urandom_range(130,140);
        for (i = 0; i < n; i = i + 1) begin
          @(posedge clk);
          x <= 2**i;
          y <= 2**i;
          eq <= 1;
          gt <= 0;
          lt <= 0;
        end
      end
    end
  
    
  
  //Waveform---------------
  initial begin
    $dumpfile("waveform_4bit.vcd");
    $dumpvars(0, n_bit_comparator_tb);
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
      $display("PASS: Time=%0t | x=%d(%b) y=%d(%b) | Outputs: gt=%b lt=%b eq=%b", 
               $time, x, x, y, y, x_gt_y, x_lt_y, x_eq_y);
      pass_count = pass_count + 1;
    end
    else begin
      $display("FAIL: Time=%0t | x=%d(%b) y=%d(%b)", 
               $time, x, x, y, y);
      $display("      Expected: gt=%b lt=%b eq=%b | Got: gt=%b lt=%b eq=%b",
               expected_gt, expected_lt, expected_eq, x_gt_y, x_lt_y, x_eq_y);
      fail_count = fail_count + 1;
    end
  end
  end
      
endmodule