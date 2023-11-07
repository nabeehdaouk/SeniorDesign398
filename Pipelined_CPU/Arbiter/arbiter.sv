module arbiter(
    input [31:0] instr,
    input resetn,
    output reg [31:0] FIFO_1, //Into first FIFO connected to core 1
    output reg [31:0] FIFO_2 //Into second FIFO connected to core 2
);
    reg fifo_sel;
    reg [31:0] fifo_1_que [7:0];
    reg [31:0] fifo_2_que [7:0];
    reg [31:0] src_dest_1;
    reg [31:0] dest_src_1;
    reg [31:0] dest_dest_1;
    reg [31:0] src_dest_2;
    reg [31:0] dest_src_2;
    reg [31:0] dest_dest_2;
    localparam fifo_1_sel= 1'b0;
    localparam fifo_2_sel= 1'b1;

    integer i;
    integer j;
    integer k;

    assign FIFO_1= fifo_1_que[0];
    assign FIFO_2= fifo_2_que[0];

    always @(instr) begin
        if (!resetn) begin
            fifo_sel = 1'b0;
            src_dest_1= 32'b0;
            dest_src_1= 32'b0;
            dest_dest_1= 32'b0;
            src_dest_2= 32'b0;
            dest_src_2= 32'b0;
            dest_dest_2= 32'b0;
            for (int k = 0; k < 8; k = k + 1) begin
                fifo_1_que[k] = 32'b0;
                fifo_2_que[k] = 32'b0;
            end
        end
        else begin
            if (instr[27] == 1'b1)
                begin
                    if (instr[26] ==1'b0)
                    begin
                        fifo_1_que= {fifo_1_que[6:0], instr};
                        fifo_sel = 1'b1;
                    end
                    if (instr[26] ==1'b1)
                    begin
                        fifo_2_que= {fifo_2_que[6:0], instr};
                        fifo_sel = 1'b0;
                    end
                end
            else
                begin
                    case (fifo_sel)
                        fifo_1_sel:
                        begin
                            if ((instr[23]== 1'b0) || (instr[22] ==1'b0))
                                begin
                                    for (i = 0; i < 8; i = i + 1) begin
                                        src_dest_1[i]= (((~instr[10])&&({instr[23], instr[10], instr[4:0]} == {fifo_2_que[i][22], fifo_2_que[i][21], fifo_2_que[i][15:11]})) || ((instr[10])&&({instr[23], instr[10], instr[9:5]} == {fifo_2_que[i][22], fifo_2_que[i][21], fifo_2_que[i][20:16]})))?1'b1:1'b0;
                                        dest_src_1[i]= (((~instr[21])&&({instr[22], instr[21], instr[15:11]} == {fifo_2_que[i][23], fifo_2_que[i][10], fifo_2_que[i][4:0]})) || ((instr[21])&&({instr[22], instr[21], instr[20:16]} == {fifo_2_que[i][23], fifo_2_que[i][10], fifo_2_que[i][9:5]})))?1'b1:1'b0;
                                        dest_dest_1[i]= (((~instr[21])&&({instr[22], instr[21], instr[15:11]} == {fifo_2_que[i][22], fifo_2_que[i][21], fifo_2_que[i][15:11]})) || ((instr[21])&&({instr[22], instr[21], instr[20:16]} == {fifo_2_que[i][22], fifo_2_que[i][21], fifo_2_que[i][20:16]})))?1'b1:1'b0;
                                    end
                                    if ((|src_dest_1) || (|dest_src_1) || (|dest_dest_1))
                                        begin
                                            fifo_2_que= {fifo_2_que[6:0], instr};
                                            fifo_sel = 1'b0;
                                        end
                                    else begin
                                        fifo_1_que= {fifo_1_que[6:0], instr};
                                        fifo_sel = 1'b1;
                                    end
                                end
                            else begin
                                fifo_1_que= {fifo_1_que[6:0], instr};
                                fifo_sel = 1'b1;
                            end
                        end

                        fifo_2_sel:
                        begin
                            if ((instr[23]== 1'b0) || (instr[22] ==1'b0))
                                begin
                                    for (j = 0; j <8; j = j + 1) begin
                                        src_dest_2[i]= (((~instr[10])&&({instr[23], instr[10], instr[4:0]} == {fifo_1_que[i][22], fifo_1_que[i][21], fifo_1_que[i][15:11]})) || ((instr[10])&&({instr[23], instr[10], instr[9:5]} == {fifo_1_que[i][22], fifo_1_que[i][21], fifo_1_que[i][20:16]})))?1'b1:1'b0;
                                        dest_src_2[i]= (((~instr[21])&&({instr[22], instr[21], instr[15:11]} == {fifo_1_que[i][23], fifo_1_que[i][10], fifo_1_que[i][4:0]})) || ((instr[21])&&({instr[22], instr[21], instr[20:16]} == {fifo_1_que[i][23], fifo_1_que[i][10], fifo_1_que[i][9:5]})))?1'b1:1'b0;
                                        dest_dest_2[i]= (((~instr[21])&&({instr[22], instr[21], instr[15:11]} == {fifo_1_que[i][22], fifo_1_que[i][21], fifo_1_que[i][15:11]})) || ((instr[21])&&({instr[22], instr[21], instr[20:16]} == {fifo_1_que[i][22], fifo_1_que[i][21], fifo_1_que[i][20:16]})))?1'b1:1'b0;
                                    end
                                    if ((|src_dest_2) || (|dest_src_2) || (|dest_dest_2))
                                        begin
                                            fifo_1_que= {fifo_1_que[6:0], instr};
                                            fifo_sel = 1'b1;
                                        end
                                    else begin
                                        fifo_2_que= {fifo_2_que[6:0], instr};
                                        fifo_sel = 1'b0;
                                    end
                                end
                            else
                                begin
                                    fifo_2_que= {fifo_2_que[6:0], instr};
                                    fifo_sel = 1'b0;
                                end
                        end
                    endcase
                end
        end
    end
endmodule


