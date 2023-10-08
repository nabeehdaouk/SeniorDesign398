module ff_sync #(parameter DATA_WIDTH =32)(                        //Double flip flop synchronizer
	input clk,                         //Global clock signal
	input resetn,                      //Global reset signal
	input [DATA_WIDTH:0] data_in,              //Data in
	output reg [DATA_WIDTH:0] data_out         //Data out
);
	reg [DATA_WIDTH:0] q1;                     //Output of first flipflop holding data_in
	
	always @(posedge clk) begin
	    if (!resetn) begin             //If reset set both flip flop outputs to 0
	       q1 <= 0;
	       data_out <= 0;
	    end 
	    else begin                     //Set data_out to what was in between flip flops
	       data_out <= q1;
	       q1 <= data_in;              //Set register to data_in
	    end
	    
	end
	
endmodule
