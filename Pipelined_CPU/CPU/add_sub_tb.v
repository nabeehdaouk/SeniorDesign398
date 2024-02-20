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
    
    localparam LOAD = 12'b111_00_000_0_0_;
    localparam REG_A3 = 11'b0_00000_00011;
    localparam REG_B3 = 11'b1_00011_00000;
    localparam NOP = 32'b0;
    
    
    
    
    
    always #5 clk = ~clk;
    
    initial begin
        //Reset
        clk = 0;
        resetn = 0;
        cpu_en = 1;
        w_instruction = 32'h0000_0000;
        w_enable = 0;
        
        //Load the number 10 from memory into reg_a_3
        #10
        cpu_en = 0;
        resetn = 1;
        w_enable = 1;
        w_adrs = 1;
        w_instruction = {LOAD, REG_A3, 11'd100}; //LOAD MEM10 REG_A_3
        
        //Load the number 11 from memory into reg_b_3 
        #10
        w_adrs = 2;
        w_instruction = {LOAD, REG_B3, 11'd101}; //LOAD MEM11 REG_B_3
        
        //Add immediate to value in register a
        #10
        w_adrs = 5;
        w_instruction = 32'b100_00_000_1_0_0_00000_00011_0_00000_00101;  //ADD 5 REG_A_3
      
        //Add immediate to value in register b
        #10
        w_adrs = 6;
        w_instruction = 32'b100_00_000_1_0_1_00011_00000_0_00000_00001;  //ADD 1 REG_B_3
        
        #10
        w_adrs = 7;
        w_instruction = NOP; 
        
        #10
        w_adrs = 8;
        w_instruction = NOP; 
        
        //Add instruction  
        #10
        w_adrs = 9;
        w_instruction = 32'b011_00_000_1_0_0_00000_00011_0_00000_00001;  //SUB 1 REG_A_3

        //Add instruction
        #10
       // w_adrs = 8;
       // w_instruction = 32'b101_00_100_0_0_0_00000_00110_0_00000_00000; //BRA NEZ MEM6
        
        #10
        w_adrs = 10;
        w_instruction = NOP; 
        
        #10
        w_adrs = 11;
        w_instruction = NOP; 
        
        #10
        w_adrs = 12;
        w_instruction = NOP; 
        
        #10
        w_adrs = 13;
        w_instruction = 32'b100_00_000_0_0_0_00000_00011_1_00011_00000; //Add REG_B_3 REG_A_3
        
        
        
        
        
        
    
        //Number 10 in memory 10
        #10
        w_adrs = 100;
        w_instruction = 32'd10;
        
        //Number 11 in memory 11
        #10
        w_adrs = 101;
        w_instruction = 32'd11;
        
        //Start
        #10
        cpu_en = 1;
        w_enable = 0;
        
        //#115
        
        $monitor($time, "   result=%d",result);
        
        #1000
        $stop();    
    
    end
    
endmodule