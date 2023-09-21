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
    
    reg [31:0] decode;          //Stores the information being decoded
    reg [31:0] execute;
    reg [31:0] mem;
    reg [31:0] write_back;
    reg [10:0] pc_cnt;          //Stores program count
    
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


    //Decode - Load fetched command to be decoded
    always @(posedge clk) begin : DEC
        decode <= instruction_fetch;
    end
    
    //Execute - Take decode info and execute (or grab additional info from memory)
    always @(posedge clk) begin : EXE
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