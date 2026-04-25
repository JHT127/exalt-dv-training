interface counter_if #(int COUNT_WIDTH = 8) (input logic pclk);

    logic [COUNT_WIDTH-1:0] count;

endinterface
