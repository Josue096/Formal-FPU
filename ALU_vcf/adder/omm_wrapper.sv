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

    always_comb begin
        COMM_SIGNO: assert (result_ab[31] == result_ba[31]);
        COMM_EXPONENTE: assert (result_ab[30:23] == result_ba[30:23]);
        COMM_MANTISSA: assert (result_ab[22:0] == result_ba[22:0]);
        COMM_OV: assert (ov1 == ov2);
        COMM_UD: assert (ud1 == ud2);
    end
  
endmodule
