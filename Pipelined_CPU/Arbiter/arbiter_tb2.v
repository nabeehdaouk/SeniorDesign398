module arbiter_tb2();
    reg [31:0] instr;
    reg rstn;
    wire [31:0] instr_out;
    wire FIFO_1_en;
    wire FIFO_2_en;

    arbiter arbiter_instance(
        .instr(instr),
        .resetn(rstn),
        .FIFO_1_en(FIFO_1_en),
        .FIFO_2_en(FIFO_2_en),
        .instr_out(instr_out)
    );


    initial begin
        $monitor($time,"    Instruction sent = %h, FIFO1 instr = %h   FIFO2 instr = %h",instr, FIFO_1_en, FIFO_2_en);
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
        

        #10 //Arbiter override send to FIFO1
        $display("test override");
        rstn = 1;
        instr = 32'b000_10_000_0_0_0_00000_00001_0_00000_00001;
        
        #10 //Arbiter override send to FIFO1
        rstn = 1;
        instr = 32'b000_10_000_0_0_0_00000_00001_0_00000_00011;

        #10 //Arbiter override send to FIFO2
        instr = 32'b000_11_000_0_0_0_00000_00001_0_00000_00111;

         #10 //Arbiter override send to FIFO2
        instr = 32'b000_11_000_0_0_0_00000_00001_0_00000_01111;


        #10 //Arbiter sends data to FIFO 2 with different src adrs
        $display("reg collition testing");
        $display("next 3 instr should all go into same fifo");
        instr = 32'b000_00_000_0_0_0_10000_10001_0_00000_10101;

        #10 //Arbiter sends data to FIFO 2 with same dest as src adrs
        instr = 32'b001_00_000_0_0_0_10000_10101_0_00000_10100;

        #10 //Arbiter sends data to FIFO 2 with same dest adrs as last dest
        instr = 32'b001_00_000_0_0_0_10000_10101_1_00000_10111;

        #10 //Arbiter sends data to FIFO 1 with different destination adrs
        $display("next instr should all go into OTHER fifo");
        instr = 32'b001_00_000_0_0_1_10000_10101_1_00000_00001;
        


       // #10 //Arbiter sends data to FIFO 1 with same destination adrs
        //instr = ;
//FINISH FROM HERE
       // #10 //Arbiter sends data to FIFO 1 with same source adrs
       // instr = ;

    end

endmodule 
