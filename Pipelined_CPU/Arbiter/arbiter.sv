module arbiter(
    input clk,
    input [31:0] instr,
    input resetn,
    output reg [31:0] FIFO_1, //Into first FIFO connected to core 1
    output reg [31:0] FIFO_2 //Into second FIFO connected to core 2
);
    reg fifo_sel;
    reg [31:0] fifo_1_que [31:0];
    reg [31:0] fifo_2_que [31:0];
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


    always @(posedge clk) begin
        if (!resetn) begin
            fifo_sel <= 1'b0;
            FIFO_1 <= 32'b0;
            FIFO_2 <= 32'b0;
        end
        else begin
            fifo_sel <= ~fifo_sel;
            //FIFO_1 <= (fifo_sel==1'b0)? instr: FIFO_1;
            //FIFO_2 <= (fifo_sel==1'b1)? instr: FIFO_2;
            case (fifo_sel)
                fifo_1_sel:
                begin
                    if ((instr[23]== 1'b0) || (instr[22] ==1'b0))
                    begin
                        for (i = 0; i < 32; i = i + 1) begin
                            src_dest_1[i]= ({instr[23], instr[10:0]} == {fifo_2_que[i][22], fifo_2_que[i][21:11]})?1'b1:1'b0;
                            dest_src_1[i]= ({instr[22], instr[21:11]} == {fifo_2_que[i][23], fifo_2_que[i][10:0]})?1'b1:1'b0;
                            dest_dest_1[i]= ({instr[22], instr[21:11]} == {fifo_2_que[i][22], fifo_2_que[i][21:11]})?1'b1:1'b0;
                        end
                        if ((|src_dest_1) || (|dest_src_1) || (|dest_dest_1))
                            begin
                                fifo_2_que= {fifo_2_que[30:0], instr};
                            end
                        else begin
                            fifo_1_que= {fifo_1_que[30:0], instr};
                        end
                    end
                end

                fifo_2_sel:
                begin
                    if ((instr[23]== 1'b0) || (instr[22] ==1'b0))
                    begin
                        for (j = 0; j <32; j = j + 1) begin
                            src_dest_2[j]= ({instr[23], instr[10:0]} == {fifo_1_que[j][22], fifo_1_que[j][21:11]})?1'b1:1'b0;
                            dest_src_2[j]= ({instr[22], instr[21:11]} == {fifo_1_que[j][23], fifo_1_que[j][10:0]})?1'b1:1'b0;
                            dest_dest_2[j]= ({instr[22], instr[21:11]} == {fifo_1_que[j][22], fifo_1_que[j][21:11]})?1'b1:1'b0;
                        end
                        if ((|src_dest_2) || (|dest_src_2) || (|dest_dest_2))
                            begin
                                fifo_1_que<= {fifo_1_que[30:0], instr};
                            end
                        else begin
                            fifo_2_que<= {fifo_2_que[30:0], instr};
                        end
                    end
                end
            endcase
        end
    end
endmodule
