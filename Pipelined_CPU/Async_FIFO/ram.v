module ram(
    input w_clk,                    //Write clock
    input r_clk,                    //Read clock
    input resetn,                   //Negative reset signal
    input w_en,                     //Write enable
    input r_en,                     //Read enable
    input full,                     //Full condition
    input empty,                    //Empty condition
    input [10:0] w_adrs,            //Write address
    input [10:0] r_adrs,            //Read address
    input [31:0] w_data,            //Write data
    output reg [31:0] r_data        //Read data
);

    reg [31:0] mem [2047:0];        //Memory
    
    always @(posedge w_clk) begin: WRITE_TO_MEM
        if(!full && w_en && resetn) begin
            mem[w_adrs] <= w_data;
        end
        
    end
    
    always @(posedge r_clk) begin: READ_TO_MEM
        if(!full && r_en && resetn) begin
            r_data <= mem[r_adrs];
        end
        
    end
endmodule 