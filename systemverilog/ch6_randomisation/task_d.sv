//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------



//Question 6 Task D---------------------------------------------------------



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