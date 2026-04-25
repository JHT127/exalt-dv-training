//Parallel-In Serial-Out (PISO) Shift Register Module

module PISO(
  input clk,
  input rst,
  input [7:0] p_in,
  input shift_load,
  output reg s_out
);
  
  //Additional Parameters
  reg [7:0] data;
  reg [2:0] counter;
  reg active;
  
  //Design Functionality Implementation
  always @(posedge clk) begin
    
    if(rst) begin //reset 
      data <= 0;
      counter <= 0;
      active <= 0;
      s_out <= 0;
    end
    
    else begin //normal operation
      s_out <= 0;
      
      if (!shift_load && !active) begin //load when shift_load is LOW
        data <= p_in;
        counter <= 0;
      end
      
      if (shift_load && !active) begin //start shifting when shift_load goes HIGH
        active <= 1;
        data <= {1'b0, data[7:1]};
        counter <= counter + 1;
        s_out <= data[0];
      end
      
      if (active) begin //during the 8 cycles of shifting (non-retriggerable)
        s_out <= data[0];
        data <= {1'b0, data[7:1]};
        counter <= counter + 1;
        if (counter == 7) begin //done (outputted all 8 bits)
          active <= 0;
        end
      end
      
    end
  end
  
endmodule