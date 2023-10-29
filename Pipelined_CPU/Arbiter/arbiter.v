module arbiter(
    input clk,
	input [31:0] instruction,
	input resetn,
	output reg [31:0] FIFO_1, FIFO_2
);
	reg fifo_select;
	
	always @(posedge clk)
	begin
	    if (!resetn)
	    begin
	    fifo_select <= 1'b0;
        FIFO_1<= 32'b0;
        FIFO_2<= 32'b0;
        end else begin
	    fifo_select <= ~fifo_select;
	    FIFO_1<= (fifo_select==1'b0)? instruction: FIFO_1;
	    FIFO_2<= (fifo_select==1'b1)? instruction: FIFO_2;
	    end
	end
endmodule
