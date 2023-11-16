module memory(
    input clk,                      //Clock
    input picture_clk,              //Clock for the picture
    input resetn,                   //Active low reset
    input [10:0] w_adrs,            //Write address
    input [10:0] w_adrs2,           //Write address 2
    input [10:0] r_adrs1,           //Read address 1
    input [10:0] r_adrs2,           //Read address 2
    input [10:0] r_adrs3,           //Read address 3
    input [10:0] picture_radrs,     //Read address for the picture index
    input [31:0] data_in,           //Data in
    input [31:0] data_in2,          //Data in 2
    input w_en,                     //Write enable
    input w_en2,                    //Write enable 2
    input r_en1,                    //Read enable 1
    input r_en2,                    //Read enable 2
    input r_en3,                    //Read enable 3
    output reg r_valid1,            //Read valid 1
    output reg r_valid2,            //Read valid 2
    output reg r_valid3,            //Read valid 3
    output reg w_valid1,            //Write valid 1
    output reg w_valid2,            //Write valid2
    output reg [31:0] data_out1,    //Data out 1
    output reg [31:0] data_out2,    //Data out 2
    output reg [31:0] data_out3,    //Data out 3
    output reg [23:0] picture_data  //Picture data output
);

    reg [31:0] mem [2047:0];
    integer i;
    
    
    always @(posedge clk) begin: Read_Write_Memory

        if (!resetn) begin
            data_out1 <= 0;
            data_out2 <= 0;
            for(i = 0; i < 1792; i = i + 1) begin
                mem[i] <= 0; 
            end
            //INSERT PICTURE DATA HERE, LEFT TO RIGHT TOP TO BOTTOM
        end else begin
            if(w_en) begin
                 mem[w_adrs] <= data_in;
                 w_valid1 <= 1;
            end else begin
                 w_valid1 <= 0;
            end
            if(w_en2) begin
                mem[w_adrs2] <= data_in2;
            end else begin
               w_valid2 <= 0;     
            end
            if(r_en1) begin
                data_out1 <= mem[r_adrs1];
                r_valid1 <= 1;
            end else begin
                r_valid1 <= 0;
            end
            if(r_en2) begin
                data_out2 <=  mem[r_adrs2];
                r_valid2 <= 1;
            end else begin
                r_valid2 <= 0;
            end
            if(r_en3) begin
                data_out3 <= mem[r_adrs3];
                r_valid3 <= 1;
            end else begin
                r_valid3 <= 0;
            end
        end    
    end
    
    always @(posedge picture_clk) begin
        picture_data <= mem[picture_radrs][23:0];
    end
    
endmodule