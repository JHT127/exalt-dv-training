//Full Adder Design Module with FSM

module fsm_full_adder (
  input clk,
  input rst,
  input in_1,
  input in_2,
  output reg sum
);
  
  //Additional Parameters
  reg carry;
  reg [1:0] state;
  
  //State Definitions
  localparam IDLE = 2'b00;
  localparam COMPUTE = 2'b01;
  
  //Design Functionality Implementation
  always @(posedge clk) begin
    
    if (rst) begin
      state <= IDLE;
      carry <= 0;
      sum <= 0;
    end
    
    else begin
      case (state)
        IDLE: begin
          state <= COMPUTE;
          sum <= 0;
          carry <= 0;
        end
        
        COMPUTE: begin
          state <= COMPUTE;
          {carry, sum} <= in_1 + in_2 + carry;
        end
        
        default: begin
          state <= IDLE;
          sum <= 0;
          carry <= 0;
        end
      endcase
    end
    
  end
  
endmodule