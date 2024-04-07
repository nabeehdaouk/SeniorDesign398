module cpu(
    input clk,                          //Clock for CPU
    input resetn,                       //Global reset signal
    input [31:0] instruction_fetch,     //Instruction fetched from memory
    input [31:0] mem_load_data,         //Data read from memory that will be loaded
    input read_load_valid,              //State we read from memory sucessfully
    input write_store_valid,            //States store instruction was valid 
    input fifo_empty,                   //States the fifo is empty
    output reg branch_valid,            //States branch was valid
    output reg read_mem_load,           //Read enable for reading for a load
    output reg [10:0] branch_address,   //Defines branch address, only taken if valid
    output reg write_mem,               //Write enable to memory
    output reg carry,                   //Carry from addition or subtraction
    output reg [31:0] result,           //Result (either sent to mem, or just as an output)
    output reg [31:0] mem_wdata,        //Used for STORE instruction, information to be stored in memory
    output reg [10:0] mem_wadrs,        //Write address to memory
    output reg [10:0] mem_radrs_ld,     //Read address to read from memoroy used for load instructions
    output read_fifo                    //States fifo should be read
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
    
    reg [31:0] file_reg_A [31:0];
    reg [31:0] file_reg_B [31:0];
    reg [31:0] operand1;
    reg [31:0] operand2;
    reg [31:0] execute_result;
    reg [31:0] wb_result;
    reg execute_carry;
    reg mem_carry;
    reg stall_pipe;              //This is used when accessing memory to stall pipeline
    reg [31:0] mem_load_data1;
    reg [31:0] mem_load_data2;
    
    
    wire [4:0] program_status;  //Defines the program status used for branches  
    
    integer i;                  //For reset of file regs
      
    
    psr program_status_register(
        .res(result),
        .carry(carry),
        .program_status(program_status)
    );

    always @(posedge clk) begin
        mem_load_data1<= mem_load_data;
        mem_load_data2<= mem_load_data1;
    end
    
    //Fetch - Load fetched command to be decoded
    always @(posedge clk) begin : FETCH
        if(!resetn) begin
           decode <=  0;
        end
        else if(!branch_valid && !stall_pipe) begin
            decode <= instruction_fetch;
        end
        else if(!stall_pipe) begin
            decode <= 0; 
        end
    end
    
    //Decode - Decode instruction, get any operands from file regs
    always @(posedge clk) begin : DECODE
        if(!resetn) begin
           execute <= 0; 
           operand1 <= 0;
           operand2 <= 0;
        end
        else if(!branch_valid && !stall_pipe) begin
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
        else if(!stall_pipe) begin
            execute <= 0;
            operand1 <= 0;  
            operand2 <= 0;  
        end       
    end
    
   
    //Execute - Take decode info and execute (or grab additional info from memory)
    always @(posedge clk) begin : EXECUTE
        if(!resetn) begin
            mem <= 0;
            branch_address <= 0;
            branch_valid <= 0;
            execute_result <= 0;
            execute_carry <= 0;
            stall_pipe <= 0;
        end
        else if(!branch_valid && !stall_pipe) begin
        
            mem <= execute;
            
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
                    read_mem_load <= 0;
                    stall_pipe <= 0;
                    mem_wdata <= 0;
                    write_mem <= 0;
                    mem_wadrs <= 0;
                end
                        
                ADD: begin
                    {execute_carry,execute_result} <= operand1 + operand2; 
                    stall_pipe <= 0;
                    mem_wdata <= 0;
                    write_mem <= 0;
                    mem_wadrs <= 0;
                    branch_address <= 0;
                    branch_valid <= 0;
                    read_mem_load <= 0;
                end
                
                SUBTRACT: begin
                    mem_wdata <= 0;
                    write_mem <= 0;
                    mem_wadrs <= 0;
                    execute_result <= operand2 - operand1;
                    execute_carry <= 1'b0;
                    branch_address <= 0;
                    branch_valid <= 0;
                    read_mem_load <= 0;
                    stall_pipe <= 0;
                end
                
                AND: begin
                    mem_wdata <= 0;
                    write_mem <= 0;
                    mem_wadrs <= 0;
                    execute_result <= operand1 & operand2;
                    execute_carry <= 1'b0;
                    branch_address <= 0;
                    branch_valid <= 0;
                    read_mem_load <= 0;
                    stall_pipe <= 0;
                end 
                
                OR: begin
                    mem_wdata <= 0;
                    write_mem <= 0;
                    mem_wadrs <= 0;
                    execute_result <= operand1 | operand2;
                    execute_carry <= 1'b0;
                    branch_address <= 0;
                    branch_valid <= 0;
                    read_mem_load <= 0;
                    stall_pipe <= 0;
                end
                
                NOOP: begin
//                    mem_wdata <= 0;
//                    write_mem <= 0;
//                    mem_wadrs <= 0;
//                    execute_result <= 0;
//                    execute_carry <= 1'b0; //set carry to 0
//                    branch_address <= 0;
//                    branch_valid <= 0;
//                    read_mem_load <= 0;
//                    stall_pipe <= 0;
                end 
                
                LOAD : begin
                    mem_wdata <= 0;
                    write_mem <= 0;
                    mem_wadrs <= 0;
                    read_mem_load <= 1;
                    mem_radrs_ld <= execute[10:0];
                    execute_result <= 0;
                    execute_carry <= 1'b0; //set carry to 0
                    branch_address <= 0;
                    branch_valid <= 0;
                    stall_pipe <= 1;
                end
                
                STORE : begin
                    write_mem <= 1;
                    mem_wadrs <= execute[21:11];
                    if(execute[10]) begin
                        mem_wdata <= file_reg_B[execute[9:5]];
                    end 
                    else begin
                        mem_wdata <= file_reg_A[execute[4:0]];
                    end
                    execute_result <= 0;
                    execute_carry <= 1'b0; //set carry to 0
                    branch_address <= 0;
                    branch_valid <= 0;
                    stall_pipe <= 1; 
                end
                
                                
                default: begin
                    mem_wdata <= 0;
                    write_mem <= 0;
                    mem_wadrs <= 0;
                    execute_result <= 0;
                    execute_carry <= 1'b0;
                    branch_address <= 0;
                    branch_valid <= 0;
                    read_mem_load <= 0;
                    mem_radrs_ld <= 0;
                    stall_pipe <= 0;
                end // set result to 0 and set carry to 0
                
            endcase
        end
        else if(!stall_pipe) begin
            execute_result <= 0;
            execute_carry <= 1'b0;
            branch_address <= 0;
            branch_valid <= 0;  
            read_mem_load <= 0;
            mem_radrs_ld <= 0;  
            mem_wdata <= 0;
            write_mem <= 0;
            stall_pipe <= 0;
        end
        else if(stall_pipe) begin
            if(read_load_valid || write_store_valid) begin
                stall_pipe <= 0;
            end
            mem_wdata <= 0;
            write_mem <= 0;
            mem_wadrs <= 0; 
            read_mem_load <= 0;
            mem_radrs_ld <= 0;
        end
        
    end

    
    //Mem - Access memory if needed (LOAD - get operand from memory, STORE - Store operand to memory)
    //TODO : Load instruction should allow immediate value as source
    always @(posedge clk) begin : MEM
        if(!resetn) begin
            write_back <= 0;
            wb_result <= 0;
            mem_carry <= 0;
        end
        else if(!stall_pipe) begin
            write_back <= mem;
            if(mem[31:29] == STORE) begin //Store into reg, set write, w_adrs, and wdata
                wb_result <= file_reg_A[mem[4:0]];
                mem_carry <= 0;
            end 
            else begin
                wb_result <= execute_result;
                mem_carry <= execute_carry;
            end
        end
    end
    
    //Write - Write the result to a register
    //TODO : All Storage should happen here, for all opcodes not just LOAD
    always @(posedge clk) begin : WB
        if(!resetn) begin
            result <= 0; 
            carry <= 0;
            for(i = 0; i < 32; i = i + 1) begin
                file_reg_A[i] <= 0;
                file_reg_B[i] <= 0;  
            end
        end
        else if(write_back[31:29] == LOAD) begin
            if(write_back[21]) begin
                file_reg_B[write_back[20:16]] <= mem_load_data2;  
            end
            else begin
                file_reg_A[write_back[15:11]] <= mem_load_data2;  
            end
            result <= mem_load_data2;
            carry <= mem_carry;
        end
        else if((write_back[31:29] != STORE) & (write_back[31:29] != NOOP)) begin
             if(write_back[21]) begin
                file_reg_B[write_back[20:16]] <= wb_result;  
            end
            else begin
                file_reg_A[write_back[15:11]] <= wb_result;  
            end
            result <= wb_result; 
            carry <= mem_carry;  
        end
        else begin
            result <= wb_result;
            carry <= mem_carry;
        end
    end
    

    assign read_fifo = ~fifo_empty & ~stall_pipe; //Enable read from memory to FIFO when the
    
endmodule