module async_fifo_top_level #(DATA_WIDTH = 31, MEM_DEPTH=8)(
	input w_clk,
	input r_clk,
	input resetn,
	input [DATA_WIDTH-1:0] w_data,
	input [MEM_DEPTH-1:0] r_adrs,
	input [MEM_DEPTH-1:0] w_adrs,
	output [DATA_WIDTH:0] r_data
	
);
	
endmodule
