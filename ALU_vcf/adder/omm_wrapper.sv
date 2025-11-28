module fp_comm_wrapper;

  logic [31:0] a, b;
  logic [31:0] result_ab, result_ba;
  logic [2:0]  rmode;
  logic ov1, ud1, ov2, ud2;

  // DUT original
  fp_adder dut_ab (
    .fp_a(a), .fp_b(b),
    .r_mode(rmode),
    .fp_result(result_ab),
    .overflow(ov1),
    .underflow(ud1)
  );

  // DUT con inputs invertidos
  fp_adder dut_ba (
    .fp_a(b), .fp_b(a),
    .r_mode(rmode),
    .fp_result(result_ba),
    .overflow(ov2),
    .underflow(ud2)
  );

  // propiedad de conmutatividad
  COMM: assert property (result_ab == result_ba);
  COMM_OV: assert property (ov1 == ov2);
  COMM_UD: assert property (ud1 == ud2);

endmodule
