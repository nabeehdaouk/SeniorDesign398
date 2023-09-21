module psr(
    input [31:0] res,
    input carry,
    output [4:0] program_status
);
  
  reg [4:0] status;
  
  always @(res) begin
    status[0] = ^res == 1 ? 1 : 0;
    status[1] = res % 2 == 0 ? 1 : 0;
    status[2] = res == 0 ? 1 : 0;
    status[3] = res > 0 ? 1 : 0;
    status[4] = carry ? 1 : 0;
  end
  
  assign program_status = status;  

endmodule