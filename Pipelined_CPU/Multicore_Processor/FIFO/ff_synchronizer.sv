module ff_synchronizer #(BITSIZE = 6)(
        input clk,
        input rstn,
        input [BITSIZE-1:0] data_in,
        output logic [BITSIZE-1:0] data_out
    );
    
    logic [BITSIZE-1:0] mid_flops;
    
    always_ff @(posedge clk) begin
        if(!rstn) begin
            data_out <= '0;
            mid_flops <= '0;
        end else begin
            mid_flops <= data_in;
            data_out <= mid_flops;
        end
    end
    
endmodule
