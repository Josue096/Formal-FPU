module fp_comm_wrapper;

  logic [2:0]rmode;
  logic [31:0]a, b;
  logic [31:0]result_ab, result_ba;
  logic ov1, ov2,ud1, ud2;
  // DUT original
  fp_mul dut_ab (
    .fp_X(a), .fp_Y(b),
    .r_mode(rmode),
    .fp_Z(result_ab),
    .ovrf(ov1),
    .udrf(ud1)
  );

  // DUT con inputs invertidos
  fp_mul dut_ba (
    .fp_X(b), .fp_Y(a),
    .r_mode(rmode),
    .fp_Z(result_ba),
    .ovrf(ov2),
    .udrf(ud2)
  );

    always_comb begin
        assume (a <= b);
        COMM_SIGNO: assert (result_ab[31] == result_ba[31]);
        COMM_EXPONENTE: assert (result_ab[30:23] == result_ba[30:23]);
        COMM_MANTISSA: assert (result_ab[22:0] == result_ba[22:0]);
        COMM_OV: assert (ov1 == ov2);
        COMM_UD: assert (ud1 == ud2);
    end
  
endmodule
