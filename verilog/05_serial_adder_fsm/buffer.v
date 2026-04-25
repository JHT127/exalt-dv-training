//Sync Buffer Design Module

module buffer(
	input clk,
 	input rst,
  	input in,
  	output reg out
);
  
  always @(posedge clk) begin
    if(rst) begin
      out <= 0;
    end
    else begin
      out <= in;
    end
  end
  
endmodule
