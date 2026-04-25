// one bit comparator design module 
module one_bit_comparator(
	input  x,
    input  y,
    input  gt,
    input  eq,
    input  lt,
    output x_gt_y,
    output x_lt_y,
    output x_eq_y
);
    
  
    // x > y: 1. x is greater than y (xy`) OR 2. ((x equals y so we use XNOR) AND (gt=1))
    assign x_gt_y = (x & ~y) | ((~(x ^ y)) & gt);
    // x < y: 1. x is smaller than y (x`y) OR 2. ((x equals y so we use XNOR) AND (lt=1))
    assign x_lt_y = (~x & y) | ((~(x ^ y)) & lt);
    // x == y: ((x equals y so we use XNOR) AND (eq=1))
    assign x_eq_y = ((~(x ^ y)) & eq) ;
  
endmodule
