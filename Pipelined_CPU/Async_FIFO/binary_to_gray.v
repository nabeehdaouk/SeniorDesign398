module binary_to_gray#(parameter WIDTH=32)(
    input [WIDTH-1:0] bin, //binary input
    output [WIDTH-1:0] gray //grey output
);

	assign gray[WIDTH-1] = bin[WIDTH-1]; // MSB of gray is same as MSB of binary

generate // Generate logic for subsequent 30 bits
    genvar i;
    for (i = 0; i < (WIDTH-1); i = i + 1) begin : gray_gen
        assign gray[WIDTH-2-i] = bin[WIDTH-1-i] ^ bin[WIDTH-2-i];
    end
endgenerate
	
endmodule 
