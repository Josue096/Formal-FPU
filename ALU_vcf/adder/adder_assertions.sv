// fp_adder_checker_sva.sv
// Versión con properties SVA (aserciones fuera de always_comb)
// Ajustes:
//  - exponent_final declarado como 8 bits
//  - funciones para cálculo de leading zero y rounding
//  - variables intermedias calculadas por assign para estabilidad del COI
//  - properties definidas y luego assert property(...)

module fp_adder_checker_sva (

// señales del top sumador
  input  logic [31:0]  fp_a,
  input  logic [31:0]  fp_b,
  input  logic [2:0]   r_mode,
  input  logic [31:0]  fp_result,
  input  logic         overflow,
  input  logic         underflow,

// señales de bloque fp_unpack
  input  logic         sign_a,
  input  logic         sign_b,
  input  logic [7:0]   exponent_a,
  input  logic [7:0]   exponent_b,
  input  logic [23:0]  mantissa_a,
  input  logic [23:0]  mantissa_b,
  input  logic         is_special_a, 
  input  logic         is_special_b,
  input  logic         is_subnormal_a,
  input  logic         is_subnormal_b,
  input  logic         is_zero_a, 
  input  logic         is_zero_b,

// señales de bloque align_exponents
  input  logic [23:0]  mantissa_a_aligned,
  input  logic [23:0]  mantissa_b_aligned,
  input  logic [7:0]   exponent_common,

// Sub_mantisas
  input  logic         result_sign,
  input  logic [24:0]  mantissa_sum,

// Normalize
  input  logic [7:0]   exponent_out, 
  input  logic [26:0]  mantissa_ext,

// Round
  input  logic [22:0]  mantissa_rounded,
  input  logic         carry_out,

//
  input  logic [7:0]   exponent_final,        // CORREGIDO: debe ser 8 bits
  input  logic         overflow_internal,
  input  logic [31:0]  fp_result_wire
);

// -----------------------------------------------------------------------------
// señales / cálculo auxiliar (combinacional, fuera de procedural blocks)
// -----------------------------------------------------------------------------
logic [7:0]  shift_amount;
wire [23:0]  carry_calc;
wire [22:0]  mantissa_r_rnz;   // nearest even
wire [22:0]  mantissa_r_rtz;   // toward zero
wire [22:0]  mantissa_r_rdn;   // toward -inf
wire [22:0]  mantissa_r_rup;   // toward +inf
wire [22:0]  mantissa_r_rmm;   // mag max in tie

