module ram #(DATA_SIZE = 32, MEM_SIZE = 32, ADDR_LEN = 6)(
        input wclk, rclk,
        input w_en, r_en,
        input resetn,
        input [DATA_SIZE-1:0] w_data,
        input [ADDR_LEN-2:0] w_addr, r_addr,
        output reg r_valid, w_valid,
        output reg [DATA_SIZE-1:0] r_data
    );
    
    reg [DATA_SIZE-1:0] fifo_mem [MEM_SIZE-1:0];
    integer i;

    always @(posedge wclk or negedge resetn) begin
        if(!resetn) begin
            for(i = 0; i < MEM_SIZE; i = i + 1) begin
                fifo_mem[i] <= 0;
                w_valid <= 0;
            end
        end
        else if(w_en) begin
            fifo_mem[w_addr] <= w_data;
            w_valid <= 1;
        end
        else begin
          w_valid <= 0;
        end
    end
    
    always @(posedge rclk or negedge resetn) begin
        if(!resetn) begin
            r_data <= 0;
            r_valid <= 0;
        end
        else if(r_en) begin
            r_data <= fifo_mem[r_addr];
            r_valid <= 1;
        end
        else begin
          r_valid <= 0;
        end
    end 
    
endmodule