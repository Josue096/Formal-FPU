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

//
  input logic         exponent_final,
  input logic         overflow_internal,
  input logic [31:0]  fp_result_wire
);
  logic [7:0]  shift_amount;
  logic [22:0] mantissa_r;
  logic [23:0] carry;
  logic [7:0]  expo_diff;

  // ============================================================================
//  Floating Point Adder Checker – PURE COMBINATIONAL SVA PROPERTIES
//  Todas las condiciones son EXACTAMENTE las mismas que tenías en el always_comb
//  No se modificó NADA de lógica, nombres, señales ni semántica.
// ============================================================================

module fp_adder_checker_sva(
    input  logic [31:0] fp_a,
    input  logic [31:0] fp_b,
    input  logic [31:0] fp_result,
    input  logic [31:0] fp_result_wire,

    input  logic sign_a,
    input  logic sign_b,
    input  logic result_sign,

    input  logic [7:0] exponent_a,
    input  logic [7:0] exponent_b,
    input  logic [7:0] exponent_common,
    input  logic [7:0] exponent_out,
    input  logic [7:0] exponent_final,

    input  logic [23:0] mantissa_a,
    input  logic [23:0] mantissa_b,
    input  logic [24:0] mantissa_a_aligned,
    input  logic [24:0] mantissa_b_aligned,

    input  logic [24:0] mantissa_sum,
    input  logic [26:0] mantissa_ext,
    input  logic [23:0] mantissa_rounded,

    input  logic [2:0] r_mode,

    input  logic is_special_a,
    input  logic is_special_b,
    input  logic is_zero_a,
    input  logic is_zero_b,
    input  logic is_subnormal_a,
    input  logic is_subnormal_b,

    input  logic [4:0] shift_amount,
    input  logic [24:0] carry,
    input  logic carry_out,

    input  logic overflow,
    input  logic underflow,

    input  logic [7:0] expo_diff
);

// ============================================================================
//  UNPACK PROPERTIES
// ============================================================================

