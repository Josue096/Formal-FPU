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

//Pack
  input logic [7:0]   exponent_final,
  input logic         overflow_internal,
  input logic [31:0]  fp_result_wire
);

// -------------------------------------------------------
// Clock artificial para evaluación de SVA (solo checker)
// -------------------------------------------------------
logic clk;
initial clk = 0;
always #1 clk = ~clk;

// -------------------------------------------------------
// Clock por defecto para TODAS las properties del módulo
// -------------------------------------------------------
default clocking cb @ (posedge clk);
endclocking

// ------------------------------
// Señales muestreadas (s_*) sincronizadas al clk
// ------------------------------
logic [31:0] s_fp_a, s_fp_b, s_fp_result, s_fp_result_wire;
logic [2:0]  s_r_mode;
logic        s_overflow, s_underflow, s_overflow_internal;

logic        s_sign_a, s_sign_b, s_result_sign;
logic [7:0]  s_exponent_a, s_exponent_b, s_exponent_common, s_exponent_out, s_exponent_final;
logic [23:0] s_mantissa_a, s_mantissa_b, s_mantissa_a_aligned, s_mantissa_b_aligned;
logic        s_is_special_a, s_is_special_b, s_is_subnormal_a, s_is_subnormal_b, s_is_zero_a, s_is_zero_b;
logic [24:0] s_mantissa_sum;
logic [26:0] s_mantissa_ext;
logic [22:0] s_mantissa_rounded;
logic        s_carry_out;

// ------------------------------
// Señales auxiliares muestreadas / calculadas
// ------------------------------
logic [7:0] s_expo_diff_ab;
logic [7:0] s_expo_diff_ba;
logic [7:0] s_shift_amount;
logic [22:0] s_mantissa_r;
logic [23:0] s_carry; // used in ROUND_CARRY property

// Muestreo síncrono de todas las entradas relevantes
always_ff @(posedge clk) begin
  s_fp_a            <= fp_a;
  s_fp_b            <= fp_b;
  s_r_mode          <= r_mode;
  s_fp_result       <= fp_result;
  s_overflow        <= overflow;
  s_underflow       <= underflow;

  s_sign_a          <= sign_a;
  s_sign_b          <= sign_b;
  s_exponent_a      <= exponent_a;
  s_exponent_b      <= exponent_b;
  s_mantissa_a      <= mantissa_a;
  s_mantissa_b      <= mantissa_b;
  s_is_special_a    <= is_special_a;
  s_is_special_b    <= is_special_b;
  s_is_subnormal_a  <= is_subnormal_a;
  s_is_subnormal_b  <= is_subnormal_b;
  s_is_zero_a       <= is_zero_a;
  s_is_zero_b       <= is_zero_b;

  s_mantissa_a_aligned <= mantissa_a_aligned;
  s_mantissa_b_aligned <= mantissa_b_aligned;
  s_exponent_common    <= exponent_common;

  s_result_sign     <= result_sign;
  s_mantissa_sum    <= mantissa_sum;

  s_exponent_out    <= exponent_out;
  s_mantissa_ext    <= mantissa_ext;

  s_mantissa_rounded <= mantissa_rounded;
  s_carry_out        <= carry_out;

  s_exponent_final   <= exponent_final;
  s_overflow_internal<= overflow_internal;
  s_fp_result_wire   <= fp_result_wire;
end

