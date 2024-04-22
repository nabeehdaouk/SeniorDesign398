module arbiter(
    input [31:0] instr,
    input resetn,
    output reg [31:0] instr_out,
    output reg FIFO_1_en, //Into first FIFO connected to core 1
    output reg FIFO_2_en //Into second FIFO connected to core 2
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
    integer ii;

    //assign FIFO_1= fifo_1_que[0];
    //assign FIFO_2= fifo_2_que[0];
    assign instr_out= instr;

    always @(instr) begin
        if (!resetn) begin
            fifo_sel = 1'b0;
            src_dest_1= 32'b0;
            dest_src_1= 32'b0;
            dest_dest_1= 32'b0;
            src_dest_2= 32'b0;
            dest_src_2= 32'b0;
            dest_dest_2= 32'b0;
            for (int ii = 0; ii < 8; ii = ii + 1) begin
                fifo_1_que[ii] = 32'b0;
                fifo_2_que[ii] = 32'b0;
            end
        end
        else begin
            if (instr[28] == 1'b1) //flipback1
                begin
                    if (instr[27] ==1'b0)//flipback 0
                    begin
                        fifo_1_que= {fifo_1_que[6:0], instr};
                        FIFO_1_en= 1'b1;
                        FIFO_2_en= 1'b0;
                        fifo_sel = 1'b1;
                    end
                    if (instr[27] ==1'b1)//flipback 1
                    begin
                        fifo_2_que= {fifo_2_que[6:0], instr};
                        FIFO_1_en= 1'b0;
                        FIFO_2_en= 1'b1;
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
                                            FIFO_1_en= 1'b0;
                                            FIFO_2_en= 1'b1;
                                            fifo_sel = 1'b0;
                                        end
                                    else begin
                                        fifo_1_que= {fifo_1_que[6:0], instr};
                                        FIFO_1_en= 1'b1;
                                        FIFO_2_en= 1'b0;
                                        fifo_sel = 1'b1;
                                    end
                                end
                            else begin
                                fifo_1_que= {fifo_1_que[6:0], instr};
                                FIFO_1_en= 1'b1;
                                FIFO_2_en= 1'b0;
                                fifo_sel = 1'b1;
                            end
                        end

                        fifo_2_sel:
                        begin
                            if ((instr[23]== 1'b0) || (instr[22] ==1'b0))
                                begin
                                    for (j = 0; j <8; j = j + 1) begin
                                        src_dest_2[j]= (((~instr[10])&&({instr[23], instr[10], instr[4:0]} == {fifo_1_que[j][22], fifo_1_que[j][21], fifo_1_que[j][15:11]})) || ((instr[10])&&({instr[23], instr[10], instr[9:5]} == {fifo_1_que[j][22], fifo_1_que[j][21], fifo_1_que[j][20:16]})))?1'b1:1'b0;
                                        dest_src_2[j]= (((~instr[21])&&({instr[22], instr[21], instr[15:11]} == {fifo_1_que[j][23], fifo_1_que[j][10], fifo_1_que[j][4:0]})) || ((instr[21])&&({instr[22], instr[21], instr[20:16]} == {fifo_1_que[j][23], fifo_1_que[j][10], fifo_1_que[j][9:5]})))?1'b1:1'b0;
                                        dest_dest_2[j]= (((~instr[21])&&({instr[22], instr[21], instr[15:11]} == {fifo_1_que[j][22], fifo_1_que[j][21], fifo_1_que[j][15:11]})) || ((instr[21])&&({instr[22], instr[21], instr[20:16]} == {fifo_1_que[j][22], fifo_1_que[j][21], fifo_1_que[j][20:16]})))?1'b1:1'b0;
                                    end
                                    if ((|src_dest_2) || (|dest_src_2) || (|dest_dest_2))
                                        begin
                                            fifo_1_que= {fifo_1_que[6:0], instr};
                                            FIFO_1_en= 1'b1;
                                            FIFO_2_en= 1'b0;
                                            fifo_sel = 1'b1;
                                        end
                                    else begin
                                        fifo_2_que= {fifo_2_que[6:0], instr};
                                        FIFO_1_en= 1'b0;
                                        FIFO_2_en= 1'b1;
                                        fifo_sel = 1'b0;
                                    end
                                end
                            else
                                begin
                                    fifo_2_que= {fifo_2_que[6:0], instr};
                                    FIFO_1_en= 1'b0;
                                    FIFO_2_en= 1'b1;
                                    fifo_sel = 1'b0;
                                end
                        end
                        default begin
                            fifo_1_que= {fifo_1_que[6:0], instr};
                            FIFO_1_en= 1'b1;
                            FIFO_2_en= 1'b0;
                            fifo_sel = 1'b1;
                        end
                    endcase
                end
        end
    end
endmodule


