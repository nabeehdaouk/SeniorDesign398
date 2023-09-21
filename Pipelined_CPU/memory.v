module memory(
    input clk,                  //Clock
    input resetn,               //Active low reset
    input [10:0] w_adrs,        //Write address
    input [10:0] r_adrs,        //Read address
    input [31:0] data_in,       //Data in
    input w_en,                 //Write enable
    input r_en,                 //Read enable
    output reg [31:0] data_out  //Data out
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