module pc(
    input clk, //cpu clock
    input reset, //reset pc register
    input branch_valid, //jump control 
    input [10:0] branch_address, //jump address
    output reg [10:0] cnt //holds program count
);

    always@(posedge clk) 
    begin: program_counter
        if (reset)
            cnt<= 10'b0000000000;
        else
            if (branch_valid)
                cnt<= branch_address;
            else
                cnt<= cnt+1'b1;
    end

endmodule