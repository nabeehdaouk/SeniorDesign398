module memory(
    input clk,                  //Clock
    input resetn,               //Active low reset
    input [10:0] w_adrs,        //Write address
    input [10:0] r_adrs1,       //Read address 1
    input [10:0] r_adrs2,       //Read address 2
    input [31:0] data_in,       //Data in
    input w_en,                 //Write enable
    input r_en1,                //Read enable 1
    input r_en2,                //Read enable 2
    output reg [31:0] data_out1,  //Data out 1
    output reg [31:0] data_out2   //Data out 2
);

    reg [31:0] mem [2047:0];
    integer i;
    
    always @(posedge clk) begin: Read_Write_Memory

        if (!resetn) begin
            data_out1 <= 0;
            data_out2 <= 0;
            for(i = 0; i < 2048; i = i + 1) begin
               mem[i] <= 0; 
            end
        end else begin
            if(w_en) begin
                mem[w_adrs] <= data_in;
            end
            if(r_en1) begin
               data_out1 <= mem[r_adrs1];
            end
            if(r_en2) begin
               data_out2 <=  mem[r_adrs2];
            end
        end    
    end
    
endmodule