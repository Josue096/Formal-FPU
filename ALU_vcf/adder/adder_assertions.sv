module fp_adder_checker (

//señales del top sumador
  input logic [31:0]  fp_a,
  input logic [31:0]  fp_b,
  input logic [2:0]   r_mode,
  input logic [31:0]  fp_result,
  input logic         overflow,
  input logic         underflow,

//señales de bloque fp_unpack
  input logic         sign_a,
  input logic         sign_b,
  input logic [7:0]   exponent_a,
  input logic [7:0]   exponent_b,
  input logic [23:0]  mantissa_a,
  input logic [23:0]  mantissa_b,
  input logic         is_special_a, 
  input logic         is_special_b,
  input logic         is_subnormal_a,
  input logic         is_subnormal_b,
  input logic         is_zero_a, 
  input logic         is_zero_b,

//señales de bloque align_exponents
  input logic [23:0]  mantissa_a_aligned,
  input logic [23:0]  mantissa_b_aligned,
  input logic [7:0]   exponent_common,

//Sub_mantisas
  input logic         result_sign,
  input logic [24:0]  mantissa_sum,

//Normalize
  input logic [7:0]   exponent_out, 
  input logic [26:0]  mantissa_ext,

//Round
  input logic [22:0]  mantissa_rounded,
  input logic         carry_out,

//Final
  input logic [7:0]   exponent_final,
  input logic         overflow_internal,
  input logic [31:0]  fp_result_wire
);

  // =======================================
  // CLOCK VIRTUAL PARA VC FORMAL (VCF)
  // =======================================
  logic clk = 0;
  always #1 clk = ~clk;

  // Clock para TODAS las properties SVA
  default clocking cb @ (posedge clk); endclocking


  // =======================================
  // Variables auxiliares
  // =======================================
  logic [7:0]  shift_amount;
  logic [22:0] mantissa_r;
  logic [23:0] carry;
  logic [7:0]  expo_diff;

  assign shift_amount = leading_zero_count(mantissa_sum[23:0]);


  // =======================================
  // ====== TODAS TUS ASSERTIONS ORIGINALES =
  // =======================================

  ZERO_SUM: assert property (
      (fp_a == 32'h00000000 && fp_b == 32'h00000000)
      |-> (fp_result == 32'h00000000 && !overflow && !underflow)
  );

  FP_UNPACK_A: assert property (
      ((fp_a[30:23] != 8'hFF) && (fp_a[30:0] != 31'd0))
      |-> ((sign_a == fp_a[31]) &&
           (exponent_a == fp_a[30:23]) &&
           (mantissa_a == {1'b1, fp_a[22:0]}))
  );

  FP_UNPACK_B: assert property (
      ((fp_b[30:23] != 8'hFF) && (fp_b[30:0] != 31'd0))
      |-> ((sign_b == fp_b[31]) &&
           (exponent_b == fp_b[30:23]) &&
           (mantissa_b == {1'b1, fp_b[22:0]}))
  );

  FP_UNPACK_A_SPECIAL: assert property (
      (fp_a[30:23] == 8'hFF)
      |-> (sign_a == fp_a[31] &&
           exponent_a == 8'hFF &&
           mantissa_a == {1'b0, fp_a[22:0]} &&
           is_special_a)
  );

  FP_UNPACK_B_SPECIAL: assert property (
      (fp_b[30:23] == 8'hFF)
      |-> (sign_b == fp_b[31] &&
           exponent_b == 8'hFF &&
           mantissa_b == {1'b0, fp_b[22:0]} &&
           is_special_b)
  );

  FP_UNPACK_A_ZERO: assert property ( (fp_a[30:0] == 0) |-> is_zero_a );
  FP_UNPACK_B_ZERO: assert property ( (fp_b[30:0] == 0) |-> is_zero_b );

  ALIGN_A_NORM: assert property (
      ((exponent_b > exponent_a) && !is_subnormal_a && !is_subnormal_b)
      |-> (mantissa_b_aligned == mantissa_b &&
           mantissa_a_aligned == mantissa_a >> (exponent_b - exponent_a))
  );

  ALIGN_A_SUBNORM: assert property (
      (is_subnormal_a && !is_subnormal_b && !is_zero_b && !is_special_b)
      |-> (mantissa_b_aligned == mantissa_b &&
           mantissa_a_aligned == mantissa_a >> ((exponent_b - exponent_a) - 1))
  );

  ALIGN_B_NORM: assert property (
      ((exponent_a > exponent_b) && !is_subnormal_a && !is_subnormal_b)
      |-> (mantissa_a_aligned == mantissa_a &&
           mantissa_b_aligned == mantissa_b >> (exponent_a - exponent_b))
  );

  ALIGN_B_SUBNORM: assert property (
      (!is_subnormal_a && is_subnormal_b && !is_zero_a && !is_special_a)
      |-> (mantissa_a_aligned == mantissa_a &&
           mantissa_b_aligned == mantissa_b >> ((exponent_a - exponent_b) - 1))
  );

  ALIGN_SUBNORMAL: assert property (
      (is_subnormal_a && is_subnormal_b)
      |-> (mantissa_a_aligned == mantissa_a &&
           mantissa_b_aligned == mantissa_b)
  );

  ALIGN_EXP_NORMAL: assert property (
      (!(is_subnormal_a || is_subnormal_b) && !is_special_a && !is_special_b)
      |-> (exponent_common == ((exponent_a > exponent_b) ? exponent_a : exponent_b))
  );

  ALIGN_EXP_SUBNORMAL: assert property (
      (is_subnormal_a && is_subnormal_b)
      |-> (exponent_common == 8'd0)
  );

  SUMA: assert property (
      (sign_a == sign_b)
      |-> (mantissa_sum == mantissa_a_aligned + mantissa_b_aligned &&
           result_sign == sign_b)
  );

  SUMA_RESTA_A_MAYOR: assert property (
      ((sign_a != sign_b) && (mantissa_a_aligned > mantissa_b_aligned))
      |-> (mantissa_sum == mantissa_a_aligned - mantissa_b_aligned &&
           result_sign == sign_a)
  );

  SUMA_RESTA_B_MAYOR: assert property (
      ((sign_a != sign_b) && (mantissa_b_aligned > mantissa_a_aligned))
      |-> (mantissa_sum == mantissa_b_aligned - mantissa_a_aligned &&
           result_sign == sign_b)
  );

  SUMA_RESTA_IGUALES: assert property (
      ((sign_a != sign_b) && (mantissa_a_aligned == mantissa_b_aligned))
      |-> (mantissa_sum == 0 && result_sign == 0)
  );

  NORM_CARRY_EXPO: assert property (
      (mantissa_sum[24] && !is_subnormal_a && !is_subnormal_b)
      |-> (exponent_out == exponent_common + 1)
  );

  NORM_CARRY_EXPO_SUB: assert property (
      (mantissa_sum[23] && exponent_common == 0 && mantissa_sum != 0)
      |-> (exponent_out == exponent_common + 1)
  );

  NORM_CARRY_MANTISSA: assert property (
      (mantissa_sum[24] && !is_subnormal_a && !is_subnormal_b)
      |-> (mantissa_ext == {mantissa_sum, 2'b00})
  );

  NORM_CARRY_MANTISSA_SUBN: assert property (
      (mantissa_sum[23] && exponent_common == 0 && mantissa_sum != 0)
      |-> (mantissa_ext[25:3] == mantissa_sum[23:0])
  );

  NORM_SHIFT_MANTISSA_NORMALES: assert property (
      (mantissa_sum != 0 &&
       !mantissa_sum[24] &&
       !mantissa_sum[23] &&
       (exponent_common > shift_amount))
      |-> (mantissa_ext[26:3] == (mantissa_sum[23:0] << shift_amount))
  );

  NORM_SHIFT_EXPO_NORMALES: assert property (
      (mantissa_sum != 0 &&
       !mantissa_sum[24] &&
       !mantissa_sum[23] &&
       (exponent_common > shift_amount))
      |-> (exponent_out == exponent_common - shift_amount)
  );

  NORM_SHIFT_MANTISSA_NORM_A_SUBN: assert property (
      (mantissa_sum != 0 &&
       !mantissa_sum[24] &&
       !mantissa_sum[23] &&
       exponent_common > 0 &&
       exponent_common <= shift_amount)
      |-> (mantissa_ext[25:3] == (mantissa_sum[23:0] << exponent_common))
  );

  NORM_SHIFT_EXPO_NORM_A_SUBN: assert property (
      (mantissa_sum != 0 &&
       !mantissa_sum[24] &&
       !mantissa_sum[23] &&
       exponent_common > 0 &&
       exponent_common <= shift_amount)
      |-> (exponent_out == 0)
  );

  ROUND_RNZ: assert property (
      (r_mode == 3'b000)
      |-> (mantissa_rounded == ( // RN-even
          (mantissa_ext[2] && (|mantissa_ext[1:0])) ?
            mantissa_ext[25:3] + 1 :
            mantissa_ext[25:3]
        ))
  );

  ROUND_RTZ: assert property (
      (r_mode == 3'b001)
      |-> (mantissa_rounded == mantissa_ext[25:3])
  );

  ROUND_RDN: assert property (
      (r_mode == 3'b010)
      |-> (mantissa_rounded ==
           (result_sign ? (mantissa_ext[25:3] + 1) : mantissa_ext[25:3]))
  );

  ROUND_RUP: assert property (
      (r_mode == 3'b011)
      |-> (mantissa_rounded ==
           (result_sign ? mantissa_ext[25:3] :
                          (mantissa_ext[25:3] + 1)))
  );

  ROUND_RMM: assert property (
      (r_mode == 3'b100)
      |-> (mantissa_rounded ==
           (mantissa_ext[2] ?
                (mantissa_ext[25:3] + 1) :
                mantissa_ext[25:3]))
  );

  ROUND_CARRY: assert property (
      carry_out
      |-> (mantissa_rounded == mantissa_ext[25:3] + 1 &&
           mantissa_rounded[23])
  );

  FP_PACK: assert property (
      fp_result_wire == {result_sign, exponent_final, mantissa_rounded}
  );

  PRUEBA_SUB: assert property (
      (fp_a == 32'h000a0000 && fp_b == 32'h000a0000 && r_mode == 3'b001)
      |-> (fp_result == 32'h00140000)
  );

  PRUEBA_SUB_NORM: assert property (
      (fp_a == 32'h01000000 && fp_b == 32'h00300000 && r_mode == 3'b001)
      |-> (fp_result == 32'h01180000)
  );

  PRUEBA_NORM_NORM: assert property (
      (fp_a == 32'h14300000 && fp_b == 32'h1FC00000 && r_mode == 3'b001)
      |-> (fp_result == 32'h1FC00001)
  );


  // ===============================
  // Leading-zero function
  // ===============================
  function automatic [7:0] leading_zero_count(input logic [23:0] value);
    leading_zero_count = 0;
    for (int i = 23; i >= 0; i--) begin
      if (value[i]) begin
        leading_zero_count = 23 - i;
        break;
      end
    end
  endfunction

endmodule
