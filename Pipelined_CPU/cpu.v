module cpu(
    input clk,                          //Clock for CPU
    input resetn,                       //Global reset signal
    input [31:0] instruction_fetch,     //Instruction fetched from memory
    input [31:0] mem_store_data,        //Data read from memory that will be stored
    output reg read_mem_ir,             //Read enable for reading instructions
    output reg read_mem_str,            //Read enable for reading for a store
    output reg write_mem,               //Write enable to memory
    output reg carry,                   //Carry from addition or subtraction
    output reg [31:0] result,           //Result (either sent to mem, or just as an output)
    output reg [31:0] mem_wdata,        //Used for STORE instruction, information to be stored in memory
    output reg [10:0] mem_wadrs,        //Write address to memory
    output reg [10:0] mem_radrs_LD,     //Read address to read from memoroy used for load instructions
    output [10:0] mem_radrs_ir          //Read address to read from memory used for fetching instructions
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
    reg [31:0] file_reg_B [31:0];
    reg [31:0] operand1;
    reg [31:0] operand2;
    reg [31:0] execute_result;
    
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
                operand1 <= (decode[10]) ? file_reg_B[decode[9:5]] : file_reg_A[decode[4:0]];  //load opp1 w regB or A depending on decode[21] 
            end
            1'b1: //immidiate
            begin
                operand1 <= {{21{1'b0}}, decode[10:0]};  //upper 21 bits 0 for ld immideate value
            end
            default:
            begin
                operand1 <= {32{1'b0}};
            end
        endcase
        
          case (decode[22])//Destination type bit
            1'b0: //reg
            begin
                operand2 <= (decode[21]) ? file_reg_B[decode[20:16]] : file_reg_A[decode[15:11]];
            end
            1'b1: //mem
            begin
                operand2<= {32{1'b0}};  
            end
            default:
            begin
                operand2<= {32{1'b0}};
            end
        endcase

    end
    
    //Execute - Take decode info and execute (or grab additional info from memory)
    always @(posedge clk) begin : EXECUTE
        mem <= execute;
    end
    
    //Mem - Access memory if needed (LOAD - get operand from memory, STORE - Store operand to memory)
    always @(posedge clk) begin : MEM
        write_back <= mem;
        
        if(mem[31:29] == LOAD) begin //LOAD from memory to reg, get memory operand as read from memory
            read_mem_str <= 1;
            mem_radrs_LD <= execute[10:0];
            write_mem <= 0;
        end
        else if(mem[31:29] == STORE) begin //Store into memory, set write, w_adrs, and wdata
            write_mem <= 1;
            mem_wadrs <= execute[21:11];
            mem_wdata <= execute_result;
            read_mem_str <= 0;
        end 
        else begin
            write_mem <= 0; 
            read_mem_str <= 0;
        end
           
    end
    
    //Write 
    always @(posedge clk) begin : WB
        
    end

    assign mem_radrs_ir = pc_cnt;
    
endmodule