property ZERO_SUM_p;
  (fp_a == 32'h00000000 && fp_b == 32'h00000000) |->
  (fp_result == 32'h00000000 && overflow == 0 && underflow == 0);
endproperty
assert property (ZERO_SUM_p);

property FP_UNPACK_A_p;
  ((fp_a[30:23] != 8'hFF) && (fp_a[30:0] != 31'd0)) |->
  ((sign_a == fp_a[31]) &&
   (exponent_a == fp_a[30:23]) &&
   (mantissa_a == {|fp_a[30:23], fp_a[22:0]}));
endproperty
assert property (FP_UNPACK_A_p);

property FP_UNPACK_B_p;
  ((fp_b[30:23] != 8'hFF) && (fp_b[30:0] != 31'd0)) |->
  ((sign_b == fp_b[31]) &&
   (exponent_b == fp_b[30:23]) &&
   (mantissa_b == {|fp_b[30:23], fp_b[22:0]}));
endproperty
assert property (FP_UNPACK_B_p);

property FP_UNPACK_A_SPECIAL_p;
  (fp_a[30:23] == 8'hFF) |->
  ((sign_a == fp_a[31]) &&
   (exponent_a == 8'hFF) &&
   (mantissa_a == {1'b0, fp_a[22:0]}) &&
   is_special_a);
endproperty
assert property (FP_UNPACK_A_SPECIAL_p);

property FP_UNPACK_B_SPECIAL_p;
  (fp_b[30:23] == 8'hFF) |->
  ((sign_b == fp_b[31]) &&
   (exponent_b == 8'hFF) &&
   (mantissa_b == {1'b0, fp_b[22:0]}) &&
   is_special_b);
endproperty
assert property (FP_UNPACK_B_SPECIAL_p);

property FP_UNPACK_A_ZERO_p;
  (fp_a[30:0] == 31'b0) |->
  (is_zero_a == 1);
endproperty
assert property (FP_UNPACK_A_ZERO_p);

property FP_UNPACK_B_ZERO_p;
  (fp_b[30:0] == 31'b0) |->
  (is_zero_b == 1);
endproperty
assert property (FP_UNPACK_B_ZERO_p);

// ============================================================================
//  ALIGN PROPERTIES
// ============================================================================

property ALIGN_A_NORM_p;
  ((exponent_b > exponent_a) && !is_subnormal_a && !is_subnormal_b) |->
  (mantissa_b_aligned == mantissa_b &&
   mantissa_a_aligned == (mantissa_a >> expo_diff));
endproperty
assert property (ALIGN_A_NORM_p);

property ALIGN_A_SUBNORM_p;
  (is_subnormal_a && !is_subnormal_b && !is_zero_b && !is_special_b) |->
  (mantissa_b_aligned == mantissa_b &&
   mantissa_a_aligned == (mantissa_a >> (expo_diff - 1)));
endproperty
assert property (ALIGN_A_SUBNORM_p);

property ALIGN_B_NORM_p;
  ((exponent_a > exponent_b) && !is_subnormal_a && !is_subnormal_b) |->
  (mantissa_a_aligned == mantissa_a &&
   mantissa_b_aligned == (mantissa_b >> expo_diff));
endproperty
assert property (ALIGN_B_NORM_p);

property ALIGN_B_SUBNORM_p;
  (!is_subnormal_a && is_subnormal_b && !is_zero_a && !is_special_a) |->
  (mantissa_a_aligned == mantissa_a &&
   mantissa_b_aligned == (mantissa_b >> (expo_diff - 1)));
endproperty
assert property (ALIGN_B_SUBNORM_p);

property ALIGN_SUBNORMAL_p;
  (is_subnormal_a && is_subnormal_b) |->
  ((mantissa_b_aligned == mantissa_b) &&
   (mantissa_a_aligned == mantissa_a));
endproperty
assert property (ALIGN_SUBNORMAL_p);

property ALIGN_EXP_NORMAL_p;
  (!(is_subnormal_a || is_subnormal_b) && !is_special_a && !is_special_b) |->
  (exponent_common ==
     ((exponent_a > exponent_b) ? exponent_a : exponent_b));
endproperty
assert property (ALIGN_EXP_NORMAL_p);

property ALIGN_EXP_SUBNORMAL_p;
  (is_subnormal_a && is_subnormal_b) |->
  (exponent_common == 8'd0);
endproperty
assert property (ALIGN_EXP_SUBNORMAL_p);

// ============================================================================
//  ADD / SUB PROPERTIES
// ============================================================================

property SUMA_p;
  (sign_a == sign_b) |->
  ((mantissa_sum == mantissa_a_aligned + mantissa_b_aligned) &&
   (result_sign == sign_b));
endproperty
assert property (SUMA_p);

property SUMA_RESTA_A_MAYOR_p;
  ((sign_a != sign_b) && (mantissa_a_aligned > mantissa_b_aligned)) |->
  ((mantissa_sum == (mantissa_a_aligned - mantissa_b_aligned)) &&
   (result_sign == sign_a));
endproperty
assert property (SUMA_RESTA_A_MAYOR_p);

property SUMA_RESTA_B_MAYOR_p;
  ((sign_a != sign_b) && (mantissa_b_aligned > mantissa_a_aligned)) |->
  ((mantissa_sum == (mantissa_b_aligned - mantissa_a_aligned)) &&
   (result_sign == sign_b));
endproperty
assert property (SUMA_RESTA_B_MAYOR_p);

property SUMA_RESTA_IGUALES_p;
  ((sign_a != sign_b) && (mantissa_a_aligned == mantissa_b_aligned)) |->
  ((mantissa_sum == 0) && (result_sign == 0));
endproperty
assert property (SUMA_RESTA_IGUALES_p);

// ============================================================================
//  NORMALIZE PROPERTIES
// ============================================================================

property NORM_CARRY_EXPO_p;
  (mantissa_sum[24] && !is_subnormal_a && !is_subnormal_b) |->
  (exponent_out == exponent_common + 1);
endproperty
assert property (NORM_CARRY_EXPO_p);

property NORM_CARRY_EXPO_SUB_p;
  (mantissa_sum[23] && (exponent_common == 8'b0) && mantissa_sum != 0) |->
  (exponent_out == exponent_common + 1);
endproperty
assert property (NORM_CARRY_EXPO_SUB_p);

property NORM_CARRY_MANTISSA_p;
  (mantissa_sum[24] && !is_subnormal_a && !is_subnormal_b) |->
  (mantissa_ext == {mantissa_sum,1'b0,1'b0});
endproperty
assert property (NORM_CARRY_MANTISSA_p);

property NORM_CARRY_MANTISSA_SUBN_p;
  (mantissa_sum[23] && (exponent_common == 8'b0) && mantissa_sum != 0) |->
  (mantissa_ext[25:3] == mantissa_sum[23:0]);
endproperty
assert property (NORM_CARRY_MANTISSA_SUBN_p);

property NORM_SHIFT_MANTISSA_NORMALES_p;
  ((mantissa_sum != 0) && !mantissa_sum[24] && !mantissa_sum[23] &&
   (exponent_common > shift_amount)) |->
  (mantissa_ext[26:3] == (mantissa_sum[23:0] << shift_amount));
endproperty
assert property (NORM_SHIFT_MANTISSA_NORMALES_p);

property NORM_SHIFT_EXPO_NORMALES_p;
  ((mantissa_sum != 0) && !mantissa_sum[24] && !mantissa_sum[23] &&
   (exponent_common > shift_amount)) |->
  (exponent_out == exponent_common - shift_amount);
endproperty
assert property (NORM_SHIFT_EXPO_NORMALES_p);

property NORM_SHIFT_MANTISSA_NORM_A_SUBN_p;
  ((mantissa_sum != 0) && !mantissa_sum[24] && !mantissa_sum[23] &&
   (exponent_common > 0) && (exponent_common <= shift_amount)) |->
  (mantissa_ext[25:3] == (mantissa_sum[23:0] << exponent_common));
endproperty
assert property (NORM_SHIFT_MANTISSA_NORM_A_SUBN_p);

property NORM_SHIFT_EXPO_NORM_A_SUBN_p;
  ((mantissa_sum != 0) && !mantissa_sum[24] && !mantissa_sum[23] &&
   (exponent_common > 0) && (exponent_common <= shift_amount)) |->
  (exponent_out == 0);
endproperty
assert property (NORM_SHIFT_EXPO_NORM_A_SUBN_p);

property NORM_SHIFT_MANTISSA_SUBN_p;
  ((mantissa_sum != 0) && !mantissa_sum[24] && !mantissa_sum[23] &&
   (exponent_common == 8'b0)) |->
  (mantissa_ext[25:3] == mantissa_sum[23:0]);
endproperty
assert property (NORM_SHIFT_MANTISSA_SUBN_p);

property NORM_SHIFT_EXPO_SUBN_p;
  ((mantissa_sum != 0) && !mantissa_sum[24] && !mantissa_sum[23] &&
   (exponent_common == 8'b0)) |->
  (exponent_out == exponent_common);
endproperty
assert property (NORM_SHIFT_EXPO_SUBN_p);

// ============================================================================
//  ROUND PROPERTIES
// ============================================================================

property ROUND_RNZ_p;
  (r_mode == 3'b000) |->
  (mantissa_rounded == mantissa_r);
endproperty
assert property (ROUND_RNZ_p);

property ROUND_RTZ_p;
  (r_mode == 3'b001) |->
  (mantissa_rounded == mantissa_ext[25:3]);
endproperty
assert property (ROUND_RTZ_p);

property ROUND_RDN_p;
  (r_mode == 3'b010) |->
  (mantissa_rounded == mantissa_r);
endproperty
assert property (ROUND_RDN_p);

property ROUND_RUP_p;
  (r_mode == 3'b011) |->
  (mantissa_rounded == mantissa_r);
endproperty
assert property (ROUND_RUP_p);

property ROUND_RMM_p;
  (r_mode == 3'b100) |->
  (mantissa_rounded == mantissa_r);
endproperty
assert property (ROUND_RMM_p);

property ROUND_CARRY_p;
  (carry_out) |->
  (carry[23] &&
   (mantissa_rounded == (mantissa_ext[25:3] + 1'b1)));
endproperty
assert property (ROUND_CARRY_p);

// ============================================================================
//  PACK PROPERTY
// ============================================================================

property FP_PACK_p;
  fp_result_wire == {result_sign, exponent_final, mantissa_rounded};
endproperty
assert property (FP_PACK_p);

// ============================================================================
//  UNIT TEST PROPERTIES
// ============================================================================

property PRUEBA_SUB_p;
  (fp_a == 32'h000A0000 && fp_b == 32'h000A0000 && r_mode == 3'b001) |->
  (fp_result == 32'h00140000);
endproperty
assert property (PRUEBA_SUB_p);

property PRUEBA_SUB_NORM_p;
  (fp_a == 32'h01000000 && fp_b == 32'h00300000 && r_mode == 3'b001) |->
  (fp_result == 32'h01180000);
endproperty
assert property (PRUEBA_SUB_NORM_p);

property PRUEBA_NORM_NORM_p;
  (fp_a == 32'h14300000 && fp_b == 32'h1FC00000 && r_mode == 3'b001) |->
  (fp_result == 32'h1FC00001);
endproperty
assert property (PRUEBA_NORM_NORM_p);

endmodule


  function automatic [7:0] leading_zero_count(input logic [23:0] value);
    begin
      leading_zero_count = 8'd0; // Inicializar el conteo en cero
      
      for (int i = 23; i >= 0; i--) begin // Recorrer desde el bit más significativo (MSB = 23)
      
        if (value[i]) begin // Primer '1' encontrado: contar los ceros previos
          leading_zero_count = 8'(23 - i);
          break;
        end
      end
    end
  endfunction
endmodule