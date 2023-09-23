module tb;
    reg clk,resetn,w_en,r_en1,r_en2,w_adrs,r_adrs1,r_adrs2,data_in;
    wire data_out1,data_out2;
    
    memory memory_instance(
        .clk(clk),
        .resetn(resetn),
        .w_adrs(w_adrs),
        .r_adrs1(r_adrs1),
        .r_adrs2(r_adrs2),
        .data_in(data_in),
        .w_en(w_en),
        .r_en1(r_en1),
        .r_en2(r_en2),
        .data_out1(data_out1),
        .data_out2(data_out2)
    );
    
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        
    	resetn = 1'b1;
    	w_en = 1'b1;
    	r_en1 = 1'b0; 
    	r_adrs1 = 0;
    	w_adrs = 11'b00001000101;
    	data_in = 11'b00110100100;
    
    end

endmodule