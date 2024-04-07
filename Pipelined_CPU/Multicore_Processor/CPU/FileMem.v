module FileMem(

    // Interface for CPU read operations
    input [4:0] read_addr_A1, read_addr_B1,
    input [4:0] read_addr_A_M1, read_addr_B_M1,
    
    input [4:0] read_addr_A2, read_addr_B2,
    input [4:0] read_addr_A_M2, read_addr_B_M2,
    // Interface for CPU write operations
    input [4:0] write_addr_A1, write_addr_B1,
    input [31:0] write_data_A1, write_data_B1,
    
    input [4:0] write_addr_A2, write_addr_B2,
    input [31:0] write_data_A2, write_data_B2,
    
    // Data outputs back to the CPU
    output [31:0] read_data_A1, read_data_B1,
    output [31:0] read_data_A_M1, read_data_B_M1,
    
    output [31:0] read_data_A2, read_data_B2,
    output [31:0] read_data_A_M2, read_data_B_M2
);

// Memory declarations for register files A and B
reg [31:0] file_reg_A [31:0];
reg [31:0] file_reg_B [31:0];

// Read operations (combinatorial logic)
assign read_data_A1 = file_reg_A[read_addr_A1];
assign read_data_B1 = file_reg_B[read_addr_B1];
assign read_data_A_M1 = file_reg_A[read_addr_A_M1];
assign read_data_B_M1 = file_reg_B[read_addr_B_M1];

assign read_data_A2 = file_reg_A[read_addr_A2];
assign read_data_B2 = file_reg_B[read_addr_B2];
assign read_data_A_M2 = file_reg_A[read_addr_A_M2];
assign read_data_B_M2 = file_reg_B[read_addr_B_M2];

always @(write_data_A1, write_data_B1) begin
    file_reg_A[write_addr_A1] = write_data_A1;
    file_reg_B[write_addr_B1] = write_data_B1;
end

always @(write_data_A2, write_data_B2) begin
    file_reg_A[write_addr_A2] = write_data_A2;
    file_reg_B[write_addr_B2] = write_data_B2;
end

endmodule
