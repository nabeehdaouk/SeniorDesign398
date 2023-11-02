module arbiter_tb2();
    reg [31:0] instr;
    reg rstn;
	
	wire [31:0] FIFO1;
	wire [31:0] FIFO2;
	
	arbiter arbiter_instance(
	    .instr(instr),
	    .resetn(resetn),
	    .FIFO_1(FIFO_1),
	    .FIFO_2(FIFO_2)
	);
	
	
	initial begin
	   $monitor($time,"Instruction sent = %b, FIFO1 instr = %b   FIFO2 instr = %b",instr, FIFO1, FIFO2);
	   rstn = 0;
	   instr = 32'hFFFF_FFFF;
	   
	   #10     //Arbiter override send to FIFO1
	   rstn = 1;
	   instr = 32'b000_10_000_0_0_00000_0001_00000_0001;
	   
	   #10     //Arbiter override send to FIFO2
	   instr = 32'b000_11_000_0_0_10000_0000_10000_0000;
	   
	   #10     //Arbiter sends data to FIFO 1 with different destination adrs
	   instr = 32'b000_00_000_0_0_00000_0010_00000_0010;
	   
	   #10     //Arbiter sends data to FIFO 1 with same destination adrs
	   instr = 32'b000_00_000_0_0_00000_0001_00000_1111;
	   
	   #10     //Arbiter sends data to FIFO 1 with same source adrs
	   instr = 32'b000_00_000_0_0_00000_1110_00000_0001;
	   
	   #10     //Arbiter sends data to FIFO 2 with different destination adrs
	   instr = 32'b000_00_000_0_0_00000_1000_00000_1000;
	   
	   #10     //Arbiter sends data to FIFO 2 with same destination adrs
	   instr = 32'b000_00_000_0_0_10000_0000_11000_0000;
	   
	   #10     //Arbiter sends data to FIFO 2 with same source adrs
	   instr = 32'b000_00_000_0_0_00000_1010_10000_0000;
	   
	end
	
endmodule 
