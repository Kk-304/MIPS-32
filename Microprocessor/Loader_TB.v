module Loader_TB;

reg clk1,clk2;

// Initializing both clks
initial begin
clk1 = 0;
forever #5clk1 = ~clk1;
end
initial begin
clk2 = 0;
#5;
forever #5clk2 = ~clk2;
end

Main DUT(clk1,clk2);

initial begin

DUT.PC = 0;
DUT.HALTED = 0;
DUT.TAKEN_BRANCH = 0;

DUT.Memory[120] = 17; // stored it with value 17
DUT.Memory[0] = 32'h28010078; // R1 = R0+120
DUT.Memory[1] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[2] = 32'h20220000; // LW R2,0(R1)
DUT.Memory[3] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[4] = 32'h2842002d; // ADDI R2,R2,45
DUT.Memory[5] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[6] = 32'h24220001; // SW R2,1(R1)
DUT.Memory[7] = 32'hfc000000; // HALT

#270 $display ("Mem[120] : %4d \nMem[121] : %4d",DUT.Memory[120],DUT.Memory[121]);

$finish;
end
endmodule