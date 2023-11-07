module memory(
    input clk,                      //Clock
    input resetn,                   //Active low reset
    input [10:0] w_adrs,            //Write address
    input [10:0] w_adrs2,           //Write address 2
    input [10:0] r_adrs1,           //Read address 1
    input [10:0] r_adrs2,           //Read address 2
    input [10:0] r_adrs3,           //Read address 3
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
    output reg [31:0] data_out3
);

    reg [31:0] mem [2047:0];
    //integer i;
    
    
    initial begin
        mem[0] = 'h0;
        mem[1] = 32'b111_00_000_0_0_0_00000_00011_0_00000_11110; //LOAD MEM30 REG_A_3
        mem[2] = 32'h0;                                          //NOP TODO : Figure out why we cant load back to back  
        mem[3] = 32'b111_00_000_0_0_1_00011_00000_0_00000_11111; //LOAD MEM31 REG_B_3
        mem[4] = 32'b101_00_001_0_0_0_00000_00000_0_00000_00000; //BRANCH EQZ MEM0
        mem[5] = 32'b110_00_000_0_1_1_11111_11110_0_00000_00011; //STORE REG_A_3 MEM2046
        mem[6] = 32'b100_00_000_1_0_1_00011_00000_0_00000_00001; //ADD 1 REG_B_3
        mem[7] = 32'b100_00_000_1_0_0_00000_00011_0_00000_00101; //ADD 5 REG_A_3
        mem[8] = 32'b011_00_000_0_0_0_00000_00011_0_00000_00011; //SUB REG_B_3 REG_A_3
        mem[9] = 32'b001_00_000_1_0_0_00000_00111_0_01010_10101; //OR REGA_7 341
        mem[10] = 32'b010_00_000_0_0_0_00000_00011_0_00000_00101;//AND REGA_3 REGA_7
        mem[30] = 32'h0000_000F;
        mem[31] = 32'h0000_0005;
    end
    
    always @(posedge clk) begin: Read_Write_Memory

        if (!resetn) begin
            data_out1 <= 0;
            data_out2 <= 0;
            //for(i = 0; i < 2048; i = i + 1) begin
              // mem[i] <= 0; 
            //end
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
    
endmodule