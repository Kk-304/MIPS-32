module Factorial_TB;

reg clk1,clk2;
integer Factor;

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

if(!$value$plusargs("Val=%d",Factor)) begin
    $display("ERROR: No value passed");
    $finish;
end

DUT.PC = 0;
DUT.HALTED = 0;
DUT.TAKEN_BRANCH = 0;

DUT.Memory[200] = Factor; // Taking input from the user
DUT.Memory[0] = 32'h280a00c8; // ADDI R10,R0,200
DUT.Memory[1] = 32'h28020001; // ADDI R2,R0,1
DUT.Memory[2] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[3] = 32'h21430000; // LW R3,0(R10)
DUT.Memory[4] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[5] = 32'h14431000; // Loop: MUL R2,R2,R3
DUT.Memory[6] = 32'h2c630001; // SUBI R3,R3,1
DUT.Memory[7] = 32'h0ce77800; // OR R7,R7,R7 --- Dummy instruction
DUT.Memory[8] = 32'h3460fffc; // BNEQZ R3,Loop
DUT.Memory[9] = 32'h2542fffe; // SW R2,-2(R10)
DUT.Memory[10] = 32'hfc000000; // HALT

$monitor("R2 = %4d",DUT.Register[2]);
wait(DUT.HALTED) $display ("Mem[200] : %d \nMem[198] : %d",DUT.Memory[200],DUT.Memory[198]);

$finish;
end
endmodule