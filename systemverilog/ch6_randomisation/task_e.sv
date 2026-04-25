//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------



//Question 6 Task E---------------------------------------------------------



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