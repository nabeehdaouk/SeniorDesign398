module gray_to_binary(
    input [31:0] gray,  //grey inout
	output [31:0] bin  //binary output
	
);

 assign bin[31] = gray[31];
 
generate
    genvar i;
    for (i = 30; i >= 0; i = i - 1) begin
        assign bin[i] = bin[i+1] ^ gray[i];
    end
endgenerate


endmodule
