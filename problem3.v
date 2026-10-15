// 3a. Design a 16-bit parallel prefix adder.
module PPA(A, B, Cin, S, Cout);

  input [15:0] A, B;
  input Cin;
  output [15:0] S;
  output Cout;

  // Index 0 is Cin. Indices 1-16 are bits 0-15.
  // The first index is the stage.
  wire [16:0] P [0:4];
  wire [16:0] G [0:4];

  wire [15:0] AxorB;
  wire carry15;

  assign P[0][0] = 1'b0;
  assign G[0][0] = Cin;

  // Calculate P, G, and A xor B for each bit.
  genvar bit_num;
  generate
    for (bit_num = 0; bit_num < 16; bit_num = bit_num + 1) begin : pre
      or  p_gate(P[0][bit_num + 1], A[bit_num], B[bit_num]);
      and g_gate(G[0][bit_num + 1], A[bit_num], B[bit_num]);
      xor x_gate(AxorB[bit_num], A[bit_num], B[bit_num]);
    end
  endgenerate

  // Combine P and G through 4 stages.
  genvar stage, i;
  generate
    for (stage = 0; stage < 4; stage = stage + 1) begin : levels
      localparam DIST = (1 << stage);

      for (i = 0; i < 17; i = i + 1) begin : nodes

        // Combine the upper half with the end of the lower half.
        if ((i % (2 * DIST)) >= DIST) begin : combine
          localparam LOWER = (i / (2 * DIST)) * (2 * DIST)
                             + DIST - 1;

          wire carry_term;

          and p_gate(P[stage + 1][i],
                     P[stage][i], P[stage][LOWER]);

          and carry_gate(carry_term,
                         P[stage][i], G[stage][LOWER]);

          or g_gate(G[stage + 1][i],
                    G[stage][i], carry_term);

        end else begin : pass_through
          assign P[stage + 1][i] = P[stage][i];
          assign G[stage + 1][i] = G[stage][i];
        end
      end
    end
  endgenerate

  // Calculate each sum bit using its carry-in.
  genvar sum_bit;
  generate
    for (sum_bit = 0; sum_bit < 16; sum_bit = sum_bit + 1) begin : sums
      xor sum_gate(S[sum_bit], AxorB[sum_bit], G[4][sum_bit]);
    end
  endgenerate

  // Calculate Cout using bit 15 and its carry-in.
  and last_carry(carry15, P[0][16], G[4][15]);
  or  cout_gate(Cout, G[0][16], carry15);

endmodule