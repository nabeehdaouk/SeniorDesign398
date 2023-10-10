module g2b #(BITSIZE = 6)(
    input        [BITSIZE-1:0] gray,      
    output logic [BITSIZE-1:0] binary     
);

    always_comb begin
        binary[BITSIZE-1] = gray[BITSIZE-1];
        for(int i = BITSIZE-2; i >= 0; i--) begin
            binary[i] = gray[i] ^ binary[i+1];
        end        
    end
  
endmodule
