//Serial Adder Top Module Design

`include "PISO.v"
`include "fsm_full_adder.v"
`include "SIPO.v"
`include "buffer.v"

module serial_adder(
  	input clk,
  	input rst,
	input [7:0] A,
	input [7:0] B,
	input shift_load,
  	output [8:0] summation
);
 
  
  //Additional parameters
  
  wire shift_load_buffer1; //first clock cycle buffer for the shift_load needed for sipo
  wire shift_load_buffer2; //second clock cycle buffer for the shift_load needed for sipo
  wire full_adder_result; //output of full adder
  wire a; //output of piso A input
  wire b; //output of piso B input
  
  
  //First shift_load buffer instantiation
  buffer buff_1(
    .clk(clk),
    .rst(rst),
    .in(shift_load),
    .out(shift_load_buffer1)
  );
  
  //Second shift_load buffer instantiation
  buffer buff_2(
    .clk(clk),
    .rst(rst),
    .in(shift_load_buffer1),
    .out(shift_load_buffer2)
  );
  
  //A input PISO instantiation
  PISO piso_A(
    .clk(clk),
    .rst(rst), 
    .p_in(A),
    .shift_load(shift_load),
    .s_out(a)
  );
  
  //B input PISO instantiation
  PISO piso_B(
    .clk(clk),
    .rst(rst), 
    .p_in(B),
    .shift_load(shift_load),
    .s_out(b)
  );
  
  //Full adder instantiation
  fsm_full_adder adder(
    .clk(clk),
    .rst(rst),
    .in_1(a),
    .in_2(b),
    .sum(full_adder_result)
  );
  
  //SIPO instantiation
  SIPO sipo(
    .clk(clk),
    .rst(rst),
    .s_in(full_adder_result),
    .start(shift_load_buffer2),
    .p_out(summation)
  );
  
endmodule