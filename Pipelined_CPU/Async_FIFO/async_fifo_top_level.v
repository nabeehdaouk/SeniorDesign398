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
	reg [PTR_SIZE - 1: 0] rptr;
	reg [PTR_SIZE - 1: 0] gray_rptr;
	reg [PTR_SIZE - 1: 0] gray_rptr_sync;
	reg [PTR_SIZE - 1: 0] rptr_sync;
	reg [PTR_SIZE - 1: 0] wptr;
	reg [PTR_SIZE - 1: 0] gray_wptr;
	reg [PTR_SIZE - 1: 0] gray_wptr_sync;
	reg [PTR_SIZE - 1: 0] wptr_sync;
	reg [PTR_SIZE - 1: 0] check_next;
	
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
    
	ram #(.MEM_WIDTH(DATA_WIDTH),.MEM_DEPTH(MEM_DEPTH),.ADDRESS_SIZE(PTR_SIZE - 1)) ram_instance(
	    .w_clk(w_clk),
	    .r_clk(r_clk),
	    .resetn(resetn),
	    .w_en(w_en),
	    .r_en(r_en),
	    .full(full),
	    .empty(empty),
	    .w_adrs(wptr[PTR_SIZE - 2:0]),
	    .r_adrs(rptr[PTR_SIZE - 2:0]),
	    .w_data(w_data),
	    .r_data(r_data)
	);
	
	always @(posedge w_clk) begin
	   if(!resetn) begin
	       wptr <= 0;
	       full <= 0;
	   end
	   else if(resetn && ~full && w_en) begin
	           if(wptr[PTR_SIZE - 2 :0] == MEM_DEPTH - 1) begin
	               wptr[PTR_SIZE - 2:0] <= 0;
	               wptr[PTR_SIZE - 1] <= ~wptr[PTR_SIZE - 1];
	           end
	           else begin
	                   wptr <= wptr + 1;
	                   if(wptr[PTR_SIZE - 1] != rptr_sync[PTR_SIZE - 1] && wptr[PTR_SIZE - 2:0] == rptr_sync[PTR_SIZE - 2:0]) begin
	                       full <= 1;
	                   end
	                   else if(wptr - 31 == rptr_sync) begin
	                           full <= 1;
	                       end
	                       else begin
	                               full <= 0;
	                           end
	               end
	       end 
	       else begin
	               full <= 0;
	           end
	           
	end
	
	always @(posedge r_clk) begin
	    if(!resetn) begin
           rptr <= 0;
           empty <= 0;
       end
       else if(resetn && ~empty && r_en) begin
               if(rptr[PTR_SIZE - 2 :0] == MEM_DEPTH - 1) begin
                   rptr[PTR_SIZE - 2:0] <= 0;
                   rptr[PTR_SIZE - 1] <= ~rptr[PTR_SIZE - 1];
               end
               else begin
                       rptr <= rptr + 1;
                       if(rptr == wptr_sync) begin
                           empty <= 1;
                       end 
                       else begin
                                empty <= 0;
                            end
                   end
           end
           else begin
                if (rptr == wptr_sync)begin
                   empty <= 1;
               end
               else if (wptr_sync - rptr == 1) begin
                    empty <= 1; 
                end
                else begin
                        empty <= 0;
                    end
                
        end            
       
       
	end
	
	
endmodule
