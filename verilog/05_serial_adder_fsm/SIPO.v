//Serial-In Parallel-Out (SIPO) Shift Register Module

module SIPO(
  input clk,
  input rst,
  input s_in,
  input start,
  output reg [8:0] p_out
);
  
  //Additional Parameters
  reg [8:0] data;
  reg [3:0] counter;
  reg active;
  
  //Design Functionality Implementation
  always @(posedge clk) begin
    
    if(rst) begin //reset
      data <= 0;
      counter <= 0;
      active <= 0;
      p_out <= 0;
    end
    
    else begin //normal operation
      
      if (start && !active) begin //start shifting when start goes HIGH
        active <= 1;
        counter <= counter + 1;
        data <= {s_in, data[8:1]};
      end
      
      if (active) begin //during the 9 cycles of shifting (non-retriggerable)
        if (counter == 8) begin //done (received all 9 bits)
          active <= 0;
          counter <= 0;
          p_out <= {s_in, data[8:1]};
        end
        else begin //continue shifting
          counter <= counter + 1;
          data <= {s_in, data[8:1]};
        end
      end
      
    end
  end
  
endmodule