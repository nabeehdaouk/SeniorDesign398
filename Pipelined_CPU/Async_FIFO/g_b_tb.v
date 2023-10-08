module g_b_tb();
    
    reg [31:0] in;
    wire [31:0] out;
    wire [31:0] intramediate;

    binary_to_gray #(32)binary_to_gray_instance(
        .bin(in),
        .gray(intramediate)
    );
    
	gray_to_binary #(32)gray_to_binary_instance(
	    .gray(intramediate),
	    .bin(out)
	);
	
	initial begin
	in= 32'haaaaaaaa;
	$display("-------------------------------------------------------------------------------------------------------------------------------------------------|");
            #100 $display("bin_in= %b,       grey=%b          bin_out=%b", in, intramediate, out);
	end 
endmodule
