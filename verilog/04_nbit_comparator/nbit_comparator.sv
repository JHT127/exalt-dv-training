`include "one_bit_comparator.v"

//n-bit comparator design module using the one bit comparator
module n_bit_comparator #(parameter n=4)(
  	input  [n-1:0]x,
  	input  [n-1:0]y,
    input gt,
    input lt,
    input eq,
    output x_gt_y,
    output x_lt_y,
    output x_eq_y
);
    // Intermediate wires for cascading
    wire [n:0] gt_cas;
    wire [n:0] lt_cas;
    wire [n:0] eq_cas;
    genvar i; //for the generator
    
    //Initial bits
    assign gt_cas[0] = gt;
    assign lt_cas[0] = lt;
    assign eq_cas[0] = eq;
  
    // Generating n-bit from one bit comp by cascading outputs between stages
    generate 
      for(i=0; i<n; i=i+1) begin: cas_outputs
        one_bit_comparator comp (
          .x(x[i]),
          .y(y[i]),
          .gt(gt_cas[i]),
          .lt(lt_cas[i]),
          .eq(eq_cas[i]),
          .x_gt_y(gt_cas[i+1]),
          .x_lt_y(lt_cas[i+1]),
          .x_eq_y(eq_cas[i+1])
        );
      end
    endgenerate 
    
    //Final Results
    assign x_gt_y = gt_cas[n];
    assign x_lt_y = lt_cas[n];
    assign x_eq_y = eq_cas[n];
  
    
endmodule