assign shift_amount = leading_zero_count(mantissa_sum[23:0]);
assign carry_calc   = ({1'b0, mantissa_ext[25:3]}) + 1'b1;

// funciones de utilidad
function automatic [7:0] leading_zero_count (input logic [23:0] value);
  integer i;
  begin
    leading_zero_count = 8'd0;
    for (i = 23; i >= 0; i = i - 1) begin
      if (value[i]) begin
        leading_zero_count = 8'(23 - i);
        disable fork; // salir del for (compatible en muchos simuladores)
      end
    end
  end
endfunction

// rounding helper: nearest even (RNE)
function automatic [22:0] round_nearest_even(input logic [26:0] ext);
  logic guard, sticky;
  logic [22:0] base;
  begin
    base = ext[25:3];
    guard = ext[2];
    sticky = |ext[1:0];
    if (!guard && !sticky)
      round_nearest_even = base;
    else if (guard && !sticky)
      round_nearest_even = (ext[3]) ? base + 1'b1 : base;
    else // guard && sticky
      round_nearest_even = base + 1'b1;
  end
endfunction

// others: RTZ, RDN, RUP, RMM (simple implementations consistent con tu original)
function automatic [22:0] round_toward_zero(input logic [26:0] ext);
  begin
    round_toward_zero = ext[25:3];
  end
endfunction

function automatic [22:0] round_toward_neg(input logic [26:0] ext, input logic sign);
  // toward -inf: if negative -> round up (in magnitude), else truncate
  logic [22:0] base;
  begin
    base = ext[25:3];
    if (sign)
      round_toward_neg = base + (|ext[2:0] ? 1'b1 : 1'b0);
    else
      round_toward_neg = base;
  end
endfunction

function automatic [22:0] round_toward_pos(input logic [26:0] ext, input logic sign);
  // toward +inf: if positive -> round up, else truncate
  logic [22:0] base;
  begin
    base = ext[25:3];
    if (!sign)
      round_toward_pos = base + (|ext[2:0] ? 1'b1 : 1'b0);
    else
      round_toward_pos = base;
  end
endfunction

function automatic [22:0] round_magmax(input logic [26:0] ext);
  logic [22:0] base;
  begin
    base = ext[25:3];
    round_magmax = base + (ext[2] ? 1'b1 : 1'b0);
  end
endfunction

assign mantissa_r_rnz = round_nearest_even(mantissa_ext);
assign mantissa_r_rtz = round_toward_zero(mantissa_ext);
assign mantissa_r_rdn = round_toward_neg(mantissa_ext, result_sign);
assign mantissa_r_rup = round_toward_pos(mantissa_ext, result_sign);
assign mantissa_r_rmm = round_magmax(mantissa_ext);

// -----------------------------------------------------------------------------
// PROPERTIES (una por una). Todas definidas en scope de módulo y comprobadas
// -----------------------------------------------------------------------------

// ZERO_SUM
property p_zero_sum;
  (fp_a == 32'h00000000 && fp_b == 32'h00000000) |-> (fp_result == 32'h00000000 && !overflow && !underflow);
endproperty
assert property (p_zero_sum) else $error("ZERO_SUM failed");

// FP_UNPACK_A (normal case)
property p_fp_unpack_a;
  ((fp_a[30:23] != 8'hFF) && (fp_a[30:0] != 31'd0)) |-> ((sign_a == fp_a[31]) && (exponent_a == fp_a[30:23]) && (mantissa_a == {|fp_a[30:23], fp_a[22:0]}));
endproperty
assert property (p_fp_unpack_a) else $error("FP_UNPACK_A failed");

// FP_UNPACK_B (normal)
property p_fp_unpack_b;
  ((fp_b[30:23] != 8'hFF) && (fp_b[30:0] != 31'd0)) |-> ((sign_b == fp_b[31]) && (exponent_b == fp_b[30:23]) && (mantissa_b == {|fp_b[30:23], fp_b[22:0]}));
endproperty
assert property (p_fp_unpack_b) else $error("FP_UNPACK_B failed");

// FP_UNPACK_A_SPECIAL
property p_fp_unpack_a_special;
  (fp_a[30:23] == 8'hFF) |-> ((sign_a == fp_a[31]) && (exponent_a == 8'hFF) && (mantissa_a == {1'b0, fp_a[22:0]}) && is_special_a);
endproperty
assert property (p_fp_unpack_a_special) else $error("FP_UNPACK_A_SPECIAL failed");

// FP_UNPACK_B_SPECIAL
property p_fp_unpack_b_special;
  (fp_b[30:23] == 8'hFF) |-> ((sign_b == fp_b[31]) && (exponent_b == 8'hFF) && (mantissa_b == {1'b0, fp_b[22:0]}) && is_special_b);
endproperty
assert property (p_fp_unpack_b_special) else $error("FP_UNPACK_B_SPECIAL failed");

// FP_UNPACK_A_ZERO
property p_fp_unpack_a_zero;
  (fp_a[30:0] == 31'b0) |-> (is_zero_a == 1);
endproperty
assert property (p_fp_unpack_a_zero) else $error("FP_UNPACK_A_ZERO failed");

// FP_UNPACK_B_ZERO
property p_fp_unpack_b_zero;
  (fp_b[30:0] == 31'b0) |-> (is_zero_b == 1);
endproperty
assert property (p_fp_unpack_b_zero) else $error("FP_UNPACK_B_ZERO failed");

// ALIGN_A_NORM: exponent_b > exponent_a, normales
property p_align_a_norm;
  ((exponent_b > exponent_a) && !is_subnormal_a && !is_subnormal_b) |-> (mantissa_b_aligned == mantissa_b && (mantissa_a_aligned == (mantissa_a >> (exponent_b - exponent_a))));
endproperty
assert property (p_align_a_norm) else $error("ALIGN_A_NORM failed");

// ALIGN_A_SUBNORM
property p_align_a_subnorm;
  (is_subnormal_a && !is_subnormal_b && !is_zero_b && !is_special_b) |-> (mantissa_b_aligned == mantissa_b && (mantissa_a_aligned ==  (mantissa_a >> ((exponent_b - exponent_a) - 1))));
endproperty
assert property (p_align_a_subnorm) else $error("ALIGN_A_SUBNORM failed");

// ALIGN_B_NORM
property p_align_b_norm;
  ((exponent_a > exponent_b) && !is_subnormal_a && !is_subnormal_b) |-> (mantissa_a_aligned == mantissa_a && (mantissa_b_aligned == (mantissa_b >> (exponent_a - exponent_b))));
endproperty
assert property (p_align_b_norm) else $error("ALIGN_B_NORM failed");

// ALIGN_B_SUBNORM
property p_align_b_subnorm;
  (!is_subnormal_a && is_subnormal_b && !is_zero_a && !is_special_a) |-> (mantissa_a_aligned == mantissa_a && (mantissa_b_aligned ==  (mantissa_b >> ((exponent_a - exponent_b) - 1))));
endproperty
assert property (p_align_b_subnorm) else $error("ALIGN_B_SUBNORM failed");

// ALIGN_SUBNORMAL
property p_align_subnormal;
  (is_subnormal_a && is_subnormal_b) |-> ((mantissa_b_aligned == mantissa_b) && (mantissa_a_aligned == mantissa_a));
endproperty
assert property (p_align_subnormal) else $error("ALIGN_SUBNORMAL failed");

// ALIGN_EXP_NORMAL
property p_align_exp_normal;
  (!(is_subnormal_a || is_subnormal_b) && !is_special_a && !is_special_b) |-> (exponent_common == ((exponent_a > exponent_b) ? exponent_a : exponent_b));
endproperty
assert property (p_align_exp_normal) else $error("ALIGN_EXP_NORMAL failed");

// ALIGN_EXP_SUBNORMAL
property p_align_exp_subnormal;
  (is_subnormal_a && is_subnormal_b) |-> (exponent_common == 8'd0);
endproperty
assert property (p_align_exp_subnormal) else $error("ALIGN_EXP_SUBNORMAL failed");

// SUMA (same sign)
property p_suma;
  (sign_a == sign_b) |-> ((mantissa_sum == mantissa_a_aligned + mantissa_b_aligned) && (result_sign == sign_b));
endproperty
assert property (p_suma) else $error("SUMA failed");

// SUMA_RESTA_A_MAYOR
property p_suma_resta_a_mayor;
  ((sign_a != sign_b) && (mantissa_a_aligned > mantissa_b_aligned)) |-> ((mantissa_sum == (mantissa_a_aligned - mantissa_b_aligned)) && (result_sign == sign_a));
endproperty
assert property (p_suma_resta_a_mayor) else $error("SUMA_RESTA_A_MAYOR failed");

// SUMA_RESTA_B_MAYOR
property p_suma_resta_b_mayor;
  ((sign_a != sign_b) && (mantissa_b_aligned > mantissa_a_aligned)) |-> ((mantissa_sum == (mantissa_b_aligned - mantissa_a_aligned)) && (result_sign == sign_b));
endproperty
assert property (p_suma_resta_b_mayor) else $error("SUMA_RESTA_B_MAYOR failed");

// SUMA_RESTA_IGUALES
property p_suma_resta_iguales;
  (sign_a != sign_b && (mantissa_a_aligned == mantissa_b_aligned)) |-> ((mantissa_sum == 0) && (result_sign == 0));
endproperty
assert property (p_suma_resta_iguales) else $error("SUMA_RESTA_IGUALES failed");

// NORM_CARRY_EXPO
property p_norm_carry_expo;
  (mantissa_sum[24] && !is_subnormal_a && !is_subnormal_b) |-> (exponent_out == exponent_common + 1);
endproperty
assert property (p_norm_carry_expo) else $error("NORM_CARRY_EXPO failed");

// NORM_CARRY_EXPO_SUB
property p_norm_carry_expo_sub;
  (mantissa_sum[23] && (exponent_common == 8'b0) && (mantissa_sum != 0)) |-> (exponent_out == exponent_common + 1);
endproperty
assert property (p_norm_carry_expo_sub) else $error("NORM_CARRY_EXPO_SUB failed");

// NORM_CARRY_MANTISSA
property p_norm_carry_mantissa;
  (mantissa_sum[24] && !is_subnormal_a && !is_subnormal_b) |-> (mantissa_ext == {mantissa_sum,1'b0,1'b0});
endproperty
assert property (p_norm_carry_mantissa) else $error("NORM_CARRY_MANTISSA failed");

// NORM_CARRY_MANTISSA_SUBN
property p_norm_carry_mantissa_subn;
  (mantissa_sum[23] && (exponent_common == 8'b0) && (mantissa_sum != 0)) |-> (mantissa_ext[25:3] == mantissa_sum[23:0]);
endproperty
assert property (p_norm_carry_mantissa_subn) else $error("NORM_CARRY_MANTISSA_SUBN failed");

// NORM_SHIFT_MANTISSA_NORMALES
property p_norm_shift_mantissa_normales;
  ((mantissa_sum != 0) && (!mantissa_sum[24]) && (!mantissa_sum[23]) && (exponent_common > shift_amount)) |-> (mantissa_ext[26:3] == (mantissa_sum[23:0] << shift_amount));
endproperty
assert property (p_norm_shift_mantissa_normales) else $error("NORM_SHIFT_MANTISSA_NORMALES failed");

// NORM_SHIFT_EXPO_NORMALES
property p_norm_shift_expo_normales;
  ((mantissa_sum != 0) && (!mantissa_sum[24]) && (!mantissa_sum[23]) && (exponent_common > shift_amount)) |-> (exponent_out == exponent_common - shift_amount);
endproperty
assert property (p_norm_shift_expo_normales) else $error("NORM_SHIFT_EXPO_NORMALES failed");

// NORM_SHIFT_MANTISSA_NORM_A_SUBN
property p_norm_shift_mantissa_norm_to_subn;
  ((mantissa_sum != 0) && (!mantissa_sum[24]) && (!mantissa_sum[23]) && (exponent_common > 0) && (exponent_common <= shift_amount)) |-> (mantissa_ext[25:3] == (mantissa_sum[23:0] << exponent_common));
endproperty
assert property (p_norm_shift_mantissa_norm_to_subn) else $error("NORM_SHIFT_MANTISSA_NORM_A_SUBN failed");

// NORM_SHIFT_EXPO_NORM_A_SUBN
property p_norm_shift_expo_norm_to_subn;
  ((mantissa_sum != 0) && (!mantissa_sum[24]) && (!mantissa_sum[23]) && (exponent_common > 0) && (exponent_common <= shift_amount)) |-> (exponent_out == 8'd0);
endproperty
assert property (p_norm_shift_expo_norm_to_subn) else $error("NORM_SHIFT_EXPO_NORM_A_SUBN failed");

// NORM_SHIFT_MANTISSA_SUBN
property p_norm_shift_mantissa_subn;
  ((mantissa_sum != 0) && (!mantissa_sum[24]) && (!mantissa_sum[23]) && (exponent_common == 8'b0)) |-> (mantissa_ext[25:3] == mantissa_sum[23:0]);
endproperty
assert property (p_norm_shift_mantissa_subn) else $error("NORM_SHIFT_MANTISSA_SUBN failed");

// NORM_SHIFT_EXPO_SUBN
property p_norm_shift_expo_subn;
  ((mantissa_sum != 0) && (!mantissa_sum[24]) && (!mantissa_sum[23]) && (exponent_common == 8'b0)) |-> (exponent_out == exponent_common);
endproperty
assert property (p_norm_shift_expo_subn) else $error("NORM_SHIFT_EXPO_SUBN failed");

// ROUND RNE
property p_round_rnz;
  (r_mode == 3'b000) |-> (mantissa_rounded == mantissa_r_rnz);
endproperty
assert property (p_round_rnz) else $error("ROUND_RNZ failed");

// ROUND RTZ
property p_round_rtz;
  (r_mode == 3'b001) |-> (mantissa_rounded == mantissa_r_rtz);
endproperty
assert property (p_round_rtz) else $error("ROUND_RTZ failed");

// ROUND RDN
property p_round_rdn;
  (r_mode == 3'b010) |-> (mantissa_rounded == mantissa_r_rdn);
endproperty
assert property (p_round_rdn) else $error("ROUND_RDN failed");

// ROUND RUP
property p_round_rup;
  (r_mode == 3'b011) |-> (mantissa_rounded == mantissa_r_rup);
endproperty
assert property (p_round_rup) else $error("ROUND_RUP failed");

// ROUND RMM
property p_round_rmm;
  (r_mode == 3'b100) |-> (mantissa_rounded == mantissa_r_rmm);
endproperty
assert property (p_round_rmm) else $error("ROUND_RMM failed");

// ROUND_CARRY
property p_round_carry;
  (carry_out) |-> ((carry_calc[23]) && (mantissa_rounded == (mantissa_ext[25:3] + 1'b1)));
endproperty
assert property (p_round_carry) else $error("ROUND_CARRY failed");

// FP_PACK (check packing)
property p_fp_pack;
  fp_result_wire == {result_sign, exponent_final, mantissa_rounded};
endproperty
assert property (p_fp_pack) else $error("FP_PACK failed");

// PRUEBAS dirigidas: convertir a cover o keep como asserts concretos (a criterio)
property p_prueba_sub;
  (fp_a == 32'h000a0000 && fp_b == 32'h000a0000 && r_mode == 3'b001) |-> (fp_result == 32'h00140000);
endproperty
assert property (p_prueba_sub) else $error("PRUEBA_SUB failed");

property p_prueba_sub_norm;
  (fp_a == 32'h01000000 && fp_b == 32'h00300000 && r_mode == 3'b001) |-> (fp_result == 32'h01180000);
endproperty
assert property (p_prueba_sub_norm) else $error("PRUEBA_SUB_NORM failed");

property p_prueba_norm_norm;
  (fp_a == 32'h14300000 && fp_b == 32'h1FC00000 && r_mode == 3'b001) |-> (fp_result == 32'h1FC00001);
endproperty
assert property (p_prueba_norm_norm) else $error("PRUEBA_NORM_NORM failed");

endmodule
