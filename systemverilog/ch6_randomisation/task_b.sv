//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------



//Question 6 Task B---------------------------------------------------------



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