module pc(
    input clk,
    input reset,
    input branch_valid,
    input [3:0] branch_address,
    output reg [3:0] cnt
);

    always@(posedge clk)
    begin
        if (reset)
            cnt<= 3'b000;
        else
            if (branch_valid)
                cnt<= branch_address;
            else
                cnt<= cnt+1;
    end

endmodule