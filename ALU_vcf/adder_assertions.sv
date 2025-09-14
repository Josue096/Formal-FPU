module fp_adder_checker (
    input logic [31:0] fp_a,
    input logic [31:0] fp_b,
    input logic [2:0]  r_mode,

    input logic [31:0] fp_result,
    input logic        overflow,
    input logic        underflow
);

  // --- Propiedad 1: 0 + 0 = 0 ---
  property add_zero_zero;
    (fp_a == 32'h00000000 && fp_b == 32'h00000000)
      |-> (fp_result == 32'h00000000 && overflow == 0 && underflow == 0);
  endproperty
  assert property(add_zero_zero);

endmodule


