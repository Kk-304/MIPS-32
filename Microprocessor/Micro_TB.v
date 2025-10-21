module Micro_TB;

reg clk1, clk2;
integer k;

Main DUT(clk1,clk2);

// Initilise a dual phase clock
initial begin
    clk1 = 0;
    forever #5 clk1 = ~clk1;
end

initial begin
    clk2 = 0;
    #5; // phase shift
    forever #5 clk2 = ~clk2;
end

// Initializing a Register block via for loop
initial begin

DUT.PC = 0;
DUT.HALTED = 0;
DUT.TAKEN_BRANCH = 0;

DUT.Memory[0] = 32'h2801000a; // ADDI R1,R0,10
DUT.Memory[1] = 32'h28020014; // ADDI R2,R0,20
DUT.Memory[2] = 32'h28030019; // ADDI R3,R0,25
DUT.Memory[3] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[4] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[5] = 32'h00222000; // ADD R4,R1,R2 
DUT.Memory[6] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[7] = 32'h00832800; // ADD R5,R4,R3
DUT.Memory[8] = 32'hfc000000; // HLT

#290 for(k = 0; k < 6; k++) 
    $display("R%1d - %2d",k,DUT.Register[k]);

$finish;
end
endmodule