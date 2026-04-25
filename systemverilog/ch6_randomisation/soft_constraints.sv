//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------




//Soft constraints examples-------------------------------------------------
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





