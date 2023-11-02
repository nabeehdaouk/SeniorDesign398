module tb();

    logic core_clk,sys_clk;
    logic resetn;
    logic carry;
    logic [31:0] result;

    single_core_cpu #(
        .DATA_SIZE(32),
        .MEM_SIZE(8)
    ) single_core_cpu_instance(
        .core_clk(core_clk),
        .sys_clk(sys_clk),
        .resetn(resetn),
        .carry(carry),
        .result(result)
    );

    always #5 sys_clk = ~sys_clk;
    always #10 core_clk = ~core_clk;
    
    initial begin
        core_clk = 0;
        sys_clk = 0;
        resetn = 0;
        #40
        resetn = 1;
        #400
        $stop();  
    end
    
endmodule
