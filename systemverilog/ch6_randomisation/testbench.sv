//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------



//--------------------------------------------------------------------------
//Answers to the questions--------------------------------------------------
//--------------------------------------------------------------------------


module questions_answers;
  
    function display();
      $display("Q1-What is the basic difference between rand and randc?");
      $display("Ans1 - randc does not choose the random number twice until all possible values are chosen.");
      $display("\nQ2-What is the difference between random property (class property) and non-random property in the classes?");
      $display("Ans2 - random property is randomised using .randosmise() while the non-random property is fixed until manually changed.");
      $display("\nQ3-What is the constraint?");
      $display("Ans3 - A constraint is like a limit to how random a generation could be, it allows us to get legal outputs from randomisation.");
      $display("\nQ4-Can 2 constraints make a contradiction without yielding to random failure?");
      $display("Ans4 - No, because the solver would not be able to choose a value that satisfies both HARD constraints.But if one of them is declared as SOFT, the solver can drop it to avoid failure.");
      $display("Note: Soft constraints act like defaults or preferences.They guide randomization but can be ignored if they conflict with stronger constraints.");
      $display("We use soft constraints to set default values or ranges,while still allowing overrides in tests or inline constraints.They are helpful when we want flexibility without randomization failure.");
      $display("\nQ5-What is the difference between if statement inside constraint and if inside sequential code?");
      $display("Ans5 - If statement inside a constraint is used to conditionally control how random values are generated during randomisation \nwhile if statements in sequential code are procedural and controls the program flow during execution.\nWe also use begin end in sequential while curly brackets in constraints."); 
    endfunction 
    
    initial begin
      $display("=========Answers to questions 1 to 5=======");
      display();
      $display("================Done=======================");
    end
  
endmodule 






//--------------------------------------------------------------------------
//Soft constraints examples-------------------------------------------------
//--------------------------------------------------------------------------


//Example 1 - Soft default value



//Randomisation check macro
`define SV_RAND_CHECK(r) \
  do begin \
    if(!(r)) begin \
      $display("Randomisation failed!"); \
      $finish; \
    end \
  end while(0)




//Class pkt
class pkt;
  
  rand bit [7:0] addr;

  
  //soft constraint: prefer addr=8'hAA but allow override
  constraint default_addr {
    soft addr == 8'hAA;
  }
 
  
  //function to display values
  function void display();
    $display("addr=%0h", addr);
  endfunction : display
   
endclass : pkt



//tb for soft constraint demo
module tb_soft;
  pkt p = new();
  
  initial begin
    
    repeat(3) begin
      
    //default soft constraint
    `SV_RAND_CHECK(p.randomize());
      p.display(); //it prints aa for 3 times (default)
      
    end

    
    //override with stronger inline constraint
    `SV_RAND_CHECK(p.randomize() with { addr == 8'h55; });
    p.display(); //it prints 55 (it was overriden by inline constraint)
    
  end
endmodule






//Example 2 - Soft range



//Randomisation check macro
`define SV_RAND_CHECK(r) \
  do begin \
    if(!(r)) begin \
      $display("Randomisation failed!"); \
      $finish; \
    end \
  end while(0)




//Class trans
class trans;
  
  rand int data;
 
  
  //soft constraint: prefer data in 0–100
  constraint soft_range {
    soft data inside {[0:100]};
  }
   
  
  //function to display values
  function void display();
    $display("data=%0d", data);
  endfunction : display
  
  
endclass : trans




//tb for soft range demo
module tb_soft_range;
  trans t = new();
  
  initial begin
    
    //randomize with soft range
    repeat(3) begin
      `SV_RAND_CHECK(t.randomize());
      t.display(); //it printed 26 58 51 (between 0 and 100 as prefered)
    end

    
    //override with stronger inline constraint
    `SV_RAND_CHECK(t.randomize() with { data > 1000; });
    t.display(); //it printed 687859098 (>1000 as it was overriden with the inline constraint)
    
  end
endmodule







//--------------------------------------------------------------------------
//Question 6 Task A---------------------------------------------------------
//--------------------------------------------------------------------------


