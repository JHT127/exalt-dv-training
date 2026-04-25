module updown_counter_tb;
  
  //Declare the wires and regs need to be connected to the design as inputs and outputs and the variables used in checker
  reg clk;
  reg rst;
  reg load;
  reg up_down;
  reg [7:0] in;
  reg [7:0] expected_count;
  reg [3:0] reset_cycles;
  reg [3:0] load_cycles;
  reg [3:0] up_down_cycles;
  reg [1:0] consecutive_load_count;
  wire [7:0] count;
  integer pass_count;
  integer fail_count;
  
  //Instantiate the design and connect the wires and regs to the instance using pass-by-name
  updown_counter dut(
    .clk(clk),
    .rst(rst),
    .load(load),
    .up_down(up_down),
    .in(in),
    .count(count)
  );
  localparam cycle_delay = 10;
  
  
  //Generate the clock
  initial begin
    clk = 0;
    forever begin
      #5 clk <= ~clk;
    end
  end
  
  
  //Initializing the inputs of the design and the variables used in the checker
  initial begin
    rst = 1;
    load = 0;
    up_down = 0;
    in = 8'd0;
    expected_count = 8'd0;
    reset_cycles = 4'd4;
    load_cycles = 4'd5;
    up_down_cycles = 4'd6;
    pass_count = 0;
    fail_count = 0;
  end
  
  
  //Drive the reset such that it will have the three regions
  initial begin
    rst <= 1;
    repeat ($urandom_range(2, 4)) begin
      @(posedge clk);
    end
    rst <= 0;
    repeat ($urandom_range(3, 5)) begin
      @(posedge clk);
    end
    rst <= 1;
  end
  
  //Drive the different inputs of the design with random value and random delays
  
  //Drive the in signal
  initial begin
    forever begin
      repeat (load_cycles) begin
        @(posedge clk);
      end
      in <= $urandom_range(0, 255);
      load_cycles <= $urandom_range(3, 8);
    end
  end
 
  //Drive the up_down signal
  initial begin
    forever begin
      repeat (up_down_cycles) begin
        @(posedge clk);
      end
      up_down <= $urandom_range(0, 1);
      up_down_cycles <= $urandom_range(4, 9);
    end
  end
    
  //Drive the load signal
  initial begin
    forever begin
      // Load values near 0 for potential UNDERFLOW testing
      repeat (load_cycles) begin
        @(posedge clk);
        load <= 0;
      end
      load <= 1;
      in <= $urandom_range(0, 1);
      
      repeat (load_cycles) begin
        @(posedge clk);
        load <= 0;
      end
      load <= 1;
      in <= $urandom_range(0, 2);
      load_cycles <= $urandom_range(1, 5);
      
      // Potentially CONSECUTIVE LOADS
      repeat (load_cycles) begin
        @(posedge clk);
        load <= $urandom_range(0, 1);
      end
      
      // Load values near 255 for potential OVERFLOW testing
      repeat (load_cycles) begin
        @(posedge clk);
        load <= 0;
      end
      load <= 1;
      in <= $urandom_range(254, 255);
      
      repeat (load_cycles) begin
        @(posedge clk);
        load <= 0;
      end
      load <= 1;
      in <= $urandom_range(254, 255);
      
      // Random loads for general testing
      repeat (load_cycles) begin
        @(posedge clk);
        load <= 0;
      end
      load <= 1;
      in <= $urandom_range(0, 255);
      load_cycles <= $urandom_range(4, 7);
    end
  end
  
  //Drive the rst signal during the test to enable a Reset Test
  initial begin
    @(posedge clk);
    repeat ($urandom_range(50, 70)) begin
      @(posedge clk);
    end
    rst <= 0;
    repeat ($urandom_range(2, 4)) begin
      @(posedge clk);
    end
    rst <= 1;
  end
  
  //Dump the waveforms
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, updown_counter_tb);
  end
  
  
  //Finish the test with appropriate simulation time and print the test status
  initial begin
    #800;
    $display("\n========================================");
    $display("              TEST SUMMARY                ");
    $display("==========================================");
    $display("Total PASS: %0d", pass_count);
    $display("Total FAIL: %0d", fail_count);
    if (fail_count == 0) begin
      $display("\n*** ALL TESTS PASSED ***");
    end else begin
      $display("\n*** TEST FAILED ***");
    end
    $display("========================================\n");
    $finish;
  end
  
  
  //Build a simple Checker with the needed code for the reference model of the design
  initial begin
    @(negedge rst);
    forever begin
      @(posedge clk);
      
      if (!rst) begin
        expected_count = 8'd0;
      end else begin
        if (load) begin
          expected_count = in;
        end else if (up_down) begin
          expected_count = expected_count + 8'd1;
        end else begin
          expected_count = expected_count - 8'd1;
        end
      end
      
      #cycle_delay;
      
      if (count === expected_count) begin
        $display("PASS: Time=%0t | count=%0d | expected=%0d | rst=%b | load=%b | in=%0d | up_down=%b", 
                 $time, count, expected_count, rst, load, in, up_down);
        
        pass_count = pass_count + 1;
        
        if (count == 8'd255 && !load && up_down && rst) begin
          $display("----------------------------OVERFLOW CORNER CASE------------------------------------------");
        end
        
        if (count == 8'd0 && !load && !up_down && rst) begin
          $display("----------------------------UNDERFLOW CORNER CASE------------------------------------------");
        end
        
        if(load) begin
          consecutive_load_count++;
        end else begin
          consecutive_load_count=0;
        end 
        if (consecutive_load_count==2)begin
          $display("----------------------------CONSECUTIVE LOADs-------------------------------------------");
        end
        
        
      end 
      else begin
        $display("FAIL: Time=%0t | count=%0d | expected=%0d | rst=%b | load=%b | in=%0d | up_down=%b", 
                 $time, count, expected_count, rst, load, in, up_down);
        fail_count = fail_count + 1;
      end
      
    end
  end
  
endmodule