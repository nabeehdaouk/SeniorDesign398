module cpu(
    input clk,                          //Clock for CPU
    input resetn,                       //Global reset signal
    input [31:0] instruction_fetch,     //Instruction fetched from memory
    output read_mem,                    //Read enable to memory
    output write_mem,                   //Write enable to memory
    output carry,                       //Carry from addition or subtraction
    output [31:0] result,               //Result (either sent to mem, or just as an output)
    output [10:0] mem_wadrs,            //Write address to memory
    output [10:0] mem_radrs             //Read address to read from memory
);

    localparam LOAD = 3'b111;
    localparam STORE = 3'b110;
    localparam BRANCH = 3'b101;
    localparam ADD = 3'b100;
    localparam SUBTRACT = 3'b011;
    localparam AND = 3'b010;
    localparam OR = 3'b001;
    localparam NOOP = 3'b000;
    
    reg [31:0] decode;                  //Stores the information being decoded
    reg [31:0] execute;
    reg [31:0] mem;
    reg [31:0] write_back;
    reg [10:0] pc_cnt;                  //Stores program count
    
    reg [31:0] file_reg_A [31:0];
    reg [31:0] file_reg_B [63:0];
    
    reg [31:0] opperand1;
    reg [31:0] opperand2;
    
    wire [10:0] branch_address; //Defines branch address, only taken if valid
    wire branch_valid;          //Defines if the branch was valid or not
    wire program_status;        //Defines the program status used for branches    
    
    psr program_status_register(
        .res(result),
        .carry(carry),
        .program_status(program_status)
    );

    pc program_counter(
        .clk(clk),
        .resetn(resetn),
        .branch_valid(branch_valid),
        .branch_address(branch_address),
        .cnt(pc_cnt)
    ); 


    //Fetch - Load fetched command to be decoded
    always @(posedge clk) begin : FETCH
        decode <= instruction_fetch;
    end
    
    
        //Decode - Decode instruction, get any operands from file regs
    always @(posedge clk) begin : DECODE 
        case (decode[23])//Source type bit
            1'b0: //reg
            begin
                opperand1<=(decode[10])? file_reg_B[decode[9:5]] : file_reg_A[decode[4:0]];  //load opp1 w regB or A depending on decode[21]
               
            end
            1'b1: //immidiate
            begin
                opperand1<= {{21{1'b0}}, decode[10:0]};  //upper 21 bits 0 for ld immideate value
            end
            default:
            begin
                opperand1<= {32{1'b0}};
            end
        endcase
        
          case (decode[22])//Destination type bit
            1'b0: //reg
            begin
                opperand2<=(decode[21])? file_reg_B[decode[20:16]] : file_reg_A[decode[15:11]];
            end
            1'b1: //mem
            begin
                opperand2<= {32{1'b0}};  
            end
            default:
            begin
                opperand2<= {32{1'b0}};
            end
        endcase
    end  
    
    //Execute - Take decode info and execute (or grab additional info from memory)
    always @(posedge clk) begin : EXECUTE
        execute <= instruction_fetch;
    end
    
    //Mem - Access memory if needed
    always @(posedge clk) begin : MEM
        mem <= instruction_fetch;
    end
    
    //Write 
    always @(posedge clk) begin : WB
        write_back <= instruction_fetch;
    end
    
    assign read_mem = 1;
    assign write_mem = 1;
    assign mem_radrs = pc_cnt;
    
endmodule