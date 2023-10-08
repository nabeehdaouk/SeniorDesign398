module async_fifo_top_level #(parameter DATA_WIDTH = 31, MEM_DEPTH=8, PTR_SIZE=8)(
	input w_clk,
	input r_clk,
	input resetn,
	input [DATA_WIDTH-1:0] w_data,
	input [MEM_DEPTH-1:0] r_adrs,
	input [MEM_DEPTH-1:0] w_adrs,
	output reg [DATA_WIDTH:0] r_data,
	output reg full,
	output reg empty
	
);
	wire [PTR_SIZE - 1: 0] r_ptr;
	wire [PTR_SIZE - 1: 0] gray_rptr;
	wire [PTR_SIZE - 1: 0] gray_rptr_sync;
	wire [PTR_SIZE - 1: 0] rptr_sync;
	wire [PTR_SIZE - 1: 0] w_ptr;
	wire [PTR_SIZE - 1: 0] gray_wptr;
	wire [PTR_SIZE - 1: 0] gray_wptr_sync;
	wire [PTR_SIZE - 1: 0] wptr_sync;
	
	
	binary_to_gray binary_to_gray_instance(
        .bin(r_ptr),
        .gray(gray_rptr)
    );
    
	gray_to_binary gray_to_binary_instance(
	    .bin(w_ptr),
	    .gray(gray_wptr)
	);
	
	ram #(
	    .MEM_WIDTH(DATA_WIDTH),
	    .MEM_DEPTH(MEM_DEPTH)
	) ram_instance(
	    .w_clk(w_clk),
	    .r_clk(r_clk),
	    .resetn(resetn),
	    .w_en(w_en),
	    .r_en(r_en),
	    .full(full),
	    .empty(empty),
	    .w_adrs(w_adrs),
	    .r_adrs(r_adrs),
	    .w_data(w_data),
	    .r_data(r_data)
	);
	
endmodule
