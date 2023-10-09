module async_fifo_top_level #(parameter DATA_WIDTH = 31, MEM_DEPTH=8, PTR_SIZE=8)(
	input w_clk,
	input r_clk,
	input resetn,
	input r_en,
	input w_en,
	input [DATA_WIDTH-1:0] w_data,
	input [MEM_DEPTH-1:0] r_adrs,
	input [MEM_DEPTH-1:0] w_adrs,
	output reg [DATA_WIDTH:0] r_data,
	output reg full,
	output reg empty
	
);
	wire [PTR_SIZE - 1: 0] rptr;
	wire [PTR_SIZE - 1: 0] gray_rptr;
	wire [PTR_SIZE - 1: 0] gray_rptr_sync;
	wire [PTR_SIZE - 1: 0] rptr_sync;
	wire [PTR_SIZE - 1: 0] wptr;
	wire [PTR_SIZE - 1: 0] gray_wptr;
	wire [PTR_SIZE - 1: 0] gray_wptr_sync;
	wire [PTR_SIZE - 1: 0] wptr_sync;
	wire [PTR_SIZE - 1: 0] check_next;
	
	wire write;
	wire read;
	
	
	binary_to_gray #(.WIDTH(PTR_SIZE)) binary_to_gray_rptr(
        .bin(rptr),
        .gray(gray_rptr)
    );
    
	binary_to_gray #(.WIDTH(PTR_SIZE)) binary_to_gray_wptr(
	    .bin(wptr),
	    .gray(gray_wptr)
	);
	
	gray_to_binary #(.WIDTH(PTR_SIZE)) gray_to_binary_rptr(
	    .gray(gray_rptr_sync),
	    .bin(rptr_sync)
	);
	
	gray_to_binary #(.WIDTH(PTR_SIZE)) gray_to_binary_wptr(
        .gray(gray_wptr_sync),
        .bin(wptr_sync)
    );
    
    ff_sync #(.DATA_WIDTH(PTR_SIZE)) ff_sync_read_to_write(
        .clk(r_clk),
        .resetn(resetn),
        .data_in(gray_rptr),
        .data_out(gray_rptr_sync)
    );
    
    ff_sync #(.DATA_WIDTH(PTR_SIZE)) ff_sync_write_to_read(
        .clk(w_clk),
        .resetn(resetn),
        .data_in(gray_wptr),
        .data_out(gray_wptr_sync)
    );
    
	ram #(.MEM_WIDTH(DATA_WIDTH),.MEM_DEPTH(MEM_DEPTH)) ram_instance(
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
