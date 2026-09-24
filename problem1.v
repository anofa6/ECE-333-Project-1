module one_bit_full_adder(A, B, Cin, S, Cout);
  
  input A, B, Cin;
  output S, Cout;
  
  S = A ^ B ^ Cin;
  Cout = A*B + B*Cin * A*Cin;
  
endmodule
