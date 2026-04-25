//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------



//Question 6 Task C---------------------------------------------------------



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