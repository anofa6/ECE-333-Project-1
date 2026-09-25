// a. Design a 1-bit full-adder in Verilog using behavioral modeling. Assume that the inputs are A, B, and Cin, and outputs are S, Cout. 
// Use the module template of Figure 1(a). 
module one_bit_full_adder_b(A, B, Cin, S, Cout);
  
 	input A, B, Cin;
	output S, Cout;
  
  	assign S = A ^ B ^ Cin;
 	assign Cout = A & B | B & Cin | A & Cin;
  
endmodule

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

// d. Enhance the 4-bit RCA of Part (c) to construct 4-bit Ripple-Carry Subtractor (RCS). Use the module template of 1(b).
module four_bit_RCA_RCS(A, B, Sub, S, Cout);
  input [3:0] A, B;
  input Sub;
  output [3:0] S;
  output Cout;
  
  wire [3:0] Cn, P, G, C;
  
  one_bit_full_adder_s add0(A[0], B[0] ^ Sub, Sub, S[0], Cn[0]);
  one_bit_full_adder_s add1(A[1], B[1] ^ Sub, Cn[0], S[1], Cn[1]);
  one_bit_full_adder_s add2(A[2], B[2] ^ Sub, Cn[1], S[2], Cn[2]);
  one_bit_full_adder_s add3(A[3], B[3] ^ Sub, Cn[2], S[3], Cn[3]);
  
  assign G = A & B;
  assign P = A | B;
  assign C[0] = G[0] | P[0] & Sub;
  assign C[1] = G[1] | P[1] & C[0];
  assign C[2] = G[2] | P[2] & C[1];
  assign Cout = G[3] + P[3] * C[2];
    
endmodule
