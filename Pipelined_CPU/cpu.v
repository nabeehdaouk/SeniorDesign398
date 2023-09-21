module cpu(
    input clk,                          //Clock for CPU
    input reset,                        //Global reset signal
    input [31:0] instruction_fetch,     //Instruction fetched from memory
    output carry,                       //Carry from addition or subtraction
    output [31:0] result,               //Result (either sent to mem, or just as an output)
    output [10:0] pc_wadrs              //Write address to write to memory
);

    localparam LOAD = 3'b111;
    localparam STORE = 3'b110;
    localparam BRANCH = 3'b101;
    localparam ADD = 3'b100;
    localparam SUBTRACT = 3'b011;
    localparam AND = 3'b010;
    localparam OR = 3'b001;
    localparam NOOP = 3'b000;

    
    reg [31:0] decode; //Stores the information being decoded
    wire [10:0] branch_address; //Defines branch address, only taken if valid
    wire branch_valid; //Defines if the branch was valid or not
    wire program_status; //Defines the program status used for branches
    reg src_type; //Source type (reg == 0, immediate == 1)
    reg dest_type; //Destination type (reg == 0, memory == 1)
    reg [2:0] opcode_type; //Opcode type
    
    psr program_status_register(
        .res(result),
        .carry(carry),
        .program_status(program_status)
    );

    pc program_counter(
        .clk(clk),
        .reset(reset),
        .branch_valid(branch_valid),
        .branch_address(branch_address),
        .cnt(pc_wadrs)
    ); 


    //Fetch - Load fetched command to be decoded
    always @(posedge clk) begin : Fetch
        decode <= instruction_fetch;
    end

    //Decode - Take fetched information and decode it
    always @(posedge clk) begin : Decode
        src_type <= decode[23]; //Set source type (reg == 0, immediate == 1)
        dest_type <= decode[22]; //Set destination type (reg == 0, memory == 1) 
    end
    
    //Execute - Take decode info and execute (or grab additional info from memory)
    
    //Mem - Access memory if needed
    
    //Write 
    
endmodule