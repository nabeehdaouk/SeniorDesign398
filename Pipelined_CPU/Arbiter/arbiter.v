module arbiter(
    input clk,
    input [31:0] instr,
    input resetn,
    output reg [31:0] FIFO_1, //Into first FIFO connected to core 1
    output reg [31:0] FIFO_2 //Into second FIFO connected to core 2
);
    reg fifo_sel;
    reg [21:0] src_dest1_adrs [7:0];
    reg [21:0] src_dest2_adrs [7:0];
    reg load;
    
    localparam LD = 3'b111;
    localparam STR = 3'b110;


    always @(posedge clk) begin
        if (!resetn) begin
            fifo_sel <= 1'b0;
            FIFO_1 <= 32'b0;
            FIFO_2 <= 32'b0;
        end
        else begin

            case(instr[28:27])

                2'b10: begin
                    FIFO_1 <= instr;
                end

                2'b11: begin
                    FIFO_2 <= instr;
                end

                default: begin

                    case(instr[31:29])

                        LD: begin
                        end
                        STR: begin
                        end

                        default: begin
                            if(fifo_sel == 0) begin
                                if(instr[23] == 0 && instr[22] == 0) begin
                                    for(integer i = 0; i < 8; i = i + 1) begin
                                        if((instr[21:11] == src_dest2_adrs[i][21:11] || (instr[21:11] == src_dest2_adrs[i][10:0]))) begin
                                            FIFO_2 <= instr;
                                            load <= 1;
                                        end
                                        else begin
                                            load <= 0;
                                        end
                                    end
                                end
                            end
                            else if(fifo_sel == 1) begin
                            end
                        end

                    endcase
                end

            endcase
            /*
            fifo_sel <= ~fifo_sel;
            FIFO_1 <= (fifo_sel==1'b0)? instr: FIFO_1;
            FIFO_2 <= (fifo_sel==1'b1)? instr: FIFO_2;
            
            
            if(fifo_sel == 0) begin
                if((instr[21:11] == dest2_adrs[0]) || (instr[21:11] == dest2_adrs[1]) || (instr[21:11] == dest2_adrs[2])
                || (instr[21:11] == dest2_adrs[3]) || (instr[21:11] == dest2_adrs[4] || (instr[21:11] == dest2_adrs[5])
                || (instr[21:11] == dest2_adrs[6]) || (instr[21:11] == dest2_adrs[7]))) 
                begin
                    FIFO_2 <= instr;
                end
                else begin
                    FIFO_1 <= instr;
                    dest1_adrs[] <= instr[21:11];
                end
            end
            else if (fifo_sel == 1) begin
            end
        */

        end
    end

    always @(load) begin
        
    end
    
endmodule
