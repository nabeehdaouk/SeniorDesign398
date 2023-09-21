module pc(
    input clk, //cpu clock
    input resetn, //reset pc register
    input branch_valid, //jump control 
    input [10:0] branch_address, //jump address
    output reg [10:0] cnt //holds program count
);

    always@(posedge clk) 
    begin: program_counter
        if (!resetn)    //When reset is active low count is set to 0
            cnt<= 10'b0000000000;
        else
            if (branch_valid)   //If jump control is active high, count is set to branch address
                cnt<= branch_address;
            else                // Else count = count + 1
                cnt<= cnt+1'b1;
    end

endmodule