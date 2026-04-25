//Non-Retriggerable Monoshot Design Module

module non_retriggerable_monoshot(
	input clk,
  	input rst,
  	input trigger,
  	output reg out
);
  
  //Additional Parameters
  reg active;
  reg [7:0]counter;
  localparam cycle_count = 128; 
  
  //Design Functionality Implementation
  always @(posedge clk) begin 
    if(!rst) begin //reset
      out <= 0;
      counter <= 0;
      active <= 0;
    end
    else begin //trigger
      if (trigger && !active) begin //trigger NOT during the 128 cycles
      	active <= 1;
        counter <= 0;
        out <= 1;
      end
      else if (active) begin //DURING the 128 cycles
        if (counter == cycle_count - 1) begin //done
          active <= 0;
          counter <= 0;
          out <= 0;
        end
        else begin //continue until 128
          counter <= counter + 1;
        end
      end
    end  
  end
  
endmodule
  