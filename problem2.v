// b. Design a 1-bit full-adder in Verilog using structural modeling. Assume that the inputs are A, B, and Cin, and outputs are S, 
// Cout. Use the module template of Figure 1(a).
module one_bit_full_adder_s(A, B, Cin, S, Cout);
  
  input A, B, Cin;
  output S, Cout;
  
  wire and_AB;
  wire and_BCin;
  wire and_ACin;
  
  xor XOR1(S, A, B, Cin);
  
  and AND1(and_AB, A, B);
  and AND2(and_BCin, B, Cin);
  and AND3(and_ACin, A, Cin);
  
  or OR1(Cout, and_AB, and_BCin, and_ACin);
  
endmodule

// c. Using the 1-bit full adder from either Part (a) or Part (b), design a 4-bit Ripple-Carry Adder (RCA). Use 
// the module template of 1(b). 
module four_bit_RCA(A, B, Cin, S, Cout);
  input [3:0] A, B;
  input Cin;
  output [3:0] S;
  output Cout;
  
  wire Cin1, Cin2, Cin3, Cin4;
  wire [3:0] P, G, C;
  
  one_bit_full_adder_s add0(A[0], B[0], Cin, S[0], Cin1);
  one_bit_full_adder_s add1(A[1], B[1], Cin1, S[1], Cin2);
  one_bit_full_adder_s add2(A[2], B[2], Cin2, S[2], Cin3);
  one_bit_full_adder_s add3(A[3], B[3], Cin3, S[3], Cin4);
  
  assign G = A & B;
  assign P = A | B;
  assign C[0] = G[0] | P[0] & Cin;
  assign C[1] = G[1] | P[1] & C[0];
  assign C[2] = G[2] | P[2] & C[1];
  assign Cout = G[3] + P[3] * C[2];
    
endmodule

// 2a. Design a 32-bit Carry Lookahead Adder (CLA) using a block size of four (4). Assume that the inputs are A[31:0], B[31:0], and Cin, and outputs are S[31:0], 
// Cout. Use the 4-bit full adder (RCA) that you designed in Problem 1 as the component. You can only use 2-input AND and OR gates to construct the carry 
// propagation and carry generate logic. No need to include subtraction operation for the CLA. Use the CLA module template of Figure 2(a).
module CLA(A, B, Cin, S, Cout);

  input [31:0] A, B;
  input Cin;
  output [31:0] S;
  output Cout;
  
  wire Cin1, Cin2, Cin3, Cin4, Cin5, Cin6, Cin7, Cin8;
  wire [31:0] P, G;
  wire [7:0] BP, BG, C;
  
  four_bit_RCA add0(A[3:0],   B[3:0],   Cin,  S[3:0],   Cin1);
  four_bit_RCA add1(A[7:4],   B[7:4],   C[0], S[7:4],   Cin2);
  four_bit_RCA add2(A[11:8],  B[11:8],  C[1], S[11:8],  Cin3);
  four_bit_RCA add3(A[15:12], B[15:12], C[2], S[15:12], Cin4);
  four_bit_RCA add4(A[19:16], B[19:16], C[3], S[19:16], Cin5);
  four_bit_RCA add5(A[23:20], B[23:20], C[4], S[23:20], Cin6);
  four_bit_RCA add6(A[27:24], B[27:24], C[5], S[27:24], Cin7);
  four_bit_RCA add7(A[31:28], B[31:28], C[6], S[31:28], Cin8);
  
  assign G = A & B;
  assign P = A | B;
  
  assign BP[0] = P[3]  & P[2]  & P[1]  & P[0];
  assign BP[1] = P[7]  & P[6]  & P[5]  & P[4];
  assign BP[2] = P[11] & P[10] & P[9]  & P[8];
  assign BP[3] = P[15] & P[14] & P[13] & P[12];
  assign BP[4] = P[19] & P[18] & P[17] & P[16];
  assign BP[5] = P[23] & P[22] & P[21] & P[20];
  assign BP[6] = P[27] & P[26] & P[25] & P[24];
  assign BP[7] = P[31] & P[30] & P[29] & P[28];
  
  assign BG[0] = G[3]  | P[3]  & G[2]  | P[3]  & P[2]  & G[1]  | P[3]  & P[2]  & P[1]  & G[0];
  assign BG[1] = G[7]  | P[7]  & G[6]  | P[7]  & P[6]  & G[5]  | P[7]  & P[6]  & P[5]  & G[4];
  assign BG[2] = G[11] | P[11] & G[10] | P[11] & P[10] & G[9]  | P[11] & P[10] & P[9]  & G[8];
  assign BG[3] = G[15] | P[15] & G[14] | P[15] & P[14] & G[13] | P[15] & P[14] & P[13] & G[12];
  assign BG[4] = G[19] | P[19] & G[18] | P[19] & P[18] & G[17] | P[19] & P[18] & P[17] & G[16];
  assign BG[5] = G[23] | P[23] & G[22] | P[23] & P[22] & G[21] | P[23] & P[22] & P[21] & G[20];
  assign BG[6] = G[27] | P[27] & G[26] | P[27] & P[26] & G[25] | P[27] & P[26] & P[25] & G[24];
  assign BG[7] = G[31] | P[31] & G[30] | P[31] & P[30] & G[29] | P[31] & P[30] & P[29] & G[28];

  assign C[0] = BG[0] | BP[0] & Cin;
  assign C[1] = BG[1] | BP[1] & BG[0] | BP[1] & BP[0] & Cin;
  assign C[2] = BG[2] | BP[2] & BG[1] | BP[2] & BP[1] & BG[0]
              | BP[2] & BP[1] & BP[0] & Cin;
  assign C[3] = BG[3] | BP[3] & BG[2] | BP[3] & BP[2] & BG[1]
              | BP[3] & BP[2] & BP[1] & BG[0]
              | BP[3] & BP[2] & BP[1] & BP[0] & Cin;
  assign C[4] = BG[4] | BP[4] & BG[3] | BP[4] & BP[3] & BG[2]
              | BP[4] & BP[3] & BP[2] & BG[1]
              | BP[4] & BP[3] & BP[2] & BP[1] & BG[0]
              | BP[4] & BP[3] & BP[2] & BP[1] & BP[0] & Cin;
  assign C[5] = BG[5] | BP[5] & BG[4] | BP[5] & BP[4] & BG[3]
              | BP[5] & BP[4] & BP[3] & BG[2]
              | BP[5] & BP[4] & BP[3] & BP[2] & BG[1]
              | BP[5] & BP[4] & BP[3] & BP[2] & BP[1] & BG[0]
              | BP[5] & BP[4] & BP[3] & BP[2] & BP[1] & BP[0] & Cin;
  assign C[6] = BG[6] | BP[6] & BG[5] | BP[6] & BP[5] & BG[4]
              | BP[6] & BP[5] & BP[4] & BG[3]
              | BP[6] & BP[5] & BP[4] & BP[3] & BG[2]
              | BP[6] & BP[5] & BP[4] & BP[3] & BP[2] & BG[1]
              | BP[6] & BP[5] & BP[4] & BP[3] & BP[2] & BP[1] & BG[0]
              | BP[6] & BP[5] & BP[4] & BP[3] & BP[2] & BP[1] & BP[0] & Cin;
  assign C[7] = BG[7] | BP[7] & BG[6] | BP[7] & BP[6] & BG[5]
              | BP[7] & BP[6] & BP[5] & BG[4]
              | BP[7] & BP[6] & BP[5] & BP[4] & BG[3]
              | BP[7] & BP[6] & BP[5] & BP[4] & BP[3] & BG[2]
              | BP[7] & BP[6] & BP[5] & BP[4] & BP[3] & BP[2] & BG[1]
              | BP[7] & BP[6] & BP[5] & BP[4] & BP[3] & BP[2] & BP[1] & BG[0]
              | BP[7] & BP[6] & BP[5] & BP[4] & BP[3] & BP[2] & BP[1] & BP[0] & Cin;
  
  assign Cout = C[7];

