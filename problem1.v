// Design a 1-bit full-adder in Verilog using behavioral modeling. Assume that the inputs are A, B, and Cin, and outputs are S, Cout. Use the module template of Figure 1(a). 
module one_bit_full_adder_b(A, B, Cin, S, Cout);
  
  input A, B, Cin;
  output S, Cout;
  
  S = A ^ B ^ Cin;
  Cout = A*B + B*Cin * A*Cin;
  
endmodule

// 1B One Bit Full Adder using Structural Modeling
module one_bit_full_adder_s(A, B, Cin, S, Cout);
  
  input A, B, Cin;
  output S, Cout;
  
  wire and_AB;
  wire and_BCin;
  wire and_ACin;
  
  XOR XOR1(S, A, B, Cin);
  
  AND AND1(and_AB, A, B);
  AND AND2(and_BCin, B, Cin);
  AND AND3(and_ACin, A, Cin);
  
  OR OR1(Cout, AND1, AND2, AND3);
  
endmodule

module four_bit_RCA_RCS(A, B, Cin, S,
Cout);
