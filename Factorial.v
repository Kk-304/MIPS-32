`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2024 14:55:55
// Design Name: 
// Module Name: Factorial
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Factorial;
reg [31:0] k;
reg done;
Datapath test();
initial begin
test.PC = 0;
test.HALTED = 0;
test.TAKEN_BRANCH = 0;
test.Memory[200] = 3;
test.Memory[0] = 32'h280a00c8; // R10 = 100
test.Memory[1] = 32'h28020001; // R2 = 1
test.Memory[2] = 32'h0e94a000; // dummy inst
test.Memory[3] = 32'h21430000; // Load Mem(R10)
test.Memory[4] = 32'h0e94a000; // dummy inst
test.Memory[5] = 32'h0e94a000; // Multiply
test.Memory[6] = 32'h2c630001; // SubI
test.Memory[7] = 32'h0e94a000; // dummy inst
test.Memory[8] = 32'h3460fffc; // -4 offset to go 3 places back
test.Memory[9] = 32'h2542fffe; // Store R2 in Mem[198]
test.Memory[10] = 32'hfc000000; // Halt
forever begin
k <= test.Register[2];
done <= test.HALTED;
end
end
endmodule
