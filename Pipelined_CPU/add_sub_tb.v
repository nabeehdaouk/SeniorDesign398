module add_sub_tb();
    
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
        
        //Load the number 10 from memory into reg_a_3
        #10
        cpu_en = 0;
        resetn = 1;
        w_enable = 1;
        w_adrs = 2;
        w_instruction = 32'b111_00_000_0_0_0_00000_00011_0_00000_01010; //LOAD MEM10 REG_A_3
        
        //Load the number 11 from memory into reg_b_3 
        #10
        w_adrs = 3;
        w_instruction = 32'b111_00_000_0_0_1_00011_00000_0_00000_01011; //LOAD MEM11 REG_B_3
        
        //Add immediate to value in register a
        #10
        w_adrs = 4;
        w_instruction = 32'b100_00_000_1_0_0_00000_00011_0_00000_00001;  //Add 1 REG_A_3
      
        //Add immediate to value in register b
        #10
        w_adrs = 5;
        w_instruction = 32'b100_00_000_1_0_1_00011_00000_0_00000_00001;  //Add 1 REG_B_3
        
        //Add instruction
        #10
        w_adrs = 9;
        w_instruction = 32'b011_00_000_1_0_0_00000_00011_0_00000_00001;  //Sub 1 REG_A_3

        
        //Add immediate to register b
        //Add immediate to memory
        //Add register a to register a
        //Add register a to register b
        //Add register b to register a
        //Add register b to register b
        //Add register a to memory
        //Add register b to memory
        //Add memory to register a
        //Add memory to register b 
        //Add memory to memory
        
        //Sub register from immediate
        //Sub memory from immediate
        //Sub register from register
        //Sub memory from register
        //Sub register from memory
        //Sub memory from memory
        
        //Number 10 in memory 10
        #10
        w_adrs = 10;
        w_instruction = 32'b000_00_000_0_0_0_00000_00000_0_00000_01010;
        
        //Number 11 in memory 11
        #10
        w_adrs = 11;
        w_instruction = 32'b000_00_000_0_0_0_00000_00000_0_00000_01011;
        
        //Start
        #10
        cpu_en = 1;
        w_enable = 0;
        
        #115
        $display("result=%b",result);
        
        #300
        $stop();    
    
    end
    
endmodule