module memory(data_read, w_mem, r_mem, w_address, r_address, clk, reset, data);
    
input [31:0] data;
input clk, reset, w_mem, r_mem, w_address, r_address;
output [32:0]data_read;
reg [31:0] mem [2047:0];


 
always @(posedge clk) begin: Read_Write_Memory
    
    if (reset) begin
        data_read <= {32{1'b0}};
    end else if (r_mem)begin
        data_read <= mem[data[21:11]];
    
    end else if (w_mem) begin
        mem[data[21:11]] <= data;
    end 
    

end

endmodule