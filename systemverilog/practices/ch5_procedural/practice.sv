//================================================================================================================================
//Chapter 5 practice--------------------------------------------------------------------------------------------------------------
//================================================================================================================================



module practice_ch5;
  
  
//Procedural Statements-----------------------------------------------------------------------------------------------------------
 
  
	//difference between printing with %0d and without %0 (it is not a new feature i just wanted to test it)
  	int a =5;
  	int b=1234;
  
	initial begin : test_0d
        $display("\n=====Tetsing 0d and d=====");
        $display("with: a=%0d, b=%0d", a, b); //no padding
        $display("without: a=%d, b=%d", a, b); //with padding
        $display("==========================\n");
	end : test_0d
  


    
	//Sample 3.1 - New procedural statements and operators
    integer array [10],sum, j;    
  
	initial begin : example
		$display("=====Example1:Showing new statements and operators=====");

        // for loop with loop variable declared inside
        for (int i = 0; i < 10; i++) begin
            array[i] = i;
        end

        sum = array[9];
        j = 8;

        // do-while loop with compound assignment
        do begin
            sum += array[j]; // same as sum = sum + array[j]
        end while (j--);

        $display("Sum =%4d", sum); // %4d specifies width
      $display("==========================================================\n");
    end : example //end label

  
  
  
    //Sample 3.2 - Using break and continue while reading a file
    bit [127:0] cmd;
    int file,c;
  
    initial begin
        file = $fopen("commands.txt", "r");
        while(!$feof(file)) begin 
          c = $fscanf(file, "%s", cmd); 
            case(cmd) 
                "": continue; //continue the loop but ignore this iteration
                "done" : break; //leaves the loop
                //placeholder for other commands
            endcase
        end
        $fclose(file);
    end
  
              
              
              
    // Sample 3.3 Case-inside statement with ranges
    int graduation_year = 2004;
    initial begin
        $display("=====Example 3:Case-inside statement with ranges=====");
        case(graduation_year) inside //inside is used for ranges
          [1990:2000] : $display("Duaa range");
          [2000:2002] : $display("Tala range");
          [2003:2025] : $display("Joud range");
        endcase
        $display("=====================================================\n");
    end
  
  
  
  

  
//Tasks, Functions, and Void Functions----------------------------------------------------------------------------------------------
  
  
    //Difference between tasks and functions
    initial begin
        $display("=====Difference between a task and a function=====");
        $display("1. Functions: Functions cannot contain nonblocking assignments (<=).Only blocking assignments (=) are allowed. Reason:Functions are meant to be purely combinational (no timing control, no event scheduling).\nWhile Tasks: Tasks can contain both blocking and nonblocking assignments. Tasks are allowed to have timing controls (#, @, wait), so nonblocking assignments are valid inside them.");
        $display("2. Function must have a return value while tasks have no return value");
        $display("3. Tasks cannot be called inside functions");
        $display("=====Some notes considering tasks and functions=====");
        $display("1. SystemVerilog has allowed a function to call a task but only insde a fork join_none statement");
        $display("2. If the task does not consume time it is preferable to use a void function - a function that has no return value so a task can be called from inside a task or function");
        $display("3. if we want to call a function but ignore its return value we can cast it to void using 'void'(function)' ");
        $display("==================================================\n");     
    end
  
  
  
  
//3.3.1 Routine Begin…End Removed ---------------------------------------------------------------------------------------------------
  
  
    //Simple task without begin…end
    task display();
     	$display("First line");
     	$display("Second line");
    endtask : display
  
  
  
  
//3.4 Routine Arguments--------------------------------------------------------------------------------------------------------------
  
  
    //Sample 3.7 Verilog-1995 routine arguments
    task mytask1;
      output [31:0] x; //declare direction seperately
      reg [31:0] x; //declare type (storage etc)
      input y; //by default it is a reg for tasks
    endtask

  
  
  
    //Sample 3.8 C-style routine arguments
    task mytask1(output logic [31:0] x, input logic y ); //we can declare both direction and type together but only with a systemVerilog type like logic
        //implementation
    endtask
  
  
  
  
    //Sample 3.10 Routine arguments with sticky types  (lazy declarations)
    task mytask1(a, b, output bit [15:0] x); //by default a and b are inout logic 1-bit wide
        //code
    endtask
  
  
  
  
//
  
endmodule : practice_ch5
