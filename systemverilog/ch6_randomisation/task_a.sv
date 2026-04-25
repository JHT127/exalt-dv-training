//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------



//Question 6 Task A---------------------------------------------------------



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

