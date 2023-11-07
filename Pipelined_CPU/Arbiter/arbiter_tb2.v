module arbiter_tb2();
    reg [31:0] instr;
    reg rstn;

    wire [31:0] FIFO1;
    wire [31:0] FIFO2;

    arbiter arbiter_instance(
        .instr(instr),
        .resetn(rstn),
        .FIFO_1(FIFO1),
        .FIFO_2(FIFO2)
    );


    initial begin
        $monitor($time,"    Instruction sent = %h, FIFO1 instr = %h   FIFO2 instr = %h",instr, FIFO1, FIFO2);
        rstn = 0;
        instr = 32'hFFFF_FFFF;
        
        #10 //Arbiter override send to FIFO1
        rstn = 1;
        instr = 32'h00045678;
        
        #10
        instr = 32'h0005678a;
        
        #10
        instr = 32'h000678ab;
        
        #10
        instr = 32'h00078abc;
        
        #10
        instr = 32'h0008abcd;
        
        #10
        instr = 32'h000abcde;
        
$display("test override");
        #10 //Arbiter override send to FIFO1
        rstn = 1;
        instr = 32'b000_10_000_0_0_0_00000_00001_0_00000_00001;
        
        #10 //Arbiter override send to FIFO1
        rstn = 1;
        instr = 32'b000_10_000_0_0_0_00000_00001_0_00000_00011;

        #10 //Arbiter override send to FIFO2
        instr = 32'b000_11_000_0_0_0_00000_00001_0_00000_00111;

         #10 //Arbiter override send to FIFO2
        instr = 32'b000_11_000_0_0_0_00000_00001_0_00000_01111;

$display("reg collition testing");
        #10 //Arbiter sends data to FIFO 1 with different src adrs
        instr = 32'b000_00_000_0_0_0_10000_10001_0_00000_10101;

        #10 //Arbiter sends data to FIFO 1 with same dest as src adrs
        instr = 32'b001_00_000_0_0_0_10000_10101_0_00000_10101;

         #10 //Arbiter sends data to FIFO 1 with different src adrs
        instr = 32'b000_00_000_0_0_0_11000_00011_1_00001_10001;

        #10 //Arbiter sends data to FIFO 1 with same src adrs
        instr = 32'b001_00_000_0_0_1_11000_00011_0_00001_11001;


        #10 //Arbiter sends data to FIFO 1 with same source adrs
        instr = 32'b000_00_000_0_0_00000_1110_00000_0001;

        #10 //Arbiter sends data to FIFO 2 with different destination adrs
        instr = 32'b000_00_000_0_0_00000_1000_00000_1000;

        #10 //Arbiter sends data to FIFO 2 with same destination adrs
        instr = 32'b000_00_000_0_0_10000_0000_11000_0000;

        #10 //Arbiter sends data to FIFO 2 with same source adrs
        instr = 32'b000_00_000_0_0_00000_1010_10000_0000;

    end

endmodule 
