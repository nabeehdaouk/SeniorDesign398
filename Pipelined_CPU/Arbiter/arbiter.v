module arbiter(
    input clk,
	input [31:0] instruction,
	output reg [31:0] FIFO_1, FIFO_2
);
	reg fifo_select;
	
	always @(posedge clk)
	begin
	    fifo_select <= ~fifo_select;
	    FIFO_1<= (fifo_select==1'b0)? instruction: FIFO_1;
	    FIFO_2<= (fifo_select==1'b1)? instruction: FIFO_2;
	end
endmodule
