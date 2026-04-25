`timescale 1ns/1ps // Sets our time units: #1 means 1 nanosecond
 
// This is my main testbench module
module testbench_task1;
 
  // --- 1. Signal Declarations ---
  // I will declare ALL the signals for ALL 10 cases here.
  // Use 'reg' because we are controlling them from the testbench.
  
  // Case 1
  reg clk_c1;
  
  // Case 2
  reg signal_c2;
  
  // Case 3
  reg clk_c3;
  reg signal_c3;
  
  // Case 4
  reg signal_a_c4;
  reg signal_b_c4;
  
  // Case 5
  reg signal_a_c5;
  reg signal_b_c5;
  
  // Case 6
  // (I'll re-use clk_c3 and signal_a_c5)
  reg signal_b_c6;
 
  // Case 7
  reg clk1_c7;
  reg clk2_c7;
  reg signal_a_c7;
  reg signal_b_c7;
  
  // Case 8
  reg clk1_c8;
  reg clk2_c8;
  reg signal_a_c8;
  reg signal_b_c8;
  
  // Case 9
  // (I'll re-use clk_c3)
  reg signal_a_c9;
  reg signal_b_c9;
  reg signal_c_c9;
  
  // Case 10
  // (I'll re-use clk_c3)
  reg [3:0] signal_a_c10; // This is a 4-bit bus
  reg signal_b_c10;
 
  
  // Setup waveform dumping 
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench_task1); // Dump all signals in this module
  end
  
  
  // --- 2. Main Simulation Control ---
  initial begin
    // This block runs only ONCE at the start.
    
    // Initialize all signals to 0 to avoid 'X' (unknown)
    clk_c1 = 0;
    signal_c2 = 0;
    clk_c3 = 0;
    signal_c3 = 0;
    signal_a_c4 = 0;
    signal_b_c4 = 0;
    signal_a_c5 = 0;
    signal_b_c5 = 0;
    signal_b_c6 = 0;
    clk1_c7 = 0;
    clk2_c7 = 0;
    signal_a_c7 = 0;
    signal_b_c7 = 0;
    clk1_c8 = 0;
    clk2_c8 = 0;
    signal_a_c8 = 0;
    signal_b_c8 = 0;
    signal_a_c9 = 0;
    signal_b_c9 = 0;
    signal_c_c9 = 0;
    signal_a_c10 = 4'b0; // Use 4'b0 to initialize a 4-bit value
    signal_b_c10 = 0;
 
 
    // We use 'fork...join' to make all our independent test case tasks
    // start running at the same time, in parallel.
    fork
      gen_case1;
      gen_case2;
 
      
      
      // This is the clock generator for many of our    cases (C3, C4, C6, C9, C10)
      //I put the clock generator inside the fork...join so it starts running at the same time as all the other test cases that depend on it.
      
      
      begin
      //I used a parameter to give the clock's period a clear name and make it easy to change in one single place.
        parameter T_CLK = 10; // 10ns clock (5ns high, 5ns low)
        forever #(T_CLK/2) clk_c3 = ~clk_c3;
      end
 
      
      
      gen_case3;
      gen_case4;
      gen_case5;
      gen_case6;
      gen_case7;
      gen_case8;
      gen_case9;
      gen_case10;
    join_none
      
    // Let the simulation run for 2000ns
    #2000;
    $finish; // Stop the simulation
  end
  
  
  
  
  // --- 3. Stimulus Generation Tasks ---
  // I used tasks because they are the only Verilog  blocks  that let us control time, using delays (#) and waiting for clock edges (@(posedge)).
  
  
  // Case 1: Clock Generation
  // Goal: Generate a clock with a specific period. The document gave the formula T=1/frequency to show how to calculate the period (T).
  
  task gen_case1;
    
    // I'll define the period 'T' as a parameter for readability and easy changes as I mentioned before.
    // Let's use a 10ns period (which equals 1/100MHz frequency).
    parameter T_C1 = 10;
    
    begin
      // We use a 'forever' loop to make the clock run for the whole simulation.
      // We use '#(T_C1 / 2)' to wait for exactly half the period (5ns).
      // We use '~clk_c1' to invert the signal (0->1 or 1->0), creating the clock edge.
      forever begin
        #(T_C1 / 2) clk_c1 = ~clk_c1;
      end
    end
  endtask
  
  
  
  
  // Case 2: Assert and de-assert signal with random periods
  // Goal: Assert a signal (set to 1) for a random time T1, then de-assert it (set to 0) for a random time T2, and repeat this forever. 
  task gen_case2;
    
    // We declare 'T1' and 'T2' as 'integer' variables to hold the random time values.
    integer T1, T2;
    
    begin
      forever begin
        
        // '$urandom_range(max, min)' gives a random number between min and max.
        // Here, we get random periods between 10ns and 50ns.
        T1 = $urandom_range(50, 10);
        T2 = $urandom_range(50, 10);
        
        signal_c2 = 1; // Assert the signal (set to 1)
        #T1;           // Wait for the random T1 duration
        signal_c2 = 0; // De-assert the signal (set to 0)
        #T2;           // Wait for the random T2 duration
      end
    end
  endtask
 
  
  
  // Case 3: Assert and de-assert a signal depending on the positive edge of the clock
  // Goal: Change a signal's value at the exact moment of a positive clock edge.
  // We use 'clk_c3', which is already being generated in parallel by our main 'fork...join' block.
  task gen_case3;
    
    begin
      forever begin
        
        // We use '$urandom_range' to wait for a random number of clock cycles (2 to 5).
        // Using random cycles helps find bugs by testing many different timing scenarios, not just one fixed pattern.
        repeat ($urandom_range(5, 2)) begin
          @(posedge clk_c3); // This WAITS for one positive clock edge.
        end
        
        // Assert the signal (changes exactly on the clock edge).
        signal_c3 = 1;
        
        // Wait for another random number of clock edges (1 to 3).
        repeat ($urandom_range(3, 1)) begin
          @(posedge clk_c3);
        end
        
        // De-assert the signal (also changes exactly on the clock edge).
        signal_c3 = 0;
      end
    end
  endtask
  
  
  
  // Case 4: Assert and de-assert a signal depending on a certain delay after the positive edge of the clock
  // Goal: Change a signal's value after a small, random delay following the clock's positive edge, not directly on the edge.
  task gen_case4;
    
    // I'll re-use 'clk_c3', our common clock.
    // We declare 'd1' and 'd2' as integers to hold the random delay values.
    integer d1, d2;
    
    begin
      forever begin
        // Get random delays. These delays MUST be shorter than the full clock period (10ns).
        // If the delay was longer (e.g., 12ns), the 'forever' loop would try to run the next '@(posedge)' before this delay finished, breaking the logic.
        d1 = $urandom_range(4, 1); // Random delay 1ns to 4ns
        d2 = $urandom_range(4, 1);
        
        // --- Logic for signal_a ---
        @(posedge clk_c3); // 1. Wait for the positive clock edge.
        #d1;               // 2. Wait for the additional random delay 'd1'.
        signal_a_c4 = ~signal_a_c4; // 3. Toggle the signal.
        
        // --- Logic for signal_b ---
        @(posedge clk_c3); // 1. Wait for the next positive clock edge.
        #d2;               // 2. Wait for the additional random delay 'd2'.
        signal_b_c4 = ~signal_b_c4; // 3. Toggle the signal.
      end
    end
  endtask
  
  
  
  // Case 5: Assert and de-assert a signal depending on the positive edge of another signal
  // Goal: Make 'signal_b' change its value exactly on the positive edge (0-to-1 transition) of 'signal_a'. Note that 'signal_a' is not a clock; it's an asynchronous signal.
  task gen_case5;
    
    // This task needs two processes to run in parallel:
    // 1. A process to generate 'signal_a' (so we have something to watch).
    // 2. A process to watch 'signal_a' and control 'signal_b'.
    
    begin
      // We use this 'fork...join' to run this task's two internal threads in parallel;
      // it is safely nested and will not conflict with the main 'fork...join' block.
      fork
        // Thread 1: Generate 'signal_a'
        // I'll make 'signal_a' behave like Case 2, with random on/off periods.
        begin
          integer T1, T2;
          forever begin
            T1 = $urandom_range(80, 30); // Assert for 30-80ns
            T2 = $urandom_range(80, 30); // De-assert for 30-80ns
            signal_a_c5 = 1; #T1;
            signal_a_c5 = 0; #T2;
          end
        end
        
        // Thread 2: Generate 'signal_b'
        // This process just watches for 'signal_a' to rise.
        begin
          forever begin
            // Wait for the positive edge of 'signal_a'
            @(posedge signal_a_c5);
            
            // When the edge happens, toggle 'signal_b'
            signal_b_c5 = ~signal_b_c5;
          end
        end
        
      join // End of the internal parallel fork...join block
    end
  endtask
  
  
  
  // Case 6: Assert and de-assert a signal after a random number of positive edges of the clock depending on the positive edge of another signal.
  // Goal: Wait for a trigger ('signal_a') to rise, then wait for a random number (N) of clock cycles, and only then change 'signal_b'.
  task gen_case6;
    
    // I will re-use 'signal_a_c5' as our trigger and 'clk_c3' as our clock.
    // 'N' will hold the random number of cycles to wait.
    integer N;
    
    begin
      forever begin
        
        // 1. Wait for the trigger signal 'signal_a_c5' to have a positive edge.
        @(posedge signal_a_c5);
        
        // 2. Once triggered, get a random number of clock cycles to wait.
        N = $urandom_range(8, 2);
        
        // 3. Wait for exactly 'N' positive clock edges.
        // The 'repeat' loop executes the '@(posedge)' N times.
        repeat (N) begin
          @(posedge clk_c3);
        end
        
        // 4. After N cycles have passed, toggle 'signal_b_c6'.
        signal_b_c6 = ~signal_b_c6;
      end
    end
  endtask
  
  
  
  // Case 7: Assert and de-assert 2 signals after a random number of positive edges of 2 different clocks, where one depends on the other.
  // Goal: Create two signals, 'signal_a' and 'signal_b', that change based on two  different clocks ('clk1' and 'clk2'). - 'signal_a' changes based on 'clk1'.  - 'signal_b' changes based on 'signal_a' AND 'clk2'. [cite: 30]
  task gen_case7;
    
    // I will use an internal 'fork...join' to run four processes in parallel.
    begin
      fork
        // Thread 1: clk1 generator
        forever #5 clk1_c7 = ~clk1_c7;
    
        // Thread 2: clk2 generator (e.g., 16ns period, different from clk1)
        forever #8 clk2_c7 = ~clk2_c7;
        
        // Thread 3: 'signal_a' generator
        begin
          integer N_a; // Variable for random cycle count
          forever begin
            // Wait for a random number (3-10) of 'clk1' edges
            N_a = $urandom_range(10, 3);
            repeat (N_a) @(posedge clk1_c7);
            
            // Toggle 'signal_a' (based only on 'clk1')
            signal_a_c7 = ~signal_a_c7;
          end
        end
        
        // Thread 4: 'signal_b' generator
        begin
          integer N_b; // Variable for random cycle count
          forever begin
            // 1. Wait for the trigger (positive edge of 'signal_a')
            @(posedge signal_a_c7);
            
            // 2. Wait for a random number (2-6) of 'clk2' edges
            N_b = $urandom_range(6, 2);
            repeat (N_b) @(posedge clk2_c7);
            
            // 3. Toggle 'signal_b' (based on 'signal_a' AND 'clk2')
            signal_b_c7 = ~signal_b_c7;
          end
        end
        
      join // End of the internal parallel fork...join
    end
  endtask
  
  
  // Case 8: Assert and de-assert 2 signals after a random number of positive edges of 2 different clocks, where one signal 'gates' (enables) the other.
  // Goal: 'signal_a' changes based on 'clk1'. 'signal_b' can only change on a 'clk2' edge *if* 'signal_a' is 1 (asserted).
  task gen_case8;
    
    // This case also needs four parallel threads, so we use an internal 'fork...join'.
    begin
      fork
        // Thread 1: clk1 generator 
        forever #6 clk1_c8 = ~clk1_c8;
    
        // Thread 2: clk2 generator 
        forever #9 clk2_c8 = ~clk2_c8;
        
        // Thread 3: 'signal_a' generator (based on clk1)
        begin
          integer N_a; // Variable for random cycle count
          forever begin
            // Wait for a random number (3-10) of 'clk1' edges
            N_a = $urandom_range(10, 3);
            repeat (N_a) @(posedge clk1_c8);
            
            // Toggle 'signal_a'
            signal_a_c8 = ~signal_a_c8;
          end
        end
        
        // Thread 4: 'signal_b' generator (enabled by 'signal_a')
        begin
          forever begin
            // 1. Wait for a positive edge of 'clk2'
            @(posedge clk2_c8);
            
            // 2. Check if 'signal_a' is asserted (is 1)
            if (signal_a_c8 == 1) begin
              // 3. Only if 'signal_a' is 1, toggle 'signal_b'
              signal_b_c8 = ~signal_b_c8;
            end
            // If 'signal_a_c8' is 0, nothing happens on this clk2 edge.
          end
        end
        
      join // End of the internal parallel fork...join
    end
  endtask
  
  
  
  // Case 9: Assert and de-assert group of signals according to a specific order
  // Goal: Create a specific, synchronous sequence between three signals (a, b, c)  based on a set of timing rules.
  task gen_case9;
    
    // I'll re-use 'clk_c3' as the single clock for all signals.
    integer N_c; // For the random delay before 'c' asserts.
    
    begin
      // Wait for a few cycles at the start to let other signals settle.
      repeat (5) @(posedge clk_c3);
      
      forever begin
        
        // 1. Assert 'signal-a' freely
        signal_a_c9 = 1;
        
        // 2. 'signal-b' asserts 1 cycle after 'signal-a'.
        @(posedge clk_c3);
        signal_b_c9 = 1;
        
        // 3. 'signal-c' asserts 'some' (random) cycles after 'a' asserted.
        //We already waited 1 cycle for 'b', so we'll wait N-1 more.
        N_c = $urandom_range(5, 2); // 'some' = 2 to 5 cycles total.
        repeat (N_c - 1) @(posedge clk_c3);
        
        // At this point, 'N_c' cycles have passed since 'a' asserted.
        signal_c_c9 = 1; // Assert 'c'.
        
        // 4. On the next clock edge:
        // - 'signal-c' de-asserts (1 cycle after asserting).
        // - 'signal-a' de-asserts (1 cycle after 'c' asserted).
        // - 'signal-b' de-asserts (1 cycle after 'c' asserted).
        @(posedge clk_c3);
        signal_c_c9 = 0;
        signal_a_c9 = 0;
        signal_b_c9 = 0;
        
        // Wait for a random time before starting the sequence all over again.
        repeat ($urandom_range(10, 3)) @(posedge clk_c3);
      end
    end
  endtask
 
  
  
  // Case 10: Toggle a signal depending on a value of another signal and the clock
  // Goal: Toggle 'signal_b' on every positive clock edge, but only if the 4-bit signal 'signal_a' has the specific value of 7.
  task gen_case10;
    
    // I'll re-use 'clk_c3' as our clock.
    
    begin
      fork
        // Thread 1: The Counter (for signal_a)
        // This process increments the counter, but I've added logic to
        // make it 'pause' (hold) the value 7 for 3 extra clock cycles.
        begin
          forever begin
            @(posedge clk_c3);
            
            // This 'if' statement checks if 'a' is  7
            if (signal_a_c10 == 7) begin
              // If it is 7, wait for 3 more cycles.
              // 'signal_a_c10' will not be changed during this time.
              repeat (3) begin
                @(posedge clk_c3);
              end
            end
            
            // Increment the counter. This will happen on every cycle
            // unless it was 7, in which case it happens after the pause.
            signal_a_c10 = signal_a_c10 + 1;
          end
        end
        
        // Thread 2: The Toggler (for signal_b)
        // It will now see 'signal_a_c10 == 7'
        // for 4 cycles in a row and will toggle on each of them.
        begin
          forever begin
            @(posedge clk_c3);
            if (signal_a_c10 == 7) begin
              signal_b_c10 = ~signal_b_c10;
            end
          end
        end
        
      join // End of the internal parallel fork...join
    end
  endtask
   
endmodule