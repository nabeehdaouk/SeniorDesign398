module gray_to_binary #(parameter WIDTH=32)(
    input [WIDTH-1:0] gray,  //grey inout
	output [WIDTH-1:0] bin  //binary output
	
);

 assign bin[WIDTH-1] = gray[WIDTH-1];
 
generate
    genvar i;
    for (i = (WIDTH-2); i >= 0; i = i - 1) begin
        assign bin[i] = bin[i+1] ^ gray[i];
    end
endgenerate


endmodule
