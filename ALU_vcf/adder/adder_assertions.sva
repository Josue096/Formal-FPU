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

  always_comb begin

  // 0 + 0 = 0
    ZERO_SUM: assert ((fp_a == 32'h00000000 && fp_b == 32'h00000000) ->
                (fp_result == 32'h00000000 && overflow == 0 && underflow == 0));
  
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  //fp_unpack de cada valor es el correcto
    FP_UNPACK_A: assert (((fp_a[30:23] != 8'hFF) && (fp_a[30:0] != 31'd0)) ->
                ((sign_a == fp_a[31]) && (exponent_a == fp_a[30:23]) && (mantissa_a == {|fp_a[30:23], fp_a[22:0]})));
  
    FP_UNPACK_B: assert (((fp_b[30:23] != 8'hFF) && (fp_b[30:0] != 31'd0)) ->
                ((sign_b == fp_b[31]) && (exponent_b == fp_b[30:23]) && (mantissa_b == {|fp_b[30:23], fp_b[22:0]})));
  
    FP_UNPACK_A_SPECIAL: assert ((fp_a[30:23] == 8'hFF) ->
                ((sign_a == fp_a[31]) && (exponent_a == 8'hFF) && (mantissa_a == {1'b0, fp_a[22:0]}) && is_special_a));
  
    FP_UNPACK_B_SPECIAL: assert ((fp_b[30:23] == 8'hFF) ->
                ((sign_b == fp_b[31]) && (exponent_b == 8'hFF) && (mantissa_b == {1'b0, fp_b[22:0]}) && is_special_b));
    
    FP_UNPACK_A_ZERO: assert ((fp_a[30:0] == 31'b0) ->
                (is_zero_a == 1));

    FP_UNPACK_B_ZERO: assert ((fp_b[30:0] == 31'b0) ->
                (is_zero_b == 1));
  
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // mantissa_a alineada si exponent_b > exponent_a

  expo_diff = (is_subnormal_a) ? 1 : exponent_b - exponent_a;

    ALIGN_A: assert (((exponent_b > exponent_a) &&  !is_zero_a && !is_zero_a)->
                (mantissa_b_aligned == mantissa_b && (mantissa_a_aligned == (mantissa_a >> expo_diff))));

  // mantissa_b alineada si exponent_a > exponent_b
    ALIGN_B: assert (((exponent_a > exponent_b) &&  !is_zero_a && !is_zero_a)->
                (mantissa_a_aligned == mantissa_a && (mantissa_b_aligned == (mantissa_b >> (exponent_a - (exponent_b == 8'b0) ? 1 : exponent_b)))));

    ALIGN_NORMAL: assert (((exponent_b > exponent_a) && !(is_subnormal_a || is_subnormal_b)) ->
                (mantissa_a_aligned == (mantissa_a >> (exponent_b - exponent_a))));

    ALIGN_SUBNORMAL: assert ((is_subnormal_a && is_subnormal_b) -> 
                (mantissa_a_aligned) == mantissa_a); 

  // exponente resultante es el máximo
    ALIGN_EXP_NORMAL: assert (!(is_subnormal_a && is_subnormal_b) -> 
                (exponent_common) == ((exponent_a > exponent_b) ? exponent_a : exponent_b));

  // exponente en ambos numeros subnormales
    ALIGN_EXP_SUBNORMAL: assert ((is_subnormal_a && is_subnormal_b) -> 
                (exponent_common) == 8'd1);
  
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  //Suma de mantisas
    SUMA: assert ((sign_a == sign_b) -> 
                ((mantissa_sum == mantissa_a_aligned + mantissa_b_aligned) && (result_sign == sign_b)));
  
  //Resta de mantisas
    SUMA_RESTA_A_MAYOR: assert (((sign_a != sign_b) && (mantissa_a_aligned > mantissa_b_aligned))  -> 
                ((mantissa_sum == (mantissa_a_aligned - mantissa_b_aligned) && (result_sign == sign_a))));

    SUMA_RESTA_B_MAYOR: assert (((sign_a != sign_b) && (mantissa_b_aligned > mantissa_a_aligned))  -> 
                ((mantissa_sum == (mantissa_b_aligned - mantissa_a_aligned) && (result_sign == sign_b))));
  
    SUMA_RESTA_IGUALES: assert ((sign_a != sign_b && (mantissa_a_aligned == mantissa_b_aligned)) -> 
                ((mantissa_sum == 0) && (result_sign == 0)));// solo por que samuel lo define asi, no se si por norma esa asi
  
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  shift_amount = leading_zero_count(mantissa_sum[23:0]); //calculo util para saber cuanto dezplazamiento en caso de shift

  //Si hay carry de la suma ajusta la mantizza
    NORM_CARRY_EXPO: assert ((mantissa_sum[24]) -> 
                ((exponent_out == exponent_common + 1)));
  
  //Si hay carry de la suma aumneta exponente en normalize
    NORM_CARRY_MANTISSA: assert ((mantissa_sum[24]) -> 
                ((mantissa_ext == {mantissa_sum,1'b0,1'b0})));  //{1'b0,mantissa_sum,1'b0}  

  //ajuste normalize poner el primer 1 con shift a la derecha
    NORM_SHIFT_MANTISSA_NORMALES: assert (((mantissa_sum != 0) 
                                && (!mantissa_sum[24]) 
                                && (exponent_common > shift_amount)) ->
                (mantissa_ext[26:3] == (mantissa_sum[23:0]<<shift_amount)));
  
    NORM_SHIFT_MANTISSA_NORM_A_SUBN: assert (((mantissa_sum != 0)
                                && (!mantissa_sum[24]) 
                                && (exponent_common <= shift_amount)
                                && (exponent_a > 0)
                                && (exponent_b > 0)) ->
                mantissa_ext[26:3] == mantissa_sum[23:0] << (exponent_common - 1));

    NORM_SHIFT_MANTISSA_SUBNORMAL: assert (((mantissa_sum != 0)
                                && (!mantissa_sum[24]) 
                                && (exponent_common <= shift_amount)
                                && (exponent_a == 0)
                                && (exponent_b == 0)) ->
                mantissa_ext[26:3] == mantissa_sum[23:0]);
  
    NORM_SHIFT_EXPO_NORMALES: assert (((mantissa_sum != 0) 
                                && (!mantissa_sum[24]) 
                                && (exponent_common > shift_amount)) ->
                ((exponent_out == exponent_common - shift_amount)));

    NORM_SHIFT_EXPO_SUBNORMALES: assert (((mantissa_sum != 0) 
                                && (!mantissa_sum[24]) 
                                && (exponent_common <= shift_amount)) ->
                ((exponent_out == 0)));  

    NORM_SHIFT_EXPO_NORM_A_SUBNORM: assert (((mantissa_sum != 0)
                                && (!mantissa_sum[24])  
                                && (exponent_common > 0) 
                                && (exponent_common <= shift_amount)) ->
                ((exponent_out == 0)));

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case ({mantissa_ext[2],(|mantissa_ext[1:0])})
      2'b00: mantissa_r = mantissa_ext[25:3];   
      2'b01: mantissa_r = mantissa_ext[25:3]; 
      2'b10: mantissa_r = mantissa_ext[3] ? mantissa_ext[25:3] + 1'b1 : mantissa_ext[25:3]; //si es impar redondea para arriba
      2'b11: mantissa_r = mantissa_ext[25:3] + 1'b1;
    //default: mantissa_r = mantissa_ext[25:3];
    endcase
    
    ROUND_RNZ: assert ((r_mode == 3'b000) -> mantissa_rounded == mantissa_r);

    ROUND_RTZ: assert ((r_mode == 3'b001) -> mantissa_rounded == mantissa_ext[25:3]);

    case (result_sign)
      1'b0: mantissa_r = mantissa_ext[25:3];   
      1'b1: mantissa_r = mantissa_ext[25:3] + 1'b1; 
    //default: mantissa_r = mantissa_ext[25:3];
    endcase 

    ROUND_RDN: assert ((r_mode == 3'b010) -> mantissa_rounded == mantissa_r);

    case (result_sign)
      1'b0: mantissa_r = mantissa_ext[25:3] + 1'b1;   
      1'b1: mantissa_r = mantissa_ext[25:3]; 
    //default: mantissa_r = mantissa_ext[25:3];
    endcase    

    ROUND_RUP: assert ((r_mode == 3'b011) -> mantissa_rounded == mantissa_r);

    case (mantissa_ext[2])
      1'b0: mantissa_r = mantissa_ext[25:3];   
      1'b1: mantissa_r = mantissa_ext[25:3] + 1'b1; 
    //default: mantissa_r = mantissa_ext[25:3];
    endcase    

    ROUND_RMM: assert ((r_mode == 3'b100) -> mantissa_rounded == mantissa_r);

    carry = {1'b0, mantissa_ext[25:3]} + 1'b1;
    ROUND_CARRY: assert ((carry_out) -> ((carry [23]) && (mantissa_rounded == mantissa_ext[25:3] + 1'b1)));

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    FP_PACK : assert (fp_result_wire == {result_sign, exponent_final, mantissa_rounded});

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // 5 + 10 = 15 prueba de samuel
    Z_PRUEBA: assert ((fp_a == 32'h00080000 && fp_b == 32'h00080000 && r_mode == 3'b001) ->
                          (fp_result == 32'h00100000));
end  

  function automatic [7:0] leading_zero_count(input logic [23:0] value);
    begin
      leading_zero_count = 8'd0; // Inicializar el conteo en cero
      // Recorrer desde el bit más significativo (MSB = 23)
      for (int i = 23; i >= 0; i--) begin
      // Primer '1' encontrado: contar los ceros previos
        if (value[i]) begin
          leading_zero_count = 8'(23 - i);
          break;
        end
      end
    end
  endfunction
endmodule
