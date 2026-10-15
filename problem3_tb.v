`timescale 1ns/1ps

// 3b. Modify the CLA testbench to test the 16-bit PPA.
module testbench;

  reg [15:0] A, B;
  reg Sub;

  wire [15:0] S;
  wire Cout;

  integer tests;
  integer errors;

  // Sub = 0 for addition, Sub = 1 for subtraction.
  PPA add0(A, B ^ {16{Sub}}, Sub, S, Cout);

  // Apply inputs and check Cout and S.
  task check;
    input [15:0] test_A, test_B;
    input test_Sub;
    input [16:0] expected;

    begin
      A = test_A;
      B = test_B;
      Sub = test_Sub;

      #10;
      tests = tests + 1;

      if ({Cout, S} !== expected) begin
        errors = errors + 1;
        $display("FAIL: A=%h B=%h Sub=%b | Cout=%b S=%h | Expected=%h",
                 A, B, Sub, Cout, S, expected);
      end else begin
        $display("PASS: A=%h B=%h Sub=%b | Cout=%b S=%h",
                 A, B, Sub, Cout, S);
      end
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);

    tests = 0;
    errors = 0;

    // Unsigned addition: 100 + 200 = 300
    check(16'd100, 16'd200, 1'b0, 17'h0012C);

    // Unsigned subtraction: 1000 - 400 = 600
    check(16'd1000, 16'd400, 1'b1, 17'h10258);

    // Signed addition: 50 + (-20) = 30
    check(16'd50, 16'hFFEC, 1'b0, 17'h1001E);

    // Signed subtraction: 50 - (-20) = 70
    check(16'd50, 16'hFFEC, 1'b1, 17'h00046);

    // Carry-out: FFFF + FFFF = 1FFFE
    check(16'hFFFF, 16'hFFFF, 1'b0, 17'h1FFFE);

    // Carry through all 16 bits.
    check(16'hFFFF, 16'd1, 1'b0, 17'h10000);

    // Carry across multiple 4-bit blocks.
    check(16'h00FF, 16'd1, 1'b0, 17'h00100);

    // Carry across three 4-bit boundaries.
    check(16'h0FFF, 16'd1, 1'b0, 17'h01000);

    // Subtraction with borrow: 0 - 1 = -1
    check(16'd0, 16'd1, 1'b1, 17'h0FFFF);

    // Equal operands: 25 - 25 = 0
    check(16'd25, 16'd25, 1'b1, 17'h10000);

    // Signed overflow: 32767 + 1
    check(16'h7FFF, 16'd1, 1'b0, 17'h08000);

    // Adder inputs become A = 0, B = 0, Cin = 1.
    check(16'h0000, 16'hFFFF, 1'b1, 17'h00001);

    // Adder inputs become A = FFFF, B = 0, Cin = 1.
    check(16'hFFFF, 16'hFFFF, 1'b1, 17'h10000);

    $display("--------------------------------");
    $display("Tests: %0d | Errors: %0d", tests, errors);

    if (errors == 0)
      $display("ALL TESTS PASSED");
    else
      $display("TESTS FAILED");

    $finish;
  end

endmodule