module memory(input clk, 
    input resetn,
    input [10:0] w_adrs, r_adrs,
    input [31:0] data_in,
    input w_en, r_en,
    output reg [31:0] data_out
);

    reg [31:0] mem [2047:0];
    integer i;
    
    always @(posedge clk) begin: Read_Write_Memory

        if (!resetn) begin
            data_out <= 0;
            for(i = 0; i < 2048; i = i + 1) begin
               mem[i] <= 0; 
            end
        end else begin
            if(w_en) begin
                mem[w_adrs] <= data_in;
            end
            if(r_en) begin
               data_out <= mem[r_adrs];
            end
        end    
    end
    
endmodule