endmodule

//2b. Enhance the 4-bit RCA/RCS testbench of Problem 1(e) to test the 32-bit CLA.
//In addition to the previous types of test cases, include at least one test case
//that requires carry propagation across multiple 4-bit blocks. 
module testbench;
  reg [31:0] A, B;
  reg Sub;
  wire [31:0] S;
  wire Cout;
  
  initial begin    
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
    $display ("time\t Sub\t A\t\t B\t\t Cout\t S");
    $monitor ("%g\t %b\t %h\t %h\t %b\t %h", $time, Sub, A, B, Cout, S);
    Sub = 1'b0;			// Add
    A = 32'd100;		// 100
    B = 32'd200; 		// 200
    #5;					// Expected Output: 300
    Sub = 1'b1;			// Subtract
    A = 32'd1000; 		// 1000
    B = 32'd400;		// 400
    #5;					// Expected Output: 600
    Sub = 1'b0;			// Add
    A = 32'd50;			// 50
    B = 32'hFFFFFFEC;	// -20
    #5;					// Expected Output: 30
    Sub = 1'b1;			// Subtract
    A = 32'd50;			// 50
    B = 32'hFFFFFFEC;	// -20
    #5;					// Expected Output: 70
    Sub = 1'b0;			// Add
    A = 32'hFFFFFFFF;	// 4294967295
    B = 32'hFFFFFFFF;	// 4294967295
    #5;					// Expected Output: Cout = 1
    Sub = 1'b0;			// Add
    A = 32'hFFFFFFFF;	// 4294967295
    B = 32'd1;			// 1
    #5;					// Expected Output: 0, Cout = 1
    Sub = 1'b0;			// Add
    A = 32'h0000FFFF;	// 65535
    B = 32'd1;			// 1
    #5;					// Expected Output: 65536
    Sub = 1'b1;			// Subtract
    A = 32'h10000000;	// 268435456
    B = 32'd1;			// 1
    #5 $finish;			// Expected Output: 268435455
  end
  
  CLA add0(A, B ^ {32{Sub}}, Sub, S, Cout);
endmodule
