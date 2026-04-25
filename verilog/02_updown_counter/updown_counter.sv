module updown_counter (
  input clk,
  input rst,
  input load,
  input up_down,
  input [7:0] in,
  output reg [7:0] count
);
  
  always @(posedge clk) begin
    if (!rst) begin
      count <= 8'b0;
    end
    else if (load) begin
      count <= in;
    end
    else if (up_down) begin
      count <= count + 1;
    end
    else begin
      count <= count - 1;
    end
  end
  
endmodule