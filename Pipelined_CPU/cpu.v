module cpu(
    input clk,                          //Clock for CPU
    input resetn,                       //Global reset signal
    input [31:0] instruction_fetch,     //Instruction fetched from memory
    input [31:0] mem_store_data,        //Data read from memory that will be stored
    output read_mem_ir,                 //Read enable for reading instructions
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
    reg [31:0] mem_result;
    reg execute_carry;
    
    reg [10:0] branch_address;  //Defines branch address, only taken if valid
    reg branch_valid;           //Defines if the branch was valid or not
    wire [4:0] program_status;  //Defines the program status used for branches  
      
    
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
        if(!branch_valid) begin
            decode <= instruction_fetch;
        end
        else begin
            decode <= {32{1'b0}}; 
        end
    end
    
    //Decode - Decode instruction, get any operands from file regs
    always @(posedge clk) begin : DECODE
        if(!branch_valid) begin
            execute <= decode;
            
            //Decode source
            if(decode[23]) begin
                operand1 <= {{21{1'b0}}, decode[10:0]};  //upper 21 bits 0 for ld immideate value
            end else begin
                operand1 <= (decode[10]) ? file_reg_B[decode[9:5]] : file_reg_A[decode[4:0]];  //load opp1 w regB or A depending on decode[21] 
            end
            
            //Decode destination
            if(decode[22]) begin
                operand2 <= {32{1'b0}};  
            end else begin
                operand2 <= (decode[21]) ? file_reg_B[decode[20:16]] : file_reg_A[decode[15:11]];
            end
        end
        else begin
           operand1 <= {32{1'b0}};  
           operand2 <= {32{1'b0}};  
        end       
    end
    
   
    //Execute - Take decode info and execute (or grab additional info from memory)
    always @(posedge clk) begin : EXECUTE
        if(!branch_valid) begin
        
            mem <= execute;
            mem_result <= execute_result;
            
            case(execute[31:29])
                
                BRANCH: begin
                    case(execute[26:24])
                        3'b111: begin                               //not-zero
                            if (program_status[2] == 1'b0) begin
                                branch_address <= execute[21:11];
                                branch_valid <= 1'b1;
                            end
                        end
                        3'b110: begin                               //even
                            if (program_status[0] == 1'b0) begin
                                branch_address <= execute[21:11];
                                branch_valid <= 1'b1;
                            end
                        end
                        3'b101: begin                               //positive
                            if (program_status[3] == 1'b1) begin
                                branch_address <= execute[21:11];
                                branch_valid <= 1'b1;
                                end
                        end
                        3'b100: begin                               //zero
                            if (program_status[2] == 1'b1) begin
                                branch_address <= execute[21:11];
                                branch_valid <= 1'b1;
                            end
                        end
                        3'b011: begin                               //no carry
                            if (program_status[4] == 1'b0) begin
                                branch_address <= execute[21:11];
                                branch_valid <= 1'b1;
                            end
                        end
                        3'b010: begin                               //parity even
                            if (program_status[0] == 1'b0) begin
                                branch_address <= execute[21:11];
                                branch_valid <= 1'b1;
                            end
                        end
                        3'b001: begin                               //parity odd
                            if (program_status[0] == 1'b1) begin
                                branch_address <= execute[21:11];
                                branch_valid <= 1'b1;
                            end
                        end
                        3'b000: begin                               //always
                            branch_address <= execute[21:11];
                            branch_valid <= 1'b1;
                        end
                        default: begin
                            branch_address <= 0;
                            branch_valid <= 0;
                        end
                    endcase
                end
                        
                ADD: {carry,execute_result} <= operand1 + operand2; 
                
                SUBTRACT: begin
                    execute_result <= operand1 - operand2;
                    execute_carry <= 1'b0;
                    branch_address <= 0;
                    branch_valid <= 0;
                end
                
                AND: begin
                    execute_result <= operand1 & operand2;
                    execute_carry <= 1'b0;
                    branch_address <= 0;
                    branch_valid <= 0;
                end 
                
                OR: begin
                    execute_result <= operand1 | operand2;
                    execute_carry <= 1'b0;
                    branch_address <= 0;
                    branch_valid <= 0;
                end
                
                NOOP: begin
                    execute_result <= 0;
                    execute_carry <= 1'b0; //set carry to 0
                    branch_address <= 0;
                    branch_valid <= 0;
                end 
                
                default: begin
                    execute_result <= 0;
                    execute_carry <= 1'b0;
                    branch_address <= 0;
                    branch_valid <= 0;
                end // set result to 0 and set carry to 0
                
            endcase
        end
        else begin
            execute_result <= 0;
            execute_carry <= 1'b0;
            branch_address <= 0;
            branch_valid <= 0;    
        end
        
    end

    
    //Mem - Access memory if needed (LOAD - get operand from memory, STORE - Store operand to memory)
    always @(posedge clk) begin : MEM
        write_back <= mem;
        
        if(mem[31:29] == LOAD) begin //LOAD from memory to reg, get memory operand as read from memory
            read_mem_str <= 1;
            mem_radrs_LD <= mem[10:0];
            write_mem <= 0;
        end
        else if(mem[31:29] == STORE) begin //Store into memory, set write, w_adrs, and wdata
            write_mem <= 1;
            mem_wadrs <= mem[21:11];
            mem_wdata <= mem_result;
            read_mem_str <= 0;
        end 
        else begin
            write_mem <= 0; 
            read_mem_str <= 0;
        end
           
    end
    
    //Write 
    always @(posedge clk) begin : WB
        if(write_back[31:29] == LOAD) begin
            if(write_back[10]) begin
                file_reg_A[write_back[9:5]] <= mem_store_data;  
            end
            else begin
                file_reg_A[write_back[4:0]] <= mem_store_data;  
            end
        end
        result <= mem_result;
    end

    assign mem_radrs_ir = pc_cnt;
    assign read_mem_ir = 1'b1;
    
endmodule