module arbiter(
    input clk,
    input [31:0] instr,
    input resetn,
    output reg [31:0] FIFO_1, //Into first FIFO connected to core 1
    output reg [31:0] FIFO_2 //Into second FIFO connected to core 2
);
    reg fifo_sel;

    always @(posedge clk) begin
        if (!resetn) begin
            fifo_sel <= 1'b0;
            FIFO_1<= 32'b0;
            FIFO_2<= 32'b0;
        end
        else begin
            fifo_sel <= ~fifo_sel;
            FIFO_1 <= (fifo_sel==1'b0)? instr: FIFO_1;
            FIFO_2 <= (fifo_sel==1'b1)? instr: FIFO_2;
        end
    end
endmodule