//Randomisation check macro
`define SV_RAND_CHECK(r) \
	do begin \
      if(!(r)) begin \
        $display("Randomisation failed!"); \
        $finish; \
      end \
    end while(0)



//Class c
class c;
  
  rand int a,b;
     
  //constraint ("a+`a=32'hffffffff because if a[0] is 0 a`[0] would be 1 so the sum is 1")
  /*constraint a_plus_b {
   	b == ~a;
  } */
  
  //same constraint but using xor
  constraint a_plus_b {
  b == (a ^ 32'hFFFFFFFF);
  }

  
   
  //function to display values
  function void display();
    $display("a=%0h | b=%0h | sum=%0h", a, b, (a+b));
  endfunction : display
   
  
endclass : c


//tb for task a
module task_a;
  c object = new();
  initial begin
    repeat(12) begin
      `SV_RAND_CHECK(object.randomize());
       object.display();
    end
  end
endmodule 






//--------------------------------------------------------------------------
//Question 6 Task B---------------------------------------------------------
//--------------------------------------------------------------------------


//Randomisation check macro
`define SV_RAND_CHECK(r) \
	do begin \
      if(!(r)) begin \
        $display("Randomisation failed!"); \
        $finish; \
      end \
    end while(0)




//Class c
class c;
  
  rand bit controller;
  rand int rand_int;
  
  
  //constraint ("if controller=0 then rand_int should be between 0 and 10 otherwise it should be between 30 and 40")
  constraint int_range {
    (controller == 0) -> rand_int inside {[0:10]};
    (controller == 1) -> rand_int inside {[30:40]};
    solve controller before rand_int; //choose controller first then determine the range for rand_int so that it doesn't choose both simultaneously
  }
  
  
  //constraint for making the prob of 1 and 0 equal for the controller signal
  constraint controller_distribution{
    controller dist {1'b0 := 50, 1'b1 := 50};
  }
   
  
  //function to display values
  function void display();
    $display("controller=%0d | rand_int=%0d", controller, rand_int);
  endfunction : display
   
  
endclass : c


//tb for task b
module task_b;
  c object = new();
  initial begin
    repeat(12) begin
   	  `SV_RAND_CHECK(object.randomize());
       object.display();
    end
  end
endmodule 






//--------------------------------------------------------------------------
//Question 6 Task C---------------------------------------------------------
//--------------------------------------------------------------------------


//Randomisation check macro
`define SV_RAND_CHECK(r) \
	do begin \
      if(!(r)) begin \
        $display("Randomisation failed!"); \
        $finish; \
      end \
    end while(0)




//Class c
class c;
  
  rand bit[1:0] controller;
  rand int rand_int;
  
  
  //constraint ("if controller=0 then rand_int should be between 0 and 20, if controller=1 -> 21:30, if controller=2 ->31:40, otherwise it should be random")
  constraint int_range {
    (controller == 0) -> rand_int inside {[0:20]};
    (controller == 1) -> rand_int inside {[21:30]};
    (controller == 2) -> rand_int inside {[31:40]};
    solve controller before rand_int;
  }
  
  
  //constraint for making the prob equal for the controller signal
  constraint controller_distribution{
    controller dist {2'b00 := 25, 2'b01 := 25, 2'b10 := 25, 2'b11 := 25};
  }
   
  
  //function to display values
  function void display();
    $display("controller=%0d | rand_int=%0d", controller, rand_int);
  endfunction : display
   
  
endclass : c


//tb for task c
module task_c;
  c object = new();
  initial begin
    repeat(32) begin
      `SV_RAND_CHECK(object.randomize());
       object.display();
    end
  end
endmodule 






//--------------------------------------------------------------------------
//Question 6 Task D---------------------------------------------------------
//--------------------------------------------------------------------------


//Randomisation check macro
`define SV_RAND_CHECK(r) \
	do begin \
      if(!(r)) begin \
        $display("Randomisation failed!"); \
        $finish; \
      end \
    end while(0)




//Class c
class c;
  
  bit a;
  rand int b;
  
  
  //each time the randomization function is called, "a" will take the its opposite value 
  function void pre_randomize();
    a = ~a;
  endfunction : pre_randomize
  
  
  //constraint ("if a=0 the b should be 0 otherwise b is random")
  constraint b_value {
    (a == 0) -> (b == 0);
  }
  
  
  //function to display values
  function void display();
    $display("a=%0d | b=%0d", a, b);
  endfunction : display
   
  
endclass : c


//tb for task d
module task_d;
  c object = new();
  initial begin
    repeat(12) begin
      `SV_RAND_CHECK(object.randomize());
       object.display();
    end
  end
endmodule 






//--------------------------------------------------------------------------
//Question 6 Task E---------------------------------------------------------
//--------------------------------------------------------------------------


//Randomisation check macro
`define SV_RAND_CHECK(r) \
	do begin \
      if(!(r)) begin \
        $display("Randomisation failed!"); \
        $finish; \
      end \
    end while(0)




//Class c
class c;
  
  rand byte mask;
  rand logic[63:0] signal;
  
  
  //constraint ("For each bit in the mask signal that has the value of 1, the signal should have the relative byte equals x values")
  //we randomise the mask then whenever there's 1 we replace it with a byte of x before the next round, also constraits doesn't allow writing x in the signal(4 state)
  function void post_randomize();
    foreach(mask[i]) begin
      if(mask[i] == 1) begin
        signal[i*8 +: 8] = 8'bx;
      end
    end
  endfunction : post_randomize
  
  
  //function to display values
  function void display();
    $display("mask=%0b | signal=%0h", mask, signal);
  endfunction : display
   
  
endclass : c


//tb for task e
module task_e;
  c object = new();
  initial begin
    repeat(12) begin
      `SV_RAND_CHECK(object.randomize());
       object.display();
    end
  end
endmodule 





//--------------------------------------------------------------------------
//Question 6 Task F---------------------------------------------------------
//--------------------------------------------------------------------------


//Randomisation check macro
`define SV_RAND_CHECK(r) \
	do begin \
      if(!(r)) begin \
        $display("Randomisation failed!"); \
        $finish; \
      end \
    end while(0)




//Class c
class c;
  
  rand bit grid[][];

  //constructor to allocate chosen rows and cols
  function new(int rows, int cols);
    grid = new[rows];
    foreach(grid[i]) begin
      grid[i] = new[cols];
    end
  endfunction
  
  
  //constraint that 1's should have NO neigboring 1's
  constraint no_neighbors {
    foreach (grid[i, j]) {  
      if (grid[i][j] == 1) {
        if (i > 0)           grid[i-1][j] == 0; // up
        if (i < grid.size()-1) grid[i+1][j] == 0; // down
        if (j > 0)           grid[i][j-1] == 0; // left
        if (j < grid[i].size()-1) grid[i][j+1] == 0; // right
      }
    }
  }

  
        
  //function to display values
  function void display();
    foreach(grid[i]) begin
      foreach(grid[i][j]) begin
        $write("%0b ", grid[i][j]);
      end
      $display("\n");
    end
      $display("\n-------------\n");
  endfunction : display
   
  
endclass : c


//tb for task f
module task_f;
  c object = new(5,5);
  initial begin
    repeat(12) begin
      `SV_RAND_CHECK(object.randomize());
       object.display();
    end
  end
endmodule 

