//Non-Retriggerable Monoshot Testbench Module

module non_retriggerable_monoshot_tb;
  
  //Declaring---------------
  reg clk;
  reg rst;
  reg trigger;
  reg [7:0] num_of_cycles;
  reg [5:0] retrigger_time;
  reg [9:0] reset_cycles;
  reg expected_out;
  reg active;
  reg [7:0] counter;
  integer pass_count;
  integer fail_count;
  integer ignored_trigger_count;
  integer reset_during_pulse_count;
  integer consecutive_trigger_flag;
  localparam active_cycle_count = 128;
  wire out;
    
  
  //DUT Instantiation---------------
  non_retriggerable_monoshot dut(.clk(clk), .rst(rst), .trigger(trigger), .out(out));
    
                                    
  //Generating the clock---------------
  initial begin
    forever begin
      #5 clk <= ~clk;
    end
  end
                                    
      
  //Initialisation---------------
  initial begin
    clk = 0;
    rst = 1;
    trigger = 0;
    pass_count = 0;
    fail_count = 0;
    num_of_cycles = 0;
    retrigger_time = 0;
    reset_cycles = 0;
    expected_out = 0;
    active = 0;
    counter = 0;
    ignored_trigger_count = 0;
    reset_during_pulse_count = 0;
    consecutive_trigger_flag = 0;
  end
                                    
  
  //Initial Reset---------------
  initial begin
    rst <= 1;
    repeat($urandom_range(2,4)) begin
      @(posedge clk);
    end
    rst <= 0;
    repeat($urandom_range(3,5)) begin
      @(posedge clk);
    end 
    rst <= 1;
  end
      
                                    
  //Driving---------------
  
  //Driving the trigger input
  initial begin
    trigger <= 0; // ensure trigger is low

    forever begin
        //Random test
		// wait for a random idle period
    		num_of_cycles = $urandom_range(10, 50);
    		repeat(num_of_cycles) begin
    			@(posedge clk);
    		end 
    		
		// send a single-cycle trigger pulse
    		trigger <= 1;
    		@(posedge clk);
    		trigger <= 0;
    		
		// testing the non-retriggerablility 
    		if ($urandom_range(0,1) == 1) begin
    			retrigger_time = $urandom_range(10, 60); //< 128
    			repeat(retrigger_time) @(posedge clk);
    			
			// send a second pulse (should be ignored)
    			trigger <= 1;
    			@(posedge clk);
    			trigger <= 0 ;
    		end 
    		
		// wait for the 128-cycle pulse to finish before looping
    		repeat($urandom_range(130,150)) @(posedge clk);
            
            
        //Test Consecutive Triggers 
        repeat($urandom_range(10, 50)) @(posedge clk); // idle
        
        // trigger and hold for 1-5 cycles
        trigger <= 1; 
        repeat($urandom_range(1, 5)) @(posedge clk); 
        trigger <= 0; 
        repeat($urandom_range(130,150)) @(posedge clk); 


        //Test Trigger on Boundary (After Pulse End)
        repeat($urandom_range(10, 50)) @(posedge clk); 
        
        // 1. start a normal pulse
        trigger <= 1; @(posedge clk);
        trigger <= 0;

        // 2. wait for the exact pulse duration
        repeat(active_cycle_count) @(posedge clk);

        // 3. trigger on the very next cycle
        trigger <= 1; @(posedge clk);
        trigger <= 0;
        
        repeat($urandom_range(130,150)) @(posedge clk); 
            
    end 
  end
  
    //Driving the rst 
    initial begin 
      forever begin
      reset_cycles = $urandom_range(200,300);
      repeat(reset_cycles) @(posedge clk);
        
      rst <= 0;
      repeat($urandom_range(2,10)) @(posedge clk);
      rst <= 1;
      end
    end
                                  
                                    
  //Waveform---------------
  initial begin
   $dumpfile("waveform.vcd");
   $dumpvars(0, non_retriggerable_monoshot_tb);
  end  
                                    
                                    
  //Finish and Test Status---------------
  initial begin
   #20000 
   $display("\n\n=====Test Summary=====");
   $display("%0d Tests Passed", pass_count);
   $display("%0d Tests Failed", fail_count);
   $display("\n=====Corner Cases Detected=====");
   $display("%0d Ignored Triggers (Non-Retriggerable)", ignored_trigger_count);
   $display("%0d Resets During Pulse", reset_during_pulse_count);
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
    
     @(negedge rst);
     @(posedge clk iff rst == 1);
     forever begin     
       
       //Reference Model Logic (calculates expected values)
       if(!rst) begin
         
         //corner case checking - reset during pulse
         if (active) begin 
           $display("-----------------RESET DURING PULSE-----------------");
           reset_during_pulse_count = reset_during_pulse_count + 1;
         end
         
         expected_out = 0;
         counter = 0;
         active = 0;
         consecutive_trigger_flag = 0;
       end
       else begin
         
         //corner case checking - consecutive triggers 
         if (trigger && active) begin
           consecutive_trigger_flag = consecutive_trigger_flag + 1;
         end else begin
           consecutive_trigger_flag = 0;
         end
         
         if (consecutive_trigger_flag == 2) begin
           $display("-----------------CONSECUTIVE TRIGGERS (IGNORED)-----------------");
           ignored_trigger_count = ignored_trigger_count + 1;
         end
         
         //safety check - counter should never exceed max cycles
         if (counter > active_cycle_count) begin
           $display("-----------------ERROR: COUNTER EXCEEDED MAX CYCLES-----------------");
           fail_count = fail_count + 1;
         end
       
         if (trigger && !active) begin
           expected_out = 1;
           active = 1;
           counter = 0;
         end
         else if (active) begin
           if(counter == active_cycle_count - 1) begin
             expected_out = 0;
             active = 0;
             counter = 0;
           end
           else begin
             expected_out = 1;
             counter = counter + 1;
           end
         end
         else begin
           expected_out = 0;
         end
       end
         
       //Wait for DUT to update
       @(posedge clk);

       //Comparison Logic
       if (out === expected_out) begin
         if(!rst) begin
           $display("PASS (Reset): Time=%0t | out=%b | expected=%b | rst=%b", 
                    $time, out, expected_out, rst);
         end else begin
           $display("PASS: Time=%0t | out=%b | expected=%b | rst=%b | trigger=%b | count=%d", 
                    $time, out, expected_out, rst, trigger, counter);
         end
         pass_count = pass_count + 1;
       end 
       else begin
         if(!rst) begin
           $display("FAIL (Reset): Time=%0t | out=%b | expected=%b | rst=%b", 
                    $time, out, expected_out, rst);
         end else begin
           $display("FAIL: Time=%0t | out=%b | expected=%b | rst=%b | trigger=%b | count=%d", 
                    $time, out, expected_out, rst, trigger, counter);
         end
         fail_count = fail_count + 1;
       end
     end   
   end
     
endmodule