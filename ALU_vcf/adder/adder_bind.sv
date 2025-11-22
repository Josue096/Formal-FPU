module adder_bind;

  bind fp_adder fp_adder_checker_sva chk (
    .fp_a                     (fp_a),
    .fp_b                     (fp_b),
    .r_mode                   (r_mode),
    .fp_result                (fp_result),
    .overflow                 (overflow),
    .underflow                (underflow),

    .sign_a                   (fp_adder.sign_a),
    .sign_b                   (fp_adder.sign_b),
    .exponent_a               (fp_adder.exponent_a),
    .exponent_b               (fp_adder.exponent_b),
    .mantissa_a               (fp_adder.mantissa_a),
    .mantissa_b               (fp_adder.mantissa_b),
    .is_special_a             (fp_adder.is_special_a),
    .is_special_b             (fp_adder.is_special_b),
    .is_subnormal_a           (fp_adder.is_subnormal_a),
    .is_subnormal_b           (fp_adder.is_subnormal_b),
    .is_zero_a                (fp_adder.is_zero_a),
    .is_zero_b                (fp_adder.is_zero_b),

    .mantissa_a_aligned       (fp_adder.mantissa_a_aligned),
    .mantissa_b_aligned       (fp_adder.mantissa_b_aligned),
    .exponent_common          (fp_adder.exponent_common),

    .result_sign              (fp_adder.result_sign),
    .exponent_out             (fp_adder.exponent_out),
    .exponent_final           (fp_adder.exponent_final),
    .mantissa_sum             (fp_adder.mantissa_sum),
    .mantissa_ext             (fp_adder.mantissa_ext),
    .mantissa_rounded         (fp_adder.mantissa_rounded),
    .carry_out                (fp_adder.carry_out),
    .overflow_internal        (fp_adder.overflow_internal),
    .fp_result_wire           (fp_adder.fp_result_wire)
  );

endmodule

