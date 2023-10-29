module arbiter_tb();

    reg clk, resetn, r_adrs1;
    wire [31:0] FIFO_1, FIFO_2, data_out1;


    memory_for_testing memory_instance(
        .clk(clk),
        .resetn(1'b1),
        .w_adrs(),
        .r_adrs1(r_adrs1),
        .r_adrs2(),
        .data_in(),
        .w_en(1'b0),
        .r_en1(1'b1),
        .r_en2(1'b0),
        .r_valid1(),
        .r_valid2(),
        .data_out1(data_out1),
        .data_out2()
    );

    arbiter arbiter_instance(
        .clk(clk),
        .instr(data_out1),
        .resetn(resetn),
        .FIFO_1(FIFO_1),
        .FIFO_2(FIFO_2)
    );

    integer j;

    always #5 clk= ~clk;
    
    initial begin
        resetn=0;
        clk= 0;
        #10
        resetn=1;

        for (j=0; j<100; j=j+1)
            begin
               #10 r_adrs1= j;
               $display("FIFO_1= %h    FIFO_2= %h", FIFO_1, FIFO_2);
            end
    end





endmodule