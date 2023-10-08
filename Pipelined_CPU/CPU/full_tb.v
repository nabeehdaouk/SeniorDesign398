module full_tb();
    
    reg clk;
    reg resetn;        //Global reset
    reg cpu_en;
    reg [31:0] w_instruction;
    reg w_enable;
    reg [10:0] w_adrs;
    wire carry;
    wire [31:0]result;
    
    top_level top_level_instance(
        .clk(clk),
        .resetn(resetn),
        .cpu_en(cpu_en),
        .w_instruction(w_instruction),
        .w_enable(w_enable),
        .w_adrs(w_adrs),
        .carry(carry),
        .result(result)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        
        //Reset
        clk = 0;
        resetn = 0;
        cpu_en = 1;
        w_instruction = 32'h0000_0000;
        w_enable = 0;
        
        //Add LOAD instrction
        #10
        w_adrs = 1;
        cpu_en = 0;
        resetn = 1;
        w_enable = 1;
        w_instruction = 32'b111_00_000_0_0_0_00000_00011_0_00000_11110; //LOAD MEM30 REG_A_3
        
        //Add LOAD instruction
        #10
        w_adrs = 2;
        w_instruction = 32'b111_00_000_0_0_1_00011_00000_0_00000_11111; //LOAD MEM31 REG_B_3
        
        //Add Branch instruction (should not take)
        #10
        w_adrs = 3;
        w_instruction = 32'b101_00_001_0_0_0_00000_00000_0_00000_00000; //BRANCH EQZ MEM0
        
        //Add STORE instruction
        #10
        w_adrs = 4;
        w_instruction = 32'b110_00_000_0_1_1_11111_11110_0_00000_00011; //STORE REG_A_3 MEM2046
        
        //Add ADD instruction
        #10
        w_adrs = 5;
        w_instruction = 32'b100_00_000_1_0_1_00011_00000_0_00000_00001;  //ADD 1 REG_B_3
        
        //Add ADD instruction
        #10
        w_adrs = 6;
        w_instruction = 32'b100_00_000_1_0_0_00000_00011_0_00000_00101;  //ADD 5 REG_A_3
        
        //Add SUB instruction
        #10
        w_adrs = 7;
        w_instruction = 32'b011_00_000_0_0_0_00000_00011_0_00000_00011;  //SUB REG_B_3 REG_A_3
        
        //Add OR instruction
        #10
        w_adrs = 8;
        w_instruction = 32'b001_00_000_1_0_0_00000_00111_0_01010_10101; //OR REGA_7 341
        
        //Add AND instruction
        #10
        w_adrs = 9;
        w_instruction = 32'b010_00_000_0_0_0_00000_00011_0_00000_00101; //AND REGA_3 REGA_7
        
        //Add BRANCH instruction
        #10
        w_adrs = 10;
        w_instruction = 32'b101_00_000_0_0_1_11111_11111_1_11111_11111; //BRANCH EQZ MEM2046
        
        //Add information
        #10
        w_adrs = 30;
        w_instruction = 32'h0000_000F;
        
        //Add information
        #10
        w_adrs = 31;
        w_instruction = 32'hF000_0000;
        
        //Start
        #10
        cpu_en = 1;
        w_enable = 0;

        #475
        $stop();    
    
    end
    
endmodule