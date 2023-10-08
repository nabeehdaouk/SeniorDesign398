module async_fifo_top_level #(data_width = 31, mem_depth=8)(
	input w_clk,
	input r_clk,
	input resetn,
	input [data_width-1:0] w_data,
	input [mem_depth-1:0] r_adrs,
	input [mem_depth-1:0] w_adrs,
	output [data_width:0] r_data
	
);
	
endmodule
