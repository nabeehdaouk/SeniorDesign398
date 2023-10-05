module binary_to_gray(
    input [31:0] bin, //binary input
    output [31:0] gray //grey output
);

	assign gray[31] = bin[31]; // MSB of gray is same as MSB of binary

generate // Generate logic for subsequent 30 bits
    genvar i;
    for (i = 0; i < 31; i = i + 1) begin : gray_gen
        assign gray[30-i] = bin[31-i] ^ bin[30-i];
    end
endgenerate
	
endmodule 
