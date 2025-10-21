`timescale 1ns / 1ps

module Main(input clk1, input clk2);
reg[31:0] PC, IF_ID_NPC, IF_ID_IR;
reg[31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
reg[2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
reg[31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
reg EX_MEM_cond;
reg[31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;

reg [31:0] Register [0:31]; // Register bank
initial Register[0] = 32'h00000000; // R0 always stores 0 value
reg [31:0] Memory [0:1023]; // (1024*32) bit Memory

parameter ADD=6'b000000, SUB=6'b000001, AND=6'b000010, OR=6'b000011, SLT=6'b000100, MUL=6'b000101, HLT=6'b111111;
parameter LW=6'b001000, SW=6'b001001, ADDI=6'b001010, SUBI=6'b001011, SLTI=6'b001100, BNEQZ=6'b001101, BNQZ=6'b001110;
parameter RR_ALU=3'b000, RM_ALU=3'b001, LOAD=3'b010, STORE=3'b011, BRANCH=3'b100, HALT=3'b101;
reg HALTED;
reg TAKEN_BRANCH;       

// 1st stage IF
always@(posedge clk1) begin
if(HALTED == 0) begin
if(((EX_MEM_IR[31:26] == BNQZ) && (EX_MEM_cond == 1)) || ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0))) begin // Branch
IF_ID_IR <= #2 Memory[EX_MEM_ALUOut];
TAKEN_BRANCH <= #2 1'b1;
IF_ID_NPC <= #2 EX_MEM_ALUOut + 1;
PC <= #2 EX_MEM_ALUOut + 1;
end
else begin //Normal case
IF_ID_IR <= Memory[PC];
PC <= PC + 1;
IF_ID_NPC <= PC + 1;
end
end
end

// 2nd stage ID
always@(posedge clk2) begin
if(HALTED == 0) begin
ID_EX_A <= Register[IF_ID_IR[25:21]];
ID_EX_B <= Register[IF_ID_IR[20:16]];
ID_EX_NPC <= IF_ID_NPC;
ID_EX_IR <= IF_ID_IR;
ID_EX_Imm <= {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};
case(IF_ID_IR[31:26])
    ADD, SUB, AND, OR, MUL, SLT: ID_EX_type <= RR_ALU;
    ADDI, SUBI, SLTI: ID_EX_type <= RM_ALU;
    LW: ID_EX_type <= LOAD;
    SW: ID_EX_type <= STORE;
    BNQZ, BNEQZ: ID_EX_type <= BRANCH;
    HLT: ID_EX_type <= HALT;
    default: ID_EX_type <= HALT; //Invalid Opcode defaults to halt instruction
endcase
end
end

// 3rd stage EX
always@(posedge clk1) begin
if(HALTED == 0) begin
EX_MEM_type <= ID_EX_type;
EX_MEM_IR <= ID_EX_IR;
TAKEN_BRANCH <= 0;
case(ID_EX_type)
RR_ALU: case (ID_EX_IR[31:26])
    ADD: EX_MEM_ALUOut <= ID_EX_A + ID_EX_B;
    SUB: EX_MEM_ALUOut <= ID_EX_A - ID_EX_B;
    AND: EX_MEM_ALUOut <= ID_EX_A & ID_EX_B;
    OR: EX_MEM_ALUOut <= ID_EX_A | ID_EX_B;
    SLT: EX_MEM_ALUOut <= ID_EX_A < ID_EX_B; // Bitwise comparison or XOR
    MUL: EX_MEM_ALUOut <= ID_EX_A * ID_EX_B;
    default: EX_MEM_ALUOut <= 32'hxxxxxxxx;
    endcase
RM_ALU: case (ID_EX_IR[31:26])
    ADDI: EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
    SUBI: EX_MEM_ALUOut <= ID_EX_A - ID_EX_Imm;
    SLTI: EX_MEM_ALUOut <= ID_EX_A < ID_EX_Imm;
    default: EX_MEM_ALUOut <= 32'hxxxxxxxx;
    endcase
LOAD, STORE: begin
    EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
    EX_MEM_B <= ID_EX_B;
    end
BRANCH: begin
    EX_MEM_ALUOut <= ID_EX_NPC + ID_EX_Imm;
    EX_MEM_cond <= (ID_EX_A == 0);
    end
endcase
end
end

// 4th stage MEM
always@(posedge clk2) begin
if(HALTED == 0) begin
MEM_WB_type = EX_MEM_type;
MEM_WB_IR = EX_MEM_IR;
case(EX_MEM_type)
    RM_ALU, RR_ALU: MEM_WB_ALUOut <= EX_MEM_ALUOut;
    LOAD: MEM_WB_LMD <= Memory[EX_MEM_ALUOut];
    STORE: if(TAKEN_BRANCH == 0) Memory[EX_MEM_ALUOut] <= EX_MEM_B; // Disable write if branch instruction is active
endcase
end
end

// 5th stage WB
always@(posedge clk1) begin
if(TAKEN_BRANCH == 0) begin // Disable write if branch instruction is active
case (MEM_WB_type)
    RM_ALU: Register[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut;
    RR_ALU: Register[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut;
    LOAD: Register[MEM_WB_IR[20:16]] <= MEM_WB_LMD;
    HALT: HALTED <= 1'b1;
endcase
end
end

endmodule