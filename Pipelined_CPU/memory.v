module memory(input clk, 
    input resetn, //active low reset
    input [10:0] w_adrs, //write address
    input [10:0] r_adrs, //read address
    input [31:0] data_in,//data in
    input w_en, //write enable
    input r_en, //read enable
    output reg [31:0] data_out //data out
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