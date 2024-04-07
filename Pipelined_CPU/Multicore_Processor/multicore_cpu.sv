module multicore_cpu #(DATA_SIZE = 32, MEM_SIZE = 8)(
    input core_clk, sys_clk, picture_clk,
    input resetn,
    input [10:0] picture_radrs,
    output logic carry, carry2,
    output logic [23:0] picture_data,
    output logic [31:0] result,result2,
    input cpu_en,
    input [31:0] w_instruction,
    input [10:0] w_adrs,
    input w_enable
);

    wire gated_cpu_clk;
    wire [10:0] mem_w_adrs;
    wire [31:0] mem_data_in;
    wire mem_w_en;


    
    //Wires for data path #1
    logic [10:0] mem_instruction_radrs;     //Output by PC, to Memory - States instruction read address
    
    logic branch_valid;                     //Output by CPU, to PC - States branch was valid
    logic [10:0] branch_address;            //Output by CPU, to PC - States branch address, overrides PC
    logic resetn_branch;                    //Input to FIFO - states branch or reset, so flush 
    
    logic [31:0] instruction_fetch;         //Output by FIFO, to CPU - States instruction data that has been fetched
    
    logic mem_instruction_read_valid;       //Output by Memory, to FIFO - States instruction read was valid, used as enable to FIFO
    logic [31:0] mem_instruction_data_out;  //Output by Memory, to FIFO - States write data
    logic full;                             //Output by FIFO, to Memory - States if we can read more or not 
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
 
    logic memory_read_load;                 //Ouput by SYCNH to Memory - read enable 1
    logic [10:0] memory_radrs_load;         //Output by SYNCH to Memory - memory read address for load
    logic [31:0] memory_load_data_out;      //Output by SYNCH to CPU - data that is being loaded
    
    logic memory_write_store;               //Output by SYNCH to Memory - write enable 1
    logic memory_read_load_valid;           //Output by Memory to SYNCH - read valid 2 output
    logic memory_write_store_valid;         //Oupput by Memory to SYNCH - write valid 1 output
    logic [31:0] memory_store_data_in;      //Output by Memory to SYNCH - write store data
    logic [10:0] memory_wadrs_store;        //Output by Memory to SYNCH - wadrs to store data
      
    logic arb_w_en_one;                     //Arbiter write outputs
    logic fifo_w_en_one;                    //FIFO write enable one
    
    //Shared wires
    logic pc_branch;
    logic [10:0] pc_branch_address;
    logic [31:0] arb_instr_out;
    
    
    
    assign gated_cpu_clk= cpu_en ? core_clk : 1'b0;
    assign gated_sys_clk= cpu_en ? sys_clk : 1'b0;
    assign mem_data_in = cpu_en ? memory_store_data_in : w_instruction;
    assign mem_w_adrs = cpu_en ? memory_wadrs_store : w_adrs;
    assign mem_w_en = cpu_en ? memory_write_store : w_enable;
    
    //Modules for core path 1    
    //cpu core #1
    cpu cpu_instance(
        .clk(gated_cpu_clk),
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
        .read_fifo(read_fifo)
    );
    
    //fifo to core #1
    asynchronous_fifo #(
        .DATA_SIZE(DATA_SIZE),
        .MEM_SIZE(MEM_SIZE)
    ) asynchronous_fifo_instance(
        .wclk(sys_clk),
        .rclk(core_clk),
        .w_en(fifo_w_en_one),
        .r_en(read_fifo),
        .w_rstn_only(resetn),
        .r_rstn_only(resetn),
        .fifo_rstn(resetn_branch),
        .w_data(arb_instr_out),
        .r_valid(r_valid), // @suppress "An implicit net wire logic was inferred for 'r_valid'"
        .w_valid(w_valid), // @suppress "An implicit net wire logic was inferred for 'w_valid'"
        .r_data(instruction_fetch),
        .full(full),
        .empty(empty)
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
    
    
    
    //Wires for data path #2  
    logic branch_valid2;                    //Output by CPU, to PC - States branch was valid
    logic [10:0] branch_address2;           //Output by CPU, to PC - States branch address, overrides PC
    
    logic [31:0] instruction_fetch2;        //Output by FIFO, to CPU - States instruction data that has been fetched
    
    logic full2;                            //Output by FIFO, to Memory - States if we can read more or not 
    logic empty2;                           //Output by FIFO, to CPU - States if we can fetch or not                                    
    logic read_fifo2;                       //Output by CPU to FIFO - states CPU will read from fifo
 
    logic [31:0] mem_load_data2;            //Output by Memory to SYNCH, to CPU - states load data
    logic read_mem_load2;                   //Output by CPU to SYNCH, to Memory - states we want to read memory to get load data
    logic [10:0] mem_radrs_load2;           //Output by CPU to SYNCH, to Memory - state read address for load to cpu
    
    logic write_mem_store2;                 //Output by CPU to SYNCH, to Memory - states we want to store data in mem
    logic [10:0] mem_wadrs_store2;          //Output by CPU to SYNCH, to Memory - states we address to write to
    logic [31:0] mem_wdata_store2;          //Output by Memory to SYNCH, to CPU - states data to write
    
    logic read_load_valid2;                 //Output from Memory to SYNCH, to CPU - states read from mem for load sucessful
    logic write_store_valid2;               //Output from Memory to SYNCH, to CPU - state write from mem for store sucessful
 
    logic memory_read_load2;                //Ouput by SYCNH to Memory - read enable 1
    logic [10:0] memory_radrs_load2;        //Output by SYNCH to Memory - memory read address for load
    logic [31:0] memory_load_data_out2;     //Output by SYNCH to CPU - data that is being loaded
    
    logic memory_write_store2;              //Output by SYNCH to Memory - write enable 1
    logic memory_read_load_valid2;          //Output by Memory to SYNCH - read valid 2 output
    logic memory_write_store_valid2;        //Oupput by Memory to SYNCH - write valid 1 output
    logic [31:0] memory_store_data_in2;     //Output by Memory to SYNCH - write store data
    logic [10:0] memory_wadrs_store2;       //Output by Memory to SYNCH - wadrs to store data
      
    logic arb_w_en_two;                     //Arbiter write outputs
    logic fifo_w_en_two;                    //FIFO write enable one and two 
    
    //Modules for core path 2
    //cpu core 2
    cpu cpu_instance2(
        .clk(gated_cpu_clk),
        .resetn(resetn),
        .instruction_fetch(instruction_fetch2),
        .read_load_valid(read_load_valid2),
        .write_store_valid(write_store_valid2),
        .fifo_empty(empty2),
        .mem_load_data(mem_load_data2),
        .branch_valid(branch_valid2),
        .read_mem_load(read_mem_load2),
        .branch_address(branch_address2),
        .write_mem(write_mem_store2),
        .carry(carry2),
        .result(result2),
        .mem_wdata(mem_wdata_store2),
        .mem_wadrs(mem_wadrs_store2),
        .mem_radrs_ld(mem_radrs_load2),
        .read_fifo(read_fifo2)
    );
    
    //fifo to core #1
    asynchronous_fifo #(
        .DATA_SIZE(DATA_SIZE),
        .MEM_SIZE(MEM_SIZE)
    ) asynchronous_fifo_instance2(
        .wclk(sys_clk),
        .rclk(core_clk),
        .w_en(fifo_w_en_two),
        .r_en(read_fifo2),
        .w_rstn_only(resetn),
        .r_rstn_only(resetn),
        .fifo_rstn(resetn_branch),
        .w_data(arb_instr_out),
        .r_valid(r_valid), // @suppress "An implicit net wire logic was inferred for 'r_valid'"
        .w_valid(w_valid), // @suppress "An implicit net wire logic was inferred for 'w_valid'"
        .r_data(instruction_fetch2),
        .full(full2),
        .empty(empty2)
    );

    //Synch read_mem_load to memory
    ff_synchronizer #(
        .BITSIZE(1)
    ) synch_read_mem_load2(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(read_mem_load2),
        .data_out(memory_read_load2)
    );
    
    //Synch write_mem_store
    ff_synchronizer #(
        .BITSIZE(1)
    ) synch_write_mem_store2(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(write_mem_store2),
        .data_out(memory_write_store2)
    );
    
    //Sycnh read_load_valid
    ff_synchronizer #(
        .BITSIZE(1)
    ) synch_read_load_valid2(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(memory_read_load_valid2),
        .data_out(read_load_valid2)
    );
    
    //Sycnh write_store_valid
    ff_synchronizer #(
        .BITSIZE(1)
    ) synch_write_store_valid2(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(memory_write_store_valid2),
        .data_out(write_store_valid2)
    );
    
    //Synch mem_radrs_load
    ff_synchronizer #(
        .BITSIZE(11)
    ) ff_synchronizer_instance2(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(mem_radrs_load2),
        .data_out(memory_radrs_load2)
    );
    
    //Synch mem_wadrs_store
    ff_synchronizer #(
        .BITSIZE(11)
    ) synch_mem_wadrs_store2(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(mem_wadrs_store2),
        .data_out(memory_wadrs_store2)
    );
    
    
    //Synch memory_load_data_out
    ff_synchronizer #(
        .BITSIZE(32)
    ) synch_memory_load_data_out2(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(memory_load_data_out2),
        .data_out(mem_load_data2)
    );
    
    //Synch memory_store_data_in
    ff_synchronizer #(
        .BITSIZE(32)
    ) synch_memory_store_data_in2(
        .clk(sys_clk),
        .rstn(resetn),
        .data_in(mem_wdata_store2),
        .data_out(memory_store_data_in2)
    );
    
    
    //Shared modules    
    pc pc_instance(
        .clk(gated_sys_clk),
        .resetn(resetn),
        .branch_valid(branch_valid),     
        .branch_address(branch_address), 
        .fifo_full(full),
        .cnt(mem_instruction_radrs)
    );
      
      
    memory memory_instance(
        .clk(sys_clk),
        .picture_clk(picture_clk),
        .resetn(resetn),
        .w_adrs(mem_w_adrs),//
        .w_adrs2(memory_wadrs_store2),
        .r_adrs1(mem_instruction_radrs),
        .r_adrs2(memory_radrs_load),
        .r_adrs3(memory_radrs_load2),
        .picture_radrs(picture_radrs),
        .data_in(mem_data_in),//
        .data_in2(memory_store_data_in2),
        .w_en(mem_w_en),
        .w_en2(memory_write_store2),
        .r_en1(memory_insturction_r_en),
        .r_en2(memory_read_load),
        .r_en3(memory_read_load2),
        .r_valid1(mem_instruction_read_valid),
        .r_valid2(memory_read_load_valid),
        .r_valid3(memory_read_load_valid2),
        .w_valid1(memory_write_store_valid),
        .w_valid2(memory_write_store_valid2),
        .data_out1(mem_instruction_data_out),
        .data_out2(memory_load_data_out),
        .data_out3(memory_load_data_out2),
        .picture_data(picture_data)
    );
    
    arbiter arbiter_instance(
        .instr(mem_instruction_data_out),
        .resetn(resetn),
        .instr_out(arb_instr_out),
        .FIFO_1_en(arb_w_en_one),
        .FIFO_2_en(arb_w_en_two)
    );
    
    //Assigns
    assign pc_branch = branch_valid | branch_valid2;
    assign pc_branch_address = branch_valid ? branch_address : (branch_valid2 ? branch_address2 : 0);
    assign fifo_w_en_one = arb_w_en_one & mem_instruction_read_valid;
    assign fifo_w_en_two = arb_w_en_two & mem_instruction_read_valid;
    assign memory_insturction_r_en = ~full & ~branch_valid & ~branch_valid2;
    assign resetn_branch = (resetn == 1 && branch_valid == 0 && branch_valid2 == 0);
    
endmodule
