// a. Design a 1-bit full-adder in Verilog using behavioral modeling. Assume that the inputs are A, B, and Cin, and outputs are S, Cout. Use the module template of Figure 1(a). 
module one_bit_full_adder_b(A, B, Cin, S, Cout);
  
 	input A, B, Cin;
	output S, Cout;
  
  	assign S = A + B;
 	assign Cout = A*B + B*Cin + A*Cin;
  
endmodule

// b. Design a 1-bit full-adder in Verilog using structural modeling. Assume that the inputs are A, B, and Cin, and outputs are S, Cout. Use the module template of Figure 1(a).
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

// c. Using the 1-bit full adder from either Part (a) or Part (b), design a 4-bit Ripple-Carry Adder (RCA). Use the module template of 1(b). 
module four_bit_RCA(A, B, Cin, S,
Cout);
  input [3:0] A, B;
  input Cin;
  output [3:0] S;
  output Cout;
  
  wire Cin1, Cin2, Cin3, Cin4;
  wire [3:0] P, G;
  
  one_bit_full_adder_s add0(A[0], B[0], Cin, S[0], Cin1);
  one_bit_full_adder_s add1(A[1], B[1], Cin, S[1], Cin2);
  one_bit_full_adder_s add2(A[2], B[2], Cin, S[2], Cin3);
  one_bit_full_adder_s add3(A[3], B[3], Cin, S[3], Cin4);
  
  assign G = A * B;
  assign P = A + B;
  
endmodule
