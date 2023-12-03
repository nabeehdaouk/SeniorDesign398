module tb();

    logic core_clk,sys_clk, picture_clk;
    logic resetn;
    logic carry,carry2;
    logic [31:0] result,result2;
    logic [10:0] picture_radrs;
    logic [23:0] picture_data;
    logic [7:0] red,green,blue;
    
    assign red = picture_data[23:16];
    assign green = picture_data[15:8];
    assign blue = picture_data[7:0];
    
    integer pinguFile;
    
    
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
        .result2(result2)
    );

    always #2 picture_clk = ~picture_clk;
    always #300 sys_clk = ~sys_clk;
    always #600 core_clk = ~core_clk;
    
    //Increment picture r_adrs
    always @(posedge picture_clk) begin
        if(picture_data[0] == 0 || picture_data[0] == 1) begin
            if(picture_radrs == 2047) begin
                $fdisplay(pinguFile, "%b", {8'h0, picture_data} );
                $fdisplay(pinguFile,"################################");
            end 
            else begin
                $fdisplay(pinguFile, "%b", {8'h0, picture_data} );
            end
            
            if (picture_radrs == 2047 ) begin
                picture_radrs <= 1792;
            end else begin
                picture_radrs <= picture_radrs + 1;
            end
        end
    end
    
    initial begin
        core_clk = 0;
        sys_clk = 0;
        picture_clk = 0;
        picture_radrs = 1792;
        resetn = 0;
        pinguFile = $fopen("C:/Users/jsalm/OneDrive/Projects/Verilog-UVM-Systemverilog/Multicore_Processor/Pingu/pingu.txt", "w");
        $monitor("radrs = 0x%0x, data = 0x%0x, red = 0x%0x, green = 0x%0x, blue = 0x%0x", picture_radrs, picture_data, red, green, blue );
        #1400
        resetn = 1;
        #4000
        $fclose(pinguFile);
        $stop();  
    end
    
endmodule