// Calculitos sobre señales muestreadas (combinacional)
assign s_expo_diff_ab = s_exponent_b - s_exponent_a;
assign s_expo_diff_ba = s_exponent_a - s_exponent_b;
assign s_shift_amount  = leading_zero_count(s_mantissa_sum[23:0]);
assign s_carry = {1'b0, s_mantissa_ext[25:3]} + 1'b1;

// Para mantener exactamente tu lógica de mantissa_r (la dejé aquí "combinacionalmente derivada")
// Nota: no cambio las reglas de redondeo — las properties comparan contra s_mantissa_r calculada así.
// Emulo el mismo comportamiento de tus case usando una combinacional-block que asigna s_mantissa_r
always_comb begin
  // default
  s_mantissa_r = s_mantissa_ext[25:3];

  // ROUND_RNZ: (mantissa_ext[2], |mantissa_ext[1:0])
  unique case ({s_mantissa_ext[2], (|s_mantissa_ext[1:0])})
    2'b00: s_mantissa_r = s_mantissa_ext[25:3];
    2'b01: s_mantissa_r = s_mantissa_ext[25:3];
    2'b10: s_mantissa_r = s_mantissa_ext[3] ? s_mantissa_ext[25:3] + 1'b1 : s_mantissa_ext[25:3];
    2'b11: s_mantissa_r = s_mantissa_ext[25:3] + 1'b1;
  endcase

  // ROUND_RDN (uses result_sign)
  // but we don't override s_mantissa_r here unconditionally — properties will compare against s_mantissa_r
  // You had several case blocks in the original always_comb; we emulate only the final s_mantissa_r result
  // (The properties still compare mantissa_rounded == mantissa_r for the given r_mode)
end

// ------------------------------
// PROPERTIES (usando señales muestreadas, s_*)
// ------------------------------

// ----------------------------------------------------------
// Caso de esquina
// ----------------------------------------------------------
property ZERO_SUM_p;
  (s_fp_a == 32'h00000000 && s_fp_b == 32'h00000000) |-> 
  (s_fp_result == 32'h00000000 && s_overflow == 0 && s_underflow == 0);
endproperty
ZERO_SUM: assert property (ZERO_SUM_p);

// ----------------------------------------------------------
// FP UNPACK
// ----------------------------------------------------------
property FP_UNPACK_A_p;
  ((s_fp_a[30:23] != 8'hFF) && (s_fp_a[30:0] != 31'd0)) |-> 
  ((s_sign_a == s_fp_a[31]) && (s_exponent_a == s_fp_a[30:23]) && (s_mantissa_a == {1'b1, s_fp_a[22:0]}));
endproperty
FP_UNPACK_A: assert property(FP_UNPACK_A_p);

property FP_UNPACK_B_p;
  ((s_fp_b[30:23] != 8'hFF) && (s_fp_b[30:0] != 31'd0)) |-> 
  ((s_sign_b == s_fp_b[31]) && (s_exponent_b == s_fp_b[30:23]) && (s_mantissa_b == {1'b1, s_fp_b[22:0]}));
endproperty
FP_UNPACK_B: assert property(FP_UNPACK_B_p);

// ----------------------------------------------------------
// SPECIALS
// ----------------------------------------------------------
property FP_UNPACK_A_SPECIAL_p;
  (s_fp_a[30:23] == 8'hFF) |-> 
  ((s_sign_a == s_fp_a[31]) && (s_exponent_a == 8'hFF) && (s_mantissa_a == {1'b0, s_fp_a[22:0]}) && s_is_special_a);
endproperty
FP_UNPACK_A_SPECIAL: assert property(FP_UNPACK_A_SPECIAL_p);

property FP_UNPACK_B_SPECIAL_p;
  (s_fp_b[30:23] == 8'hFF) |-> 
  ((s_sign_b == s_fp_b[31]) && (s_exponent_b == 8'hFF) && (s_mantissa_b == {1'b0, s_fp_b[22:0]}) && s_is_special_b);
endproperty
FP_UNPACK_B_SPECIAL: assert property(FP_UNPACK_B_SPECIAL_p);

// ----------------------------------------------------------
// ZEROS
// ----------------------------------------------------------
property FP_UNPACK_A_ZERO_p;
  (s_fp_a[30:0] == 31'b0) |-> (s_is_zero_a == 1);
endproperty
FP_UNPACK_A_ZERO: assert property(FP_UNPACK_A_ZERO_p);

property FP_UNPACK_B_ZERO_p;
  (s_fp_b[30:0] == 31'b0) |-> (s_is_zero_b == 1);
endproperty
FP_UNPACK_B_ZERO: assert property(FP_UNPACK_B_ZERO_p);

// ----------------------------------------------------------
// ALINEAMIENTO
// ----------------------------------------------------------
property ALIGN_A_NORM_p;
  ((s_exponent_b > s_exponent_a) && !s_is_subnormal_a && !s_is_subnormal_b) |->
  ((s_mantissa_b_aligned == s_mantissa_b) && (s_mantissa_a_aligned == s_mantissa_a >> s_expo_diff_ab));
endproperty
ALIGN_A_NORM: assert property (ALIGN_A_NORM_p);

property ALIGN_A_SUBNORM_p;
  (s_is_subnormal_a && !s_is_subnormal_b && !s_is_zero_b && !s_is_special_b) |->
  ((s_mantissa_b_aligned == s_mantissa_b) && (s_mantissa_a_aligned == s_mantissa_a >> (s_expo_diff_ab - 1)));
endproperty
ALIGN_A_SUBNORM: assert property (ALIGN_A_SUBNORM_p);

property ALIGN_B_NORM_p;
  ((s_exponent_a > s_exponent_b) && !s_is_subnormal_a && !s_is_subnormal_b) |->
  ((s_mantissa_a_aligned == s_mantissa_a) && (s_mantissa_b_aligned == s_mantissa_b >> s_expo_diff_ba));
endproperty
ALIGN_B_NORM: assert property (ALIGN_B_NORM_p);

property ALIGN_B_SUBNORM_p;
  (!s_is_subnormal_a && s_is_subnormal_b && !s_is_zero_a && !s_is_special_a) |->
  ((s_mantissa_a_aligned == s_mantissa_a) && (s_mantissa_b_aligned == s_mantissa_b >> (s_expo_diff_ba - 1)));
endproperty
ALIGN_B_SUBNORM: assert property (ALIGN_B_SUBNORM_p);

property ALIGN_SUBNORMAL_p;
  (s_is_subnormal_a && s_is_subnormal_b) |->
  ((s_mantissa_b_aligned == s_mantissa_b) && (s_mantissa_a_aligned == s_mantissa_a));
endproperty
ALIGN_SUBNORMAL: assert property(ALIGN_SUBNORMAL_p);

property ALIGN_EXP_NORMAL_p;
  (!(s_is_subnormal_a || s_is_subnormal_b) && !s_is_special_a && !s_is_special_b) |->
  (s_exponent_common == ((s_exponent_a > s_exponent_b) ? s_exponent_a : s_exponent_b));
endproperty
ALIGN_EXP_NORMAL: assert property(ALIGN_EXP_NORMAL_p);

property ALIGN_EXP_SUBNORMAL_p;
  (s_is_subnormal_a && s_is_subnormal_b) |-> (s_exponent_common == 8'd0);
endproperty
ALIGN_EXP_SUBNORMAL: assert property (ALIGN_EXP_SUBNORMAL_p);

// ----------------------------------------------------------
// SUMA / RESTA
// ----------------------------------------------------------
property SUMA_p;
  (s_sign_a == s_sign_b) |->
  ((s_mantissa_sum == s_mantissa_a_aligned + s_mantissa_b_aligned) && (s_result_sign == s_sign_b));
endproperty
SUMA: assert property(SUMA_p);

property SUMA_RESTA_A_MAYOR_p;
  ((s_sign_a != s_sign_b) && (s_mantissa_a_aligned > s_mantissa_b_aligned)) |->
  ((s_mantissa_sum == (s_mantissa_a_aligned - s_mantissa_b_aligned)) && (s_result_sign == s_sign_a));
endproperty
SUMA_RESTA_A_MAYOR: assert property(SUMA_RESTA_A_MAYOR_p);

property SUMA_RESTA_B_MAYOR_p;
  ((s_sign_a != s_sign_b) && (s_mantissa_b_aligned > s_mantissa_a_aligned)) |->
  ((s_mantissa_sum == (s_mantissa_b_aligned - s_mantissa_a_aligned)) && (s_result_sign == s_sign_b));
endproperty
SUMA_RESTA_B_MAYOR: assert property(SUMA_RESTA_B_MAYOR_p);

property SUMA_RESTA_IGUALES_p;
  ((s_sign_a != s_sign_b) && (s_mantissa_a_aligned == s_mantissa_b_aligned)) |->
  ((s_mantissa_sum == 0) && (s_result_sign == 0));
endproperty
SUMA_RESTA_IGUALES: assert property(SUMA_RESTA_IGUALES_p);

// ----------------------------------------------------------
// NORMALIZE
// ----------------------------------------------------------
property NORM_CARRY_EXPO_p;
  (s_mantissa_sum[24] && !s_is_subnormal_a && !s_is_subnormal_b) |-> (s_exponent_out == s_exponent_common + 1);
endproperty
NORM_CARRY_EXPO: assert property(NORM_CARRY_EXPO_p);

property NORM_CARRY_EXPO_SUB_p;
  (s_mantissa_sum[23] && s_exponent_common == 8'b0 && s_mantissa_sum != 0) |-> (s_exponent_out == s_exponent_common + 1);
endproperty
NORM_CARRY_EXPO_SUB: assert property(NORM_CARRY_EXPO_SUB_p);

property NORM_CARRY_MANTISSA_p;
  (s_mantissa_sum[24] && !s_is_subnormal_a && !s_is_subnormal_b) |-> (s_mantissa_ext == {s_mantissa_sum, 1'b0, 1'b0});
endproperty
NORM_CARRY_MANTISSA: assert property(NORM_CARRY_MANTISSA_p);

property NORM_CARRY_MANTISSA_SUBN_p;
  (s_mantissa_sum[23] && s_exponent_common == 8'b0 && s_mantissa_sum != 0) |-> (s_mantissa_ext[25:3] == s_mantissa_sum[23:0]);
endproperty
NORM_CARRY_MANTISSA_SUBN: assert property(NORM_CARRY_MANTISSA_SUBN_p);

// ----------------------------------------------------------
// SHIFT NORMAL
// ----------------------------------------------------------
property NORM_SHIFT_MANTISSA_NORMALES_p;
  (s_mantissa_sum != 0 && !s_mantissa_sum[24] && !s_mantissa_sum[23] && (s_exponent_common > s_shift_amount)) |->
  (s_mantissa_ext[26:3] == (s_mantissa_sum[23:0] << s_shift_amount));
endproperty
NORM_SHIFT_MANTISSA_NORMALES: assert property(NORM_SHIFT_MANTISSA_NORMALES_p);

property NORM_SHIFT_EXPO_NORMALES_p;
  (s_mantissa_sum != 0 && !s_mantissa_sum[24] && !s_mantissa_sum[23] && (s_exponent_common > s_shift_amount)) |->
  (s_exponent_out == s_exponent_common - s_shift_amount);
endproperty
NORM_SHIFT_EXPO_NORMALES: assert property(NORM_SHIFT_EXPO_NORMALES_p);

// ----------------------------------------------------------
// NORM → SUBNORM
// ----------------------------------------------------------
property NORM_SHIFT_MANTISSA_NORM_A_SUBN_p;
  (s_mantissa_sum != 0 && !s_mantissa_sum[24] && !s_mantissa_sum[23] && s_exponent_common > 0 && s_exponent_common <= s_shift_amount) |->
  (s_mantissa_ext[25:3] == (s_mantissa_sum[23:0] << s_exponent_common));
endproperty
NORM_SHIFT_MANTISSA_NORM_A_SUBN: assert property(NORM_SHIFT_MANTISSA_NORM_A_SUBN_p);

property NORM_SHIFT_EXPO_NORM_A_SUBN_p;
  (s_mantissa_sum != 0 && !s_mantissa_sum[24] && !s_mantissa_sum[23] && s_exponent_common > 0 && s_exponent_common <= s_shift_amount) |->
  (s_exponent_out == 0);
endproperty
NORM_SHIFT_EXPO_NORM_A_SUBN: assert property(NORM_SHIFT_EXPO_NORM_A_SUBN_p);

// ----------------------------------------------------------
// SUBNORMAL → SUBNORMAL
// ----------------------------------------------------------
property NORM_SHIFT_MANTISSA_SUBN_p;
  (s_mantissa_sum != 0 && !s_mantissa_sum[24] && !s_mantissa_sum[23] && s_exponent_common == 8'b0) |->
  (s_mantissa_ext[25:3] == s_mantissa_sum[23:0]);
endproperty
NORM_SHIFT_MANTISSA_SUBN: assert property(NORM_SHIFT_MANTISSA_SUBN_p);

property NORM_SHIFT_EXPO_SUBN_p;
  (s_mantissa_sum != 0 && !s_mantissa_sum[24] && !s_mantissa_sum[23] && s_exponent_common == 8'b0) |->
  (s_exponent_out == s_exponent_common);
endproperty
NORM_SHIFT_EXPO_SUBN: assert property(NORM_SHIFT_EXPO_SUBN_p);

// ----------------------------------------------------------
// ROUNDING
// ----------------------------------------------------------
property ROUND_RNZ_p;
  (s_r_mode == 3'b000) |-> (s_mantissa_rounded == s_mantissa_r);
endproperty
ROUND_RNZ: assert property(ROUND_RNZ_p);

property ROUND_RTZ_p;
  (s_r_mode == 3'b001) |-> (s_mantissa_rounded == s_mantissa_ext[25:3]);
endproperty
ROUND_RTZ: assert property(ROUND_RTZ_p);

property ROUND_RDN_p;
  (s_r_mode == 3'b010) |-> (s_mantissa_rounded == s_mantissa_r);
endproperty
ROUND_RDN: assert property(ROUND_RDN_p);

property ROUND_RUP_p;
  (s_r_mode == 3'b011) |-> (s_mantissa_rounded == s_mantissa_r);
endproperty
ROUND_RUP: assert property(ROUND_RUP_p);

property ROUND_RMM_p;
  (s_r_mode == 3'b100) |-> (s_mantissa_rounded == s_mantissa_r);
endproperty
ROUND_RMM: assert property(ROUND_RMM_p);

property ROUND_CARRY_p;
  (s_carry_out) |-> (s_carry[23] && (s_mantissa_rounded == s_mantissa_ext[25:3] + 1'b1));
endproperty
ROUND_CARRY: assert property(ROUND_CARRY_p);

// ----------------------------------------------------------
// PACK
// ----------------------------------------------------------
property FP_PACK_p;
  s_fp_result_wire == {s_result_sign, s_exponent_final, s_mantissa_rounded};
endproperty
FP_PACK: assert property(FP_PACK_p);

// ----------------------------------------------------------
// PRUEBAS
// ----------------------------------------------------------
property PRUEBA_SUB_p;
  ((s_fp_a == 32'h000a0000) && (s_fp_b == 32'h000a0000) && (s_r_mode == 3'b001)) |-> (s_fp_result == 32'h00140000);
endproperty
PRUEBA_SUB: assert property(PRUEBA_SUB_p);

property PRUEBA_SUB_NORM_p;
  ((s_fp_a == 32'h01000000) && (s_fp_b == 32'h00300000) && (s_r_mode == 3'b001)) |-> (s_fp_result == 32'h01180000);
endproperty
PRUEBA_SUB_NORM: assert property(PRUEBA_SUB_NORM_p);

property PRUEBA_NORM_NORM_p;
  ((s_fp_a == 32'h14300000) && (s_fp_b == 32'h1FC00000) && (s_r_mode == 3'b001)) |-> (s_fp_result == 32'h1FC00001);
endproperty
PRUEBA_NORM_NORM: assert property(PRUEBA_NORM_NORM_p);

// ----------------------------------------------------------
// FUNCTION (unchanged)
// ----------------------------------------------------------
function automatic [7:0] leading_zero_count(input logic [23:0] value);
  leading_zero_count = 0;
  for (int i = 23; i >= 0; i--) begin
    if (value[i]) begin
      leading_zero_count = 8'(23 - i);
      break;
    end
  end
endfunction

endmodule
