module pc(
    input clk,
    input reset,
    input branch_valid,
    input [10:0] branch_address,
    output reg [10:0] cnt
);

    always@(posedge clk)
    begin
        if (reset)
            cnt<= 10'b0000000000;
        else
            if (branch_valid)
                cnt<= branch_address;
            else
                cnt<= cnt+1'b1;
    end

endmodule