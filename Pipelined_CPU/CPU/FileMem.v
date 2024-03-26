module FileMem(

    // Interface for CPU read operations
    input [4:0] read_addr_A, read_addr_B,
    input [4:0] read_addr_A_M, read_addr_B_M,
    // Interface for CPU write operations
    input [4:0] write_addr_A, write_addr_B,
    input [31:0] write_data_A, write_data_B,
    
    // Data outputs back to the CPU
    output [31:0] read_data_A, read_data_B,
    output [31:0] read_data_A_M, read_data_B_M
);

// Memory declarations for register files A and B
reg [31:0] file_reg_A [31:0];
reg [31:0] file_reg_B [31:0];

// Read operations (combinatorial logic)
assign read_data_A = file_reg_A[read_addr_A];
assign read_data_B = file_reg_B[read_addr_B];
assign read_data_A_M = file_reg_A[read_addr_A_M];
assign read_data_B_M = file_reg_B[read_addr_B_M];

always @(write_data_A, write_data_B) begin
    file_reg_A[write_addr_A] = write_data_A;
    file_reg_B[write_addr_B] = write_data_B;
end

endmodule
