bind fp_adder fp_adder_checker chk (
  .fp_a                     (fp_a),
  .fp_b                     (fp_b),
  .r_mode                   (r_mode),
  .fp_result                (fp_result),
  .overflow                 (overflow),
  .underflow                (underflow),

  // internas — SIN prefijo
  .sign_a                   (sign_a),
  .sign_b                   (sign_b),
  .exponent_a               (exponent_a),
  .exponent_b               (exponent_b),
  .mantissa_a               (mantissa_a),
  .mantissa_b               (mantissa_b),
  .is_special_a             (is_special_a),
  .is_special_b             (is_special_b),
  .is_subnormal_a           (is_subnormal_a),
  .is_subnormal_b           (is_subnormal_b),
  .is_zero_a                (is_zero_a),
  .is_zero_b                (is_zero_b),

  .mantissa_a_aligned       (mantissa_a_aligned),
  .mantissa_b_aligned       (mantissa_b_aligned),
  .exponent_common          (exponent_common),

  .result_sign              (result_sign),
  .exponent_out             (exponent_out),
  .exponent_final           (exponent_final),
  .mantissa_sum             (mantissa_sum),
  .mantissa_ext             (mantissa_ext),
  .mantissa_rounded         (mantissa_rounded),
  .carry_out                (carry_out),
  .overflow_internal        (overflow_internal),
  .fp_result_wire           (fp_result_wire)       
);
