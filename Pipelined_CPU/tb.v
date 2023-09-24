module tb;
    reg clk,resetn,w_en,r_en1,r_en2;
    reg [10:0]w_adrs,r_adrs1,r_adrs2;
    reg [31:0]data_in;
    wire [31:0]data_out1,data_out2;
    
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
        
        #10
    	resetn = 1'b1;
    	w_en = 1'b1;
    	r_en1 = 1'b0; 
    	r_en2 = 1'b0;
    	r_adrs1 = 0;
    	r_adrs2 = 0;
    	w_adrs = 11'b00001000101;
    	data_in = 11'b00110100100;
    	#10
    	$display("r_adrs1 = %b, r_adrs2 = %b, w _adrs = %b, data_in = %b, data_out1 = %b, data_out2 = %b",r_adrs1,r_adrs2,w_adrs,data_in,data_out1,data_out2);
    
        #10
        resetn = 1'b1;
        w_en = 1'b1;
        r_en1 = 1'b1; 
        r_en2 = 1'b0;
        r_adrs1 = 11'b00001000101;
        r_adrs2 = 0;
        w_adrs = 11'b00000000001;
        data_in = 11'b0000001111;
        #10
        $display("r_adrs1 = %b, r_adrs2 = %b, w _adrs = %b, data_in = %b, data_out1 = %b, data_out2 = %b",r_adrs1,r_adrs2,w_adrs,data_in,data_out1,data_out2);
    
        #10
        resetn = 1'b1;
        w_en = 1'b0;
        r_en1 = 1'b1; 
        r_en2 = 1'b1;
        r_adrs1 = 11'b00001000101;
        r_adrs2 = 11'b00000000001;
        w_adrs = 0;
        data_in = 11'b00110100100;
        #10
        $display("r_adrs1 = %b, r_adrs2 = %b, w _adrs = %b, data_in = %b, data_out1 = %b, data_out2 = %b",r_adrs1,r_adrs2,w_adrs,data_in,data_out1,data_out2);
        
        #10
        resetn = 1'b1;
        w_en = 1'b0;
        r_en1 = 1'b1; 
        r_en2 = 1'b1;
        r_adrs1 = 11'b11111111111;
        r_adrs2 = 11'b11111111110;
        w_adrs = 0;
        data_in = 11'b00000000000;
        #10
        $display("r_adrs1 = %b, r_adrs2 = %b, w _adrs = %b, data_in = %b, data_out1 = %b, data_out2 = %b",r_adrs1,r_adrs2,w_adrs,data_in,data_out1,data_out2);
        
        #10
        resetn = 1'b0;
        w_en = 1'b0;
        r_en1 = 1'b1; 
        r_en2 = 1'b1;
        r_adrs1 = 11'b00001000101;
        r_adrs2 = 11'b00000000001;
        w_adrs = 0;
        data_in = 11'b11111111111;
        #10
        $display("r_adrs1 = %b, r_adrs2 = %b, w _adrs = %b, data_in = %b, data_out1 = %b, data_out2 = %b",r_adrs1,r_adrs2,w_adrs,data_in,data_out1,data_out2);
        
    end

endmodule