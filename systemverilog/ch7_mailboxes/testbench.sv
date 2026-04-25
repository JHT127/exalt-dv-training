//================================================================================================================================
//Mailbox Testbench---------------------------------------------------------------------------------------------------------------
//================================================================================================================================


`include "Producer.sv"
`include "Consumer.sv"


module testbench;

  
  
  //handles----------------------------------------------------------------------------------------------------------------------
  my_mailbox #(int) dut; // custom mailbox
  mailbox #(int) ref_mb; // Reference model
 
  
  
  //producers and consumers------------------------------------------------------------------------------------------------------
  Producer p1, p2;
  Consumer c1, c2;

  
  
  // Declare variables for use in loops ----------------------------------------------------------
  int data; // For Producer/Consumer data
  int my_val, ref_val; // Variables to store data we get from mailboxes
  int num_transactions; // Variable to control how many transactions we have
  int v; // For random data generation
  int d, r; // For data comparisons in parallel threads
  
  
  
  
  //build function (resets everything)-------------------------------------------------------------------------------------------
  function void build(int size);
    dut    = new(size);
    ref_mb = new(size);
    p1     = new(dut);
    p2     = new(dut);
    c1     = new(dut);
    c2     = new(dut);
  endfunction

  
  
  //main test---------------------------------------------------------------------------------------------------------------------
  initial begin

    
    
    //=============================================================================================================================
    // TEST 1: 1 Producer + 1 Consumer (Bounded Size 3)
    // Goal: Check basic sending/receiving and FIFO order
    //=============================================================================================================================
    
    
    $display("\n=== TEST 1: Basic Test (Size 3) ===");
    build(3);

    
    //Part A: Check Put, Peek, and Get---------------------------------------------------------------------------------------------
    $display("--- 1.1: Basic Operations ---");
    num_transactions = $urandom_range(3, 6); 

    
    
    repeat(num_transactions) begin
   
      
      data = $urandom_range(10, 99); // Random data 10-99
      $display("[TB-DEBUG] Generated random: %0d", data);
   
      
      // Send data
      p1.put(data); 
      ref_mb.put(data);
      $display("[TB] Put: %0d", data);
      
      
      
      // Check Peek (Look without removing)
      c1.peek(my_val);
      ref_mb.peek(ref_val);
      
      if (my_val !== ref_val) 
        $error("Error! Peek values do not match.");

      
      // Check Get (Remove the item)
      c1.get(my_val);
      ref_mb.get(ref_val);
      
      if (my_val !== ref_val) 
        $error("Error! Get values do not match.");
      else 
        $display("[TB] Match: %0d", my_val);
      
      
    end

    
    
    //Part B: Check blocking when Full--------------------------------------------------------------------------------------------
    $display("--- 1.2: Check Blocking (Full) ---");
    
    
    // Fill the mailbox up to size 3
    p1.put(1);  //1 represents the data
    ref_mb.put(1);
    p1.put(2); 
    ref_mb.put(2);
    p1.put(3); 
    ref_mb.put(3);
    
    
    
    fork
      
      
      // Thread 1: Try to put 4th item (Must wait)
      begin
        $display("[TB] Trying to put (Should wait)...");
        p1.put(4); // Waits here
        ref_mb.put(4);
        $display("[TB] Put successful (Space was freed)");
      end
      
      
      // Thread 2: Free up space after a delay
      begin
        #($urandom_range(10, 20)); // Random delay
        $display("[TB] Consumer taking item...");
        c1.get(my_val); 
        ref_mb.get(ref_val);
      end
      
      
    join

    
    
    //Part C: Check blocking when Empty--------------------------------------------------------------------------------------------
    $display("--- 1.3: Check Blocking (Empty) ---");
    
    
    // Empty the mailbox first
    while(dut.num() > 0) begin 
      c1.get(my_val); 
      ref_mb.get(ref_val); 
    end

    
    fork
      
      
      // Thread 1: Try to get item (Must wait)
      begin
        $display("[TB] Trying to get (Should wait)...");
        c1.get(my_val); // Waits here
        ref_mb.get(ref_val);
        $display("[TB] Got item: %0d", my_val);
      end
      
      
      
      // Thread 2: Send item after delay
      begin
        #($urandom_range(10, 20));
        $display("[TB] Producer sending item...");
        p1.put(99); 
        ref_mb.put(99);
      end
      
      
    join

    
    
    
    //==============================================================================================================================
    // TEST 2: Unbounded Test (Infinite Size)
    // Goal: Make sure 'put' never waits
    //==============================================================================================================================
    
    
    $display("\n=== TEST 2: Unbounded Test ===");
    build(0); // 0 means Unbounded
    num_transactions = $urandom_range(5, 10);

    
    
    fork
      
      
      // Thread 1: Send data fast
      begin
        repeat(num_transactions) begin
          v = $urandom_range(100, 199);
          p1.put(v);
          ref_mb.put(v);
          $display("[TB] Put: %0d", v);
          #($urandom_range(0, 1)); // Very short delay
        end
      end
      
      
      // Thread 2: Receive data slowly
      begin
        #($urandom_range(10, 15)); // Start later
        repeat(num_transactions) begin
          c1.get(my_val);
          ref_mb.get(ref_val);
          if (my_val !== ref_val) $error("Mismatch in Unbounded test");
        end
      end
      
      
    join
    $display("[TB] Unbounded Test Passed");

    
    
    
    
    //==============================================================================================================================
    // TEST 3: 1 Producer + 2 Consumers
    // Goal: Test 'try_get' and multiple readers
    //==============================================================================================================================
    
    
    $display("\n=== TEST 3: 1 Prod + 2 Cons (Try_Get) ===");
    build(10);
    num_transactions = 10;

    
    
    // Fill mailbox first
    repeat(num_transactions) begin 
      v = $urandom_range(200, 299); 
      p1.put(v); 
      ref_mb.put(v); 
    end

    
    
    fork
      
      
      // Consumer 1: Tries to get data
      repeat(num_transactions/2) begin
        #($urandom_range(1, 4));
        if (c1.try_get(my_val)) begin
           void'(ref_mb.try_get(ref_val)); // Get from reference too
           if(my_val !== ref_val) $error("Cons 1 Error");
           $display("[TB-C1] Got: %0d", my_val);
        end
      end
      
      
      // Consumer 2: Tries to get data
      repeat(num_transactions/2) begin
        #($urandom_range(1, 4));
        if (c2.try_get(my_val)) begin
           void'(ref_mb.try_get(ref_val)); 
           if(my_val !== ref_val) $error("Cons 2 Error");
           $display("[TB-C2] Got: %0d", my_val);
        end
      end
      
      
    join

    
    
    
    //==============================================================================================================================
    // TEST 4: 2 Producers + 1 Consumer
    // Goal: Test 'try_put' (fail when full)
    //==============================================================================================================================
    
    
    $display("\n=== TEST 4: 2 Prod + 1 Cons (Try_Put) ===");
    build(2); // Small size

  
    
    // Fill it
    p1.put(1); 
    ref_mb.put(1);
    p1.put(2); 
    ref_mb.put(2);

 
    
    // Both try to put (Should fail because it's full)
    if (p1.try_put(3) == 0) $display("[TB] P1 failed correctly (Full)");
    else $error("P1 Should have failed!");
 
    
    if (p2.try_put(4) == 0) $display("[TB] P2 failed correctly (Full)");
    else $error("P2 Should have failed!");

    
    // Remove one item
    c1.get(my_val);
    ref_mb.get(ref_val);
 
    
    // Now one should work
    if (p1.try_put(5)) begin
      void'(ref_mb.try_put(5));
      $display("[TB] P1 Success (Space free now)");
    end

    
    
    //==============================================================================================================================
    // TEST 5: 2 Producers + 2 Consumers (Bounded)
    // Goal: Verify thread safety and ordering with multiple threads
    //==============================================================================================================================
    
    
    $display("\n=== TEST 5: 2 Prod + 2 Cons (Bounded) ===");
    build(10); // Use a larger size to allow flow
    num_transactions = $urandom_range(5, 8); // Number of items per thread

    
    
    fork
      
      
      
      // Thread 1: Producer 1
      begin
        repeat(num_transactions) begin
          v = $urandom_range(100, 199); // Unique range for P1
          #($urandom_range(1, 3)); 
          p1.put(v);
          ref_mb.put(v);
          $display("[TB-P1] Put: %0d", v);
        end
      end

      
      
      // Thread 2: Producer 2
      begin
        repeat(num_transactions) begin
          v = $urandom_range(200, 299); // Unique range for P2
          #($urandom_range(1, 3));
          p2.put(v);
          ref_mb.put(v);
          $display("[TB-P2] Put: %0d", v);
        end
      end

      
      
      // Thread 3: Consumer 1
      begin
        repeat(num_transactions) begin
          #($urandom_range(2, 5));
          c1.get(d);
          ref_mb.get(r);
          $display("Consumer C1 got: %0d, Ref: %0d", d, r);
          if (d !== r) 
            $error("Cons 1 Mismatch! Dut:%0d Ref:%0d", d, r);
        end
      end


      // Thread 4: Consumer 2
      begin
        repeat(num_transactions) begin
          #($urandom_range(2, 5));
          c2.get(d);
          ref_mb.get(r);
          $display("Consumer C2 got: %0d, Ref: %0d", d, r);
          if (d !== r) 
            $error("Cons 2 Mismatch! Dut:%0d Ref:%0d", d, r);
        end
      end


      
    join
    $display("[TB] 2 Producers + 2 Consumers Test Passed");
    
    
    
    
    //==============================================================================================================================
    // TEST 6: Stress Test
    // Goal: Run everything at once to check stability
    //==============================================================================================================================
    
    
    $display("\n=== TEST 6: Stress Test ===");
    build(10);
    num_transactions = $urandom_range(5, 8);
    
    
    
    fork
      
      
      repeat(num_transactions) begin 
        v=$urandom; 
        #1; 
        p1.put(v); 
        ref_mb.put(v); 
      end
      
      repeat(num_transactions) begin
        v=$urandom; 
        #1; 
        p2.put(v); 
        ref_mb.put(v); 
      end
      
      repeat(num_transactions) begin 
        #2; 
        c1.get(d); 
        ref_mb.get(r); 
        if(d!=r) $error("Error"); 
      end
      
      repeat(num_transactions) begin 
        #2; 
        c2.get(d); 
        ref_mb.get(r); 
        if(d!=r) $error("Error"); 
      end
      
      
    join
    $display("[TB] Stress Test Passed");

    
    
    
    //==============================================================================================================================
    // EDGE CASE: Size = 1
    // Goal: Check weird size behavior
    //==============================================================================================================================
    
    
    $display("\n=== EDGE CASE: Size = 1 ===");
    build(1);
    
    
    p1.put(888);
    ref_mb.put(888);

    
    // Check Peek
    c1.peek(my_val);
    $display("[TB] Peeked: %0d", my_val);
  
    
    // Check Get
    c1.get(my_val);
    ref_mb.get(ref_val);
    $display("[TB] Got: %0d", my_val);
  
    
    if (my_val == 888 && ref_val == 888) 
        $display("[TB] Edge Case Passed");
    else 
        $error("Edge Case Failed");

    
    
    
    //==============================================================================================================================
    //Test Cases Passed-------------------------------------------------------------------------------------------------------------
    //==============================================================================================================================
    
    $display("\nALL TESTS PASSED");
    
    
  end

  
  
endmodule : testbench