module pc(
    input clk,                      //CPU clock
    input resetn,                   //Reset pc register
    input branch_valid,             //Branch control 
    input [10:0] branch_address,    //Branch address
    output reg [10:0] cnt           //Holds program count
);

    always @(posedge clk) begin: Program_Counter
        if (!resetn) begin              //When reset is active low count is set to 0
            cnt <= 0;
        end else begin
            if (branch_valid) begin     //If branch control is active high, count is set to branch address
                cnt <= branch_address;
            end else begin              //Else count = count + 1
                cnt <= cnt + 1;
            end
        end
    end

endmodule