module single_core_cpu #(DATA_SIZE = 32, MEM_SIZE = 8)(
    input core_clk, sys_clk,
    input resetn,
    output logic carry,
    output logic [31:0] result
);
    logic [10:0] mem_instruction_radrs;     //Output by PC, to Memory - States instruction read address
    
    logic branch_valid;                     //Output by CPU, to PC - States branch was valid
    logic [10:0] branch_address;            //Output by CPU, to PC - States branch address, overrides PC
    logic read_mem_ir;                      //Output by CPU, to Memory - States we can fetch instruction
    
    logic [31:0] instruction_fetch;         //Output by FIFO, to CPU - States instruction data that has been fetched
    
    logic mem_instruction_read_valid;       //Output by Memory, to FIFO - States instruction read was valid, used as enable 
    logic [31:0] mem_instruction_data_out;  //Output by Memory, to FIFO - States write data
    logic full;                             //Output by FIFO, to Memory - States if we can read more or not TODO: THIS IS SHIT
    logic empty;                            //Output by FIFO, to CPU - States if we can fetch or not TODO: THIS IS SHIT                                    
 
    cpu cpu_instance(
        .clk(core_clk),
        .resetn(resetn),
        .instruction_fetch(instruction_fetch),
        .mem_store_data(mem_store_data),
        .branch_valid(branch_valid),
        .read_mem_str(read_mem_str),
        .branch_address(branch_address),
        .write_mem(write_mem),
        .carry(carry),
        .result(result),
        .mem_wdata(mem_wdata),
        .mem_wadrs(mem_wadrs),
        .mem_radrs_ld(mem_radrs_ld),
        .read_mem_ir(read_mem_ir),
        .fetch_enabled(empty),
        .mem_radrs_ir(mem_radrs_ir)
    );
    
    pc pc_instance(
        .clk(sys_clk),
        .resetn(resetn),
        .branch_valid(branch_valid),
        .branch_address(branch_address),
        .cnt(mem_instruction_radrs)
    );
    
    asynchronous_fifo #(
        .DATA_SIZE(DATA_SIZE),
        .MEM_SIZE(MEM_SIZE)
    ) asynchronous_fifo_instance(
        .wclk(sys_clk),
        .rclk(core_clk),
        .w_en(mem_instruction_read_valid),
        .r_en(read_mem_ir),
        .w_rstn_only(resetn),
        .r_rstn_only(resetn),
        .fifo_rstn(resetn),
        .w_data(mem_instruction_data_out),
        .r_valid(r_valid),
        .w_valid(w_valid),
        .r_data(instruction_fetch),
        .full(full),
        .empty(empty)
    );
    
    
    memory memory_instance(
        .clk(sys_clk),
        .resetn(resetn),
        .w_adrs(w_adrs),
        .r_adrs1(mem_instruction_radrs),
        .r_adrs2(r_adrs2),
        .data_in(data_in),
        .w_en(w_en),
        .r_en1(!full),
        .r_en2(r_en2),
        .r_valid1(r_valid1),
        .r_valid2(r_valid2),
        .data_out1(mem_instruction_data_out),
        .data_out2(data_out2)
    );
    
endmodule
