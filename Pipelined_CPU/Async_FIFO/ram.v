module ram(
    input w_clk,
    input r_clk, 
    input resetn,
    input w_en,
    input r_en,
    input full,
    input empty,
    input [10:0] w_adrs,
    input [10:0] r_adrs,
    input [31:0] w_data,
    output reg [31:0] r_data
);

    reg [31:0] mem [2047:0];
    
    always @(posedge w_clk) begin
        if(!full && w_en && resetn) begin
            mem[w_adrs] <= w_data;
        end
        
    end
    
    always @(posedge r_clk) begin
        if(!full && r_en && resetn) begin
            r_data <= mem[r_adrs];
        end
        
    end
    
endmodule 