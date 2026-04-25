`timescale 1ns/1ps

//==============================================================================
// CASE 1: Clock Generation
//==============================================================================
module testbench_case1;
  reg clk;
  
  initial begin
    $dumpfile("case1.vcd");
    $dumpvars(0, testbench_case1);
    clk = 0;
    #2000 $finish;
  end
  
  // Generate clock with period T=10ns (100MHz)
  always #5 clk <= ~clk;
endmodule


//==============================================================================
// CASE 2: Assert and de-assert signal with random periods
//==============================================================================
module testbench_case2;
  reg signal;
  integer T1, T2;
  
  initial begin
    $dumpfile("case2.vcd");
    $dumpvars(0, testbench_case2);
    signal = 0;
  end
  
  // Toggle signal with random periods between 10ns and 50ns
  initial begin
    forever begin
      T1 = $urandom_range(50, 10);
      T2 = $urandom_range(50, 10);
      signal <= 1;
      #T1;
      signal <= 0;
      #T2;
    end
  end
  
  initial #2000 $finish;
endmodule


//==============================================================================
// CASE 3: Assert and de-assert signal on positive clock edge
//==============================================================================
module testbench_case3;
  reg clk, signal;
  
  initial begin
    $dumpfile("case3.vcd");
    $dumpvars(0, testbench_case3);
    clk = 0;
    signal = 0;
  end
  
  always #5 clk <= ~clk;
  
  // Change signal on clock edges after random number of cycles
  initial begin
    forever begin
      repeat ($urandom_range(5, 2)) @(posedge clk);
      signal <= 1;
      repeat ($urandom_range(3, 1)) @(posedge clk);
      signal <= 0;
    end
  end
  
  initial #2000 $finish;
endmodule


//==============================================================================
// CASE 4: Assert and de-assert signal with delay after clock edge
//==============================================================================
module testbench_case4;
  reg clk, signal_a, signal_b;
  integer d1, d2;
  
  initial begin
    $dumpfile("case4.vcd");
    $dumpvars(0, testbench_case4);
    clk = 0;
    signal_a = 0;
    signal_b = 0;
  end
  
  always #5 clk <= ~clk;
  
  // Toggle signals with random delay after clock edge
  initial begin
    forever begin
      d1 = $urandom_range(4, 1);
      d2 = $urandom_range(4, 1);
      @(posedge clk);
      #d1 signal_a <= ~signal_a;
      @(posedge clk);
      #d2 signal_b <= ~signal_b;
    end
  end
  
  initial #2000 $finish;
endmodule


//==============================================================================
// CASE 5: Signal depends on positive edge of another signal
//==============================================================================
module testbench_case5;
  reg signal_a, signal_b;
  integer T1, T2;
  
  initial begin
    $dumpfile("case5.vcd");
    $dumpvars(0, testbench_case5);
    signal_a = 0;
    signal_b = 0;
  end
  
  // Generate signal_a with random periods
  initial begin
    forever begin
      T1 = $urandom_range(80, 30);
      T2 = $urandom_range(80, 30);
      signal_a <= 1;
      #T1;
      signal_a <= 0;
      #T2;
    end
  end
  
  // Toggle signal_b on positive edge of signal_a
  initial begin
    forever begin
      @(posedge signal_a);
      signal_b <= ~signal_b;
    end
  end
  
  initial #2000 $finish;
endmodule


//==============================================================================
// CASE 6: Signal changes after N clock edges following trigger signal
//==============================================================================
module testbench_case6;
  reg clk, signal_a, signal_b;
  integer T1, T2, N;
  
  initial begin
    $dumpfile("case6.vcd");
    $dumpvars(0, testbench_case6);
    clk = 0;
    signal_a = 0;
    signal_b = 0;
  end
  
  always #5 clk <= ~clk;
  
  // Generate signal_a
  initial begin
    forever begin
      T1 = $urandom_range(80, 30);
      T2 = $urandom_range(80, 30);
      signal_a <= 1;
      #T1;
      signal_a <= 0;
      #T2;
    end
  end
  
  // Toggle signal_b after N clock edges from signal_a rising edge
  initial begin
    forever begin
      @(posedge signal_a);
      N = $urandom_range(8, 2);
      repeat (N) @(posedge clk);
      signal_b <= ~signal_b;
    end
  end
  
  initial #2000 $finish;
endmodule


//==============================================================================
// CASE 7: Two signals with two clocks, one depends on the other
//==============================================================================
module testbench_case7;
  reg clk1, clk2, signal_a, signal_b;
  
  initial begin
    $dumpfile("case7.vcd");
    $dumpvars(0, testbench_case7);
    clk1 = 0;
    clk2 = 0;
    signal_a = 0;
    signal_b = 0;
  end
  
  always #5 clk1 <= ~clk1;
  always #8 clk2 <= ~clk2;
  
  // Toggle signal_a on clk1 edges
  initial begin
    forever begin
      @(posedge clk1);
      signal_a <= ~signal_a;
    end
  end
  
  // Toggle signal_b on clk2 edges after signal_a rises
  initial begin
    forever begin
      @(posedge signal_a);
      @(posedge clk2);
      signal_b <= ~signal_b;
    end
  end
  
  initial #2000 $finish;
endmodule


//==============================================================================
// CASE 8: Signal gated by another signal
//==============================================================================
module testbench_case8;
  reg clk1, clk2, signal_a, signal_b;
  integer N;
  
  initial begin
    $dumpfile("case8.vcd");
    $dumpvars(0, testbench_case8);
    clk1 = 0;
    clk2 = 0;
    signal_a = 0;
    signal_b = 0;
  end
  
  always #6 clk1 <= ~clk1;
  always #9 clk2 <= ~clk2;
  
  // Toggle signal_a after random clk1 edges
  initial begin
    forever begin
      N = $urandom_range(10, 3);
      repeat (N) @(posedge clk1);
      signal_a <= ~signal_a;
    end
  end
  
  // Toggle signal_b on clk2 edges only when signal_a is high
  initial begin
    forever begin
      @(posedge clk2 iff signal_a == 1);
        signal_b <= ~signal_b;
    end
  end
  
  initial #2000 $finish;
endmodule


//==============================================================================
// CASE 9: Three signals with specific ordering
//==============================================================================
module testbench_case9;
  reg clk, signal_a, signal_b, signal_c;
  integer N;
  
  initial begin
    $dumpfile("case9.vcd");
    $dumpvars(0, testbench_case9);
    clk = 0;
    signal_a = 0;
    signal_b = 0;
    signal_c = 0;
  end
  
  always #5 clk <= ~clk;
  
  // Sequence: a asserts, b asserts 1 cycle later, c asserts N cycles after a, all de-assert together
  initial begin
    repeat (5) @(posedge clk);
    forever begin
      signal_a <= 1;
      @(posedge clk);
      signal_b <= 1;
      N = $urandom_range(5, 2);
      repeat (N - 1) @(posedge clk);
      signal_c <= 1;
      @(posedge clk);
      signal_a <= 0;
      signal_b <= 0;
      signal_c <= 0;
      repeat ($urandom_range(10, 3)) @(posedge clk);
    end
  end
  
  initial #2000 $finish;
endmodule


//==============================================================================
// CASE 10: Toggle signal when counter reaches specific value
//==============================================================================
module testbench_case10;
  reg clk, signal_b;
  reg [3:0] signal_a;
  
  initial begin
    $dumpfile("case10.vcd");
    $dumpvars(0, testbench_case10);
    clk = 0;
    signal_a = 0;
    signal_b = 0;
  end
  
  always #5 clk <= ~clk;
  
  initial begin
    forever begin
      @(posedge clk);      
      signal_a <= signal_a + 1;
    end
  end
  
  // Toggle signal_b when counter is at 7
  initial begin
    forever begin
      wait (signal_a == 7);
      repeat (4) begin
        @(posedge clk);
        signal_b <= ~signal_b;
      end
    end
  end
  
  initial #2000 $finish;
endmodule