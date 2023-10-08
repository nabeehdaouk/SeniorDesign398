module ram #(parameter mem_width=32, mem_depth = 8)(
    input w_clk,                            //Write clock
    input r_clk,                            //Read clock
    input resetn,                           //Negative reset signal
    input w_en,                             //Write enable
    input r_en,                             //Read enable
    input full,                             //Full condition
    input empty,                            //Empty condition
    input [mem_depth - 1:0] w_adrs,         //Write address
    input [mem_depth - 1:0] r_adrs,         //Read address
    input [mem_width:0] w_data,             //Write data
    output reg [mem_width -1:0] r_data      //Read data
);

    reg [mem_width - 1:0] mem [mem_depth - 1:0];        //Memory
    
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