module top_level(
    input clk,          //Clock driving design
    input resetn        //Global reset
);
    
    cpu cpu_instance(
        .clk(clk),
        .resetn(resetn),
        .instruction_fetch(instruction_fetch),
        .read_mem(read_mem),
        .write_mem(write_mem),
        .carry(carry),
        .result(result),
        .mem_wadrs(mem_wadrs),
        .mem_radrs(mem_radrs)
    );
    
    memory memory_instance(
        .clk(clk),
        .resetn(resetn),
        .w_adrs(w_adrs),
        .r_adrs(r_adrs),
        .data_in(data_in),
        .w_en(w_en),
        .r_en(r_en),
        .data_out(data_out)
    );
    
endmodule