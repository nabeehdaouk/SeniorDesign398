module single_core_cpu #(DATA_SIZE = 32, MEM_SIZE = 8)(
    input core_clk, sys_clk,
    input resetn,
    output logic carry,
    output logic [31:0] result
);
    logic [10:0] mem_instruction_radrs;     //Output by PC, to Memory - States instruction read address
    
    logic branch_valid;                     //Output by CPU, to PC - States branch was valid
    logic [10:0] branch_address;            //Output by CPU, to PC - States branch address, overrides PC
    logic resetn_branch;                    //Input to FIFO - states branch or reset, so flush 
    
    logic [31:0] instruction_fetch;         //Output by FIFO, to CPU - States instruction data that has been fetched
    
    logic mem_instruction_read_valid;       //Output by Memory, to FIFO - States instruction read was valid, used as enable to FIFO
    logic [31:0] mem_instruction_data_out;  //Output by Memory, to FIFO - States write data
    logic full;                             //Output by FIFO, to Memory - States if we can read more or not TODO: THIS IS SHIT
    logic empty;                            //Output by FIFO, to CPU - States if we can fetch or not                                    
    logic read_fifo;                        //Output by CPU to FIFO - states CPU will read from fifo
    logic memory_insturction_r_en;          //Input to Memory - states we can read from memory
 
    logic [31:0] mem_load_data;             //Output by Memory to SYNCH, to CPU - states load data
    logic read_mem_load;                    //Output by CPU to SYNCH, to Memory - states we want to read memory to get load data
    logic [10:0] mem_radrs_load;            //Output by CPU to SYNCH, to Memory - state read address for load to cpu
    
    logic write_mem_store;                  //Output by CPU to SYNCH, to Memory - states we want to store data in mem
    logic [10:0] mem_wadrs_store;           //Output by CPU to SYNCH, to Memory - states we address to write to
    logic [31:0] mem_wdata_store;           //Output by Memory to SYNCH, to CPU - states data to write
    
    logic read_load_valid;                  //Output from Memory to SYNCH, to CPU - states read from mem for load sucessful
    logic write_store_valid;                //Output from Memory to SYNCH, to CPU - state write from mem for store sucessful
 
    logic [31:0] mem_radrs_ir;              //TODO : Remove this
    
    logic memory_read_load;                 //Ouput by SYCNH to Memory - read enable 1
    logic [10:0] memory_radrs_load;         //Output by SYNCH to Memory - memory read address for load
    logic [31:0] memory_load_data_out;      //Output by SYNCH to CPU - data that is being loaded
    
    logic memory_write_store;               //Output by SYNCH to Memory - write enable 1
    logic memory_read_load_valid;           //Output by Memory to SYNCH - read valid 2 output
    logic memory_write_store_valid;         //Oupput by Memory to SYNCH - write valid 1 output
    logic [31:0] memory_store_data_in;      //Output by Memory to SYNCH - write store data
    logic [11:0] memory_wadrs_store;        //Output by Memory to SYNCH - wadrs to store data
      
      
    assign memory_insturction_r_en = ~full & ~branch_valid;
    assign resetn_branch = (resetn == 1 && branch_valid == 0); 
       
    cpu cpu_instance(
        .clk(core_clk),
        .resetn(resetn),
        .instruction_fetch(instruction_fetch),
        .read_load_valid(read_load_valid),
        .write_store_valid(write_store_valid),
        .fifo_empty(empty),
        .mem_load_data(mem_load_data),
        .branch_valid(branch_valid),
        .read_mem_load(read_mem_load),
        .branch_address(branch_address),
        .write_mem(write_mem_store),
        .carry(carry),
        .result(result),
        .mem_wdata(mem_wdata_store),
        .mem_wadrs(mem_wadrs_store),
        .mem_radrs_ld(mem_radrs_load),
        .read_fifo(read_fifo),
        .mem_radrs_ir(mem_radrs_ir)
    );
    
    pc pc_instance(
        .clk(sys_clk),
        .resetn(resetn),
        .branch_valid(branch_valid),
        .branch_address(branch_address),
        .fifo_full(full),
        .cnt(mem_instruction_radrs)
    );
    
    asynchronous_fifo #(
        .DATA_SIZE(DATA_SIZE),
        .MEM_SIZE(MEM_SIZE)
    ) asynchronous_fifo_instance(
        .wclk(sys_clk),
        .rclk(core_clk),
        .w_en(mem_instruction_read_valid),
        .r_en(read_fifo),
        .w_rstn_only(resetn),
        .r_rstn_only(resetn),
        .fifo_rstn(resetn_branch),
        .w_data(mem_instruction_data_out),
        .r_valid(r_valid), // @suppress "An implicit net wire logic was inferred for 'r_valid'"
        .w_valid(w_valid), // @suppress "An implicit net wire logic was inferred for 'w_valid'"
        .r_data(instruction_fetch),
        .full(full),
        .empty(empty)
    );
    
    
    memory memory_instance(
        .clk(sys_clk),
        .resetn(resetn),
        .w_adrs(memory_wadrs_store),
        .r_adrs1(mem_instruction_radrs),
        .r_adrs2(memory_radrs_load),
        .data_in(memory_store_data_in),
        .w_en(memory_write_store),
        .r_en1(memory_insturction_r_en),
        .r_en2(memory_read_load),
        .r_valid1(mem_instruction_read_valid), 
        .r_valid2(memory_read_load_valid),
        .w_valid1(memory_write_store_valid),
        .data_out1(mem_instruction_data_out),
        .data_out2(memory_load_data_out)
    );
    
    //Synch read_mem_load to memory
    ff_synchronizer #(
        .BITSIZE(1)
    ) synch_read_mem_load(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(read_mem_load),
        .data_out(memory_read_load)
    );
    
    //Synch write_mem_store
    ff_synchronizer #(
        .BITSIZE(1)
    ) synch_write_mem_store(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(write_mem_store),
        .data_out(memory_write_store)
    );
    
    //Sycnh read_load_valid
    ff_synchronizer #(
        .BITSIZE(1)
    ) synch_read_load_valid(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(memory_read_load_valid),
        .data_out(read_load_valid)
    );
    
    //Sycnh write_store_valid
    ff_synchronizer #(
        .BITSIZE(1)
    ) synch_write_store_valid(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(memory_write_store_valid),
        .data_out(write_store_valid)
    );
    
    //Synch mem_radrs_load
    ff_synchronizer #(
        .BITSIZE(11)
    ) ff_synchronizer_instance(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(mem_radrs_load),
        .data_out(memory_radrs_load)
    );
    
    //Synch mem_wadrs_store
    ff_synchronizer #(
        .BITSIZE(11)
    ) synch_mem_wadrs_store(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(mem_wadrs_store),
        .data_out(memory_wadrs_store)
    );
    
    
    //Synch memory_load_data_out
    ff_synchronizer #(
        .BITSIZE(32)
    ) synch_memory_load_data_out(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(memory_load_data_out),
        .data_out(mem_load_data)
    );
    
    //Synch memory_store_data_in
    ff_synchronizer #(
        .BITSIZE(32)
    ) synch_memory_store_data_in(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(mem_wdata_store),
        .data_out(memory_store_data_in)
    );
    
endmodule
