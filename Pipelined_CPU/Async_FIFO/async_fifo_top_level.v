module async_fifo_top_level#(DATA_SIZE = 32, MEM_SIZE = 32)(
        input wclk, rclk,
        input w_en, r_en,
        input w_rstn_only, r_rstn_only,
        input fifo_rstn,
        input [DATA_SIZE-1:0] w_data,
        output reg r_valid, w_valid,
        output reg [DATA_SIZE-1:0] r_data,
        output reg full, empty
    );
    
    localparam PTR_LEN = $clog2(MEM_SIZE) + 1;
    reg [PTR_LEN-1:0] wptr, rptr;
    reg [PTR_LEN-1:0] g_wptr, g_rptr;
    reg [PTR_LEN-1:0] g_wptr_sync, g_rptr_sync;
    reg [PTR_LEN-1:0] wptr_sync, rptr_sync;
    wire [PTR_LEN-2:0] w_addr, r_addr;
    wire fifo_w_en, fifo_r_en;
    wire w_rstn, r_rstn;
    
    assign fifo_w_en = w_en & ~(full);
    assign fifo_r_en = r_en & ~(empty);
    assign w_addr = wptr[PTR_LEN-2:0];
    assign r_addr = rptr[PTR_LEN-2:0];
    assign w_rstn = (fifo_rstn & w_rstn_only);
    assign r_rstn = (fifo_rstn & r_rstn_only);
            
    //Covert read and write pointers to gray
    binary_to_gray #(.WIDTH(PTR_LEN)) rptr_to_gray(.bin(rptr), .gray(g_rptr));
    binary_to_gray #(.WIDTH(PTR_LEN)) wptr_to_gray(.bin(wptr), .gray(g_wptr));
    
    //Flop gray rptr and wptr
    ff_sync #(.DATA_WIDTH(PTR_LEN)) rptr_synch(
        .clk(wclk), 
        .resetn(r_rstn), 
        .data_in(g_rptr), 
        .data_out(g_rptr_sync)
        );
        
    ff_sync #(.DATA_WIDTH(PTR_LEN)) wptr_synch(
        .clk(rclk), 
        .resetn(w_rstn), 
        .data_in(g_wptr), 
        .data_out(g_wptr_sync)
        );
    
    //Covert gray read and write pointers to binary
    gray_to_binary #(.WIDTH(PTR_LEN)) rptr_to_binary(.gray(g_rptr_sync), .bin(rptr_sync));
    gray_to_binary #(.WIDTH(PTR_LEN)) wptr_to_binary(.gray(g_wptr_sync), .bin(wptr_sync));
    
    //FIFO Memory 
    ram #(.DATA_SIZE(DATA_SIZE), .MEM_SIZE(MEM_SIZE), .ADDR_LEN(PTR_LEN)) memory (
        .wclk(wclk),
        .rclk(rclk),
        .w_en(fifo_w_en),
        .r_en(fifo_r_en),
        .resetn(fifo_rstn),
        .r_valid(r_valid),
        .w_valid(w_valid),
        .w_data(w_data),
        .r_data(r_data),
        .w_addr(w_addr),
        .r_addr(r_addr)
    );

    always @(*) begin
    
        //Check Full
        if((wptr[PTR_LEN-2:0] + 1) == rptr_sync[PTR_LEN-2:0]) begin
            full = 1;
        end else begin
            full = 0;
        end
        
        //Check Empty
        if(rptr == wptr_sync) begin
            empty = 1;
        end else begin
            empty = 0;
        end
    end

    always @(posedge wclk) begin
        if(!w_rstn) begin
            wptr <= 0;
        end
        else if(w_rstn & fifo_rstn & w_en & !full) begin
            wptr <= wptr + 1;
        end
    end
    
    always @(posedge rclk) begin
        if(!r_rstn) begin
            rptr <= 0;
        end 
        else if(r_rstn & fifo_rstn & r_en & !empty) begin
            rptr <= rptr + 1;
        end
    end
  
endmodule