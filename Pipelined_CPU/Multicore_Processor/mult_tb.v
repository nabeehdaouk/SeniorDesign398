module mult_tb();
    
    reg core_clk, sys_clk;
    reg resetn;        //Global reset
    reg cpu_en;
    reg [31:0] w_instruction;
    reg w_enable;
    reg [10:0] w_adrs;
    wire carry, carry2;
    wire [31:0]result, result2;
    
    localparam NOP = 32'b000_10_000_0_0_0_00000_00000_0_00000_00000;
    
    multicore_cpu #(
        .DATA_SIZE(32),
        .MEM_SIZE(8)
    ) multicore_cpu_instance(
        .core_clk(core_clk),
        .sys_clk(sys_clk),
        .picture_clk(picture_clk),
        .resetn(resetn),
        .picture_radrs(picture_radrs),
        .carry(carry),
        .carry2(carry2),
        .result(result),
        .picture_data(picture_data),
        .result2(result2),
        .cpu_en(cpu_en),
        .w_instruction(w_instruction),
        .w_adrs(w_adrs),
        .w_enable(w_enable)
    );
    
    always #5 core_clk = ~core_clk;
    always #5 sys_clk = ~sys_clk;
    
    initial begin
        
        //Reset
        sys_clk = 0;
        core_clk=0;
        resetn = 0;
        cpu_en = 1;
        w_instruction = 32'h0000_0000;
        w_enable = 0;
        
        //Add instrction
        #10
        cpu_en = 0;
        resetn = 1;
        w_enable = 1;
        
        w_adrs = 0;
        w_instruction = 32'h0000000d;
        
        #10
        w_adrs = 1;
        w_instruction = 32'h000000b;
        
        #10
        w_adrs = 2;
        w_instruction = 32'h0; //0
        
        #10
        w_adrs = 10'hff;
        w_instruction = 32'hffffffff; //-1
        
        
         $display("------------------------------------------------------------------------------------------------------------");
        $display("PROGRAMING MODE");
        $display("PROGRAMING MULTIPLICATION TEST PROGRAM...");
        $display();
        $display("VALUES IN MEM:");
        $display("hX000  -> A VALUE = 0000000d");
        $display("hX001  -> B VALUE = 0000000f");
        $display("hX002  -> C INITIAL = 00000000");
        $display("hX00f  -> DECREMENT = ffffffff");
        $display();
        $display("ADRS  -> INST SRC DEST");
        $display("hX004 -> LD MEM0 REGA_0");
        $display("hX005 -> LD MEM1 REGA_1");
        $display("hX006 -> LD MEM2 REGA_2");
        $display("hX007 -> LD MEMf REGA_f");
        $display("hX008 -> ADD REGA_0 REGA_2");
        $display("hX009 -> NOOP");
        $display("hX00a -> NOOP");
        $display("hX00b -> ADD REGA_f REGA_1");
        $display("hX00c -> NOOP");
        $display("hX00d -> NOOP");
        $display("hX00e -> BRA ZERO ADRS010");
        $display("hX00f -> BRA POS ADRS008");
        $display("hX010 -> STR REGA_2 MEM2");


        #10
        w_adrs = 4;
        w_instruction = 32'b111_10_000_0_0_0_00000_00000_0_00000_00000; //LOAD MEM0 REG_A_0
        
        #10
        w_adrs = 5;
        w_instruction = 32'b111_10_000_0_0_0_00000_00001_0_00000_00001; //LOAD MEM1 REG_A_1
        
        #10
        w_adrs = 6;
        w_instruction = 32'b111_10_000_0_0_0_00000_00010_0_00000_00010; //LOAD MEM2 REG_A_2
        
        #10
        w_adrs = 7;
        w_instruction = 32'b111_10_000_0_0_0_00000_01111_0_00111_11111; //LOAD MEMff REG_A_f
        
        #10
        w_adrs = 8;
        w_instruction = NOP; 
        
        #10
        w_adrs = 9;
        w_instruction = NOP; 
        
        #10
        w_adrs = 10;
        w_instruction = 32'b100_10_000_0_0_0_00000_00010_0_00000_00000; //Add REG_A_0 REG_A_2
        
        #10
        w_adrs = 11;
        w_instruction = NOP; 
        
        #10
        w_adrs = 12;
        w_instruction = NOP; 
        
        #10
        w_adrs = 13;
        w_instruction = NOP; 
        
        
        #10
        w_adrs = 14;
        w_instruction = 32'b100_10_000_0_0_0_00000_00001_0_00000_01111; //Add REG_A_f REG_A_1
        
        #10
        w_adrs = 15;
        w_instruction = NOP; 
        
        #10
        w_adrs = 16;
        w_instruction = NOP; 
        
        #10
        w_adrs = 17;
        w_instruction = NOP; 
        
        #10
        w_adrs = 18;
        w_instruction = 32'b101_10_100_0_0_0_00000_10110_0_00000_00000; //BRANCH EQZ MEM_20
        
        #10
        w_adrs = 19;
        w_instruction = 32'b101_10_100_0_0_0_00000_10110_0_00000_00000; //BRANCH EQZ MEM_20
        //w_instruction = NOP; 
        
        #10
        w_adrs = 20;
        w_instruction = 32'b101_10_000_0_0_0_00000_01000_0_00000_00000; //BRANCH POS MEM_8 
        
        #10
        w_adrs = 21;
        //w_instruction = 32'b110_10_000_0_1_0_00000_00010_0_00000_00010; //STORE REG_A_2 MEM2
        
        
       #10
        w_adrs = 22;
        w_instruction = 32'b110_10_000_0_1_0_00000_00010_0_00000_00010; //STORE REG_A_2 MEM2
        
        //Start
                $display("RUNNING MULTIPLICATION TEST PROGRAM...");
        $display("*****************************");
        $display("CHECKING MEMORY VALUE AT LOCATION hX002");
        $display("MULTIPLIED 11 * 13, EXP RES: 143");
        $display("*****************************");
        #10
        cpu_en = 1;
        w_enable = 0;
        
        #5000

        $stop();    
    
    end
    
endmodule