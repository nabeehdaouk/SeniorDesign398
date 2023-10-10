module b2g #(BITSIZE = 6)(
        input [BITSIZE-1:0] binary,
        output logic [BITSIZE-1:0] gray
    );
    
    always_comb begin
        gray = {binary[BITSIZE-1], binary[BITSIZE-1:1]^binary[BITSIZE-2:0]};
    end
    
endmodule
