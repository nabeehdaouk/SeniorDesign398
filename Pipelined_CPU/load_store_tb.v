module load_store_tb();
    
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
        w_adrs = 1;
        
        //Add instrction
        #10
        cpu_en = 0;
        resetn = 1;
        w_enable = 1;
        w_instruction = 32'b111_00_000_0_0_0_00000_00011_0_00000_00111; //LOAD MEM7 REG_A_3
        
        //Add instruction
        #10
        w_adrs = 4;
        w_instruction = 32'b110_00_000_0_1_1_11111_11111_0_00000_00011; //STORE REG_A_3 MEM2047
        
        //Branch instruction
        #10
        w_adrs = 5;
        w_instruction = 32'b101_00_100_0_0_0_00000_00000_0_00000_00000; //BRANCH EQZ MEM0

        //Add instruction
        #10
        w_adrs = 7;
        w_instruction = 32'h1234_5678;
        
        //Start
        #10
        cpu_en = 1;
        w_enable = 0;

        #175
        $stop();    
    
    end
    
endmodule