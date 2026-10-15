module kogge_stone_adder_16bit (
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,
    output [15:0] S,
    output        Cout
);

// Preprocessing 
wire [15:0] G_pre, P_pre;
genvar i;

generate
    for (i = 0; i < 16; i = i + 1) begin : prep_gen
        // G = A AND B
        assign G_pre[i] = A[i] & B[i];
        // P = A XOR B (per hint: Pi:i = Ai ^ Bi)
        assign P_pre[i] = A[i] ^ B[i];
    end
endgenerate

// Level 1 (offset = 1)
// Compute group G and P across a distance of 1
wire [15:0] G1, P1;

assign G1[0] = G_pre[0] | (P_pre[0] & Cin);
assign P1[0] = P_pre[0];

// For bits 1 to 15:
generate
    for (i = 1; i <= 15; i = i + 1) begin : level1_gen
        assign P1[i] = P_pre[i] & P_pre[i-1];
            
        wire and_term;
        assign and_term = P_pre[i] & G1[i-1];
            
        assign G1[i] = G_pre[i] | and_term;
    end
endgenerate

// Repeat for levels 2,3 and 4
// Level 2
wire [15:0] G2, P2;
generate
    for (i = 0; i < 16; i = i + 1) begin : level2_gen
        if (i < 2) begin
            assign G2[i] = G1[i];
            assign P2[i] = P1[i];
        end else begin
            assign P2[i] = P1[i] & P1[i-2];
            wire and_term;
            assign and_term = P1[i] & G1[i-2];
            assign G2[i] = G1[i] | and_term;
        end
    end
endgenerate

// Level 3
wire [15:0] G3, P3;
generate
    for (i = 0; i < 16; i = i + 1) begin : level3_gen
        if (i < 4) begin
            assign G3[i] = G2[i];
            assign P3[i] = P2[i];
        end else begin
            assign P3[i] = P2[i] & P2[i-4];
            wire and_term;
            assign and_term = P2[i] & G2[i-4];
            assign G3[i] = G2[i] | and_term;
        end
    end
endgenerate

// Level 4
wire [15:0] G4, P4;
generate
    for (i = 0; i < 16; i = i + 1) begin : level4_gen
        if (i < 8) begin
            assign G4[i] = G3[i];
            assign P4[i] = P3[i];
        end else begin
            assign P4[i] = P3[i] & P3[i-8];
            wire and_term;
            assign and_term = P3[i] & G3[i-8];
            assign G4[i] = G3[i] | and_term;
        end
    end
endgenerate

// Postprocessing
// Extract carry-in for each bit position
wire [15:0] carry_in;
assign carry_in[0] = Cin;
assign carry_in[15:1] = G4[14:0];

// Final Sum generation: S[i] = C[i-1] ^ P[i] (per hint)
generate
    for (i = 0; i < 16; i = i + 1) begin : sum_gen
        assign S[i] = carry_in[i] ^ P_pre[i];
    end
endgenerate

// Final Carry Out of the adder
assign Cout = G4[15];

endmodule

// 4b Testing - Enhanced CLA testbench
// 4b Testing - Enhanced CLA testbench with structured table output
module testbench;
    reg [15:0] A, B;
    reg Sub;
    wire [15:0] S;
    wire Cout;

  initial begin    
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
    
    // Print a clean table header
    $display("====================================================================================");
    $display(" Time | Op  | A (Hex)   A (Dec)  | B (Hex)   B (Dec)  | Cout | S (Hex)   S (Dec)");
    $display("====================================================================================");

    // Test 1: Addition
    Sub = 1'b0; A = 16'd100; B = 16'd200; #5;
    $display(" %3t  | Add |   %h     %5d   |   %h     %5d   |   %b  |   %h     %5d", 
             $time, A, A, B, B, Cout, S, S);

    // Test 2: Subtraction
    Sub = 1'b1; A = 16'd1000; B = 16'd400; #5;
    $display(" %3t  | Sub |   %h     %5d   |   %h     %5d   |   %b  |   %h     %5d", 
             $time, A, A, B, B, Cout, S, S);

    // Test 3: Signed Addition (negative B)
    Sub = 1'b0; A = 16'd50; B = 16'hFFEC; #5; // B = -20
    $display(" %3t  | Add |   %h     %5d   |   %h    %6d   |   %b  |   %h     %5d", 
             $time, A, A, B, $signed(B), Cout, S,$signed(S));

    // Test 4: Signed Subtraction (negative B)
    Sub = 1'b1; A = 16'd50; B = 16'hFFEC; #5; // B = -20
    $display(" %3t  | Sub |   %h     %5d   |   %h    %6d   |   %b  |   %h     %5d", 
             $time, A, A, B, $signed(B), Cout, S,$signed(S));

    // Test 5: Max 16-bit Addition
    Sub = 1'b0; A = 16'hFFFF; B = 16'hFFFF; #5;
    $display(" %3t  | Add |   %h     %5d   |   %h     %5d   |   %b  |   %h     %5d", 
             $time, A, A, B, B, Cout, S, S);

    // Test 6: Carry-out trigger (`0xFFFF + 1`)
    Sub = 1'b0; A = 16'hFFFF; B = 16'd1; #5;
    $display(" %3t  | Add |   %h     %5d   |   %h     %5d   |   %b  |   %h     %5d", 
             $time, A, A, B, B, Cout, S, S);

    // Test 7: Multi-block carry propagation (`0xFFF + 1`)
    Sub = 1'b0; A = 16'h0FFF; B = 16'd1; #5;
    $display(" %3t  | Add |   %h     %5d   |   %h     %5d   |   %b  |   %h     %5d", 
             $time, A, A, B, B, Cout, S, S);

    // Test 8: Subtraction borrow propagation (`0x1000 - 1`)
    Sub = 1'b1; A = 16'h1000; B = 16'd1; #5;
    $display(" %3t  | Sub |   %h     %5d   |   %h     %5d   |   %b  |   %h     %5d", 
             $time, A, A, B, B, Cout, S, S);

    $display("====================================================================================");
    $finish;
  end

  kogge_stone_adder_16bit add0(A, B ^ {16{Sub}}, Sub, S, Cout);

endmodule