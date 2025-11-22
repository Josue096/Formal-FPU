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
  input logic [7:0]   exponent_final,
  input logic         overflow_internal,
  input logic [31:0]  fp_result_wire
);
  logic [7:0]  shift_amount;
  logic [22:0] mantissa_r;
  logic [23:0] carry;
  logic [7:0]  expo_diff;

  always_comb begin

    //Caso de esquina 0 + 0 = 0
    ZERO_SUM: assert ((fp_a == 32'h00000000 && fp_b == 32'h00000000) ->
                (fp_result == 32'h00000000 && overflow == 0 && underflow == 0));

    //fp_unpack de cada valor es el correcto
    FP_UNPACK_A: assert (((fp_a[30:23] != 8'hFF) && (fp_a[30:0] != 31'd0)) ->
                ((sign_a == fp_a[31]) && (exponent_a == fp_a[30:23]) && (mantissa_a == {|fp_a[30:23], fp_a[22:0]})));
    
    FP_UNPACK_B: assert (((fp_b[30:23] != 8'hFF) && (fp_b[30:0] != 31'd0)) ->
                ((sign_b == fp_b[31]) && (exponent_b == fp_b[30:23]) && (mantissa_b == {|fp_b[30:23], fp_b[22:0]})));

    //Identifica que un valor especial: NaN o INF
    FP_UNPACK_A_SPECIAL: assert ((fp_a[30:23] == 8'hFF) ->
                ((sign_a == fp_a[31]) && (exponent_a == 8'hFF) && (mantissa_a == {1'b0, fp_a[22:0]}) && is_special_a));
  
    FP_UNPACK_B_SPECIAL: assert ((fp_b[30:23] == 8'hFF) ->
                ((sign_b == fp_b[31]) && (exponent_b == 8'hFF) && (mantissa_b == {1'b0, fp_b[22:0]}) && is_special_b));
    
    //Identifica que un valor es cero
    FP_UNPACK_A_ZERO: assert ((fp_a[30:0] == 31'b0) ->
                (is_zero_a == 1));

    FP_UNPACK_B_ZERO: assert ((fp_b[30:0] == 31'b0) ->
                (is_zero_b == 1));
  
    //Mantissa_a necesita ser alineada si exponent_b > exponent_a casos normales
    expo_diff = (exponent_b - exponent_a);

    ALIGN_A_NORM: assert (((exponent_b > exponent_a) && !is_subnormal_a && !is_subnormal_b)->
                (mantissa_b_aligned == mantissa_b && (mantissa_a_aligned == mantissa_a >> (expo_diff))));

    //Mantissa_a necesita ser alineada si exponent_b > exponent_a casos subnormales
    ALIGN_A_SUBNORM: assert ((is_subnormal_a && !is_subnormal_b && !is_zero_b && !is_special_b)->
                (mantissa_b_aligned == mantissa_b && (mantissa_a_aligned ==  mantissa_a >> (expo_diff - 1))));

    //Mantissa_b necesita ser alineada si exponent_a > exponent_b casos normales
    expo_diff = (exponent_a - exponent_b);
    ALIGN_B_NORM: assert (((exponent_a > exponent_b)&& !is_subnormal_a && !is_subnormal_b)->
                (mantissa_a_aligned == mantissa_a && (mantissa_b_aligned == mantissa_b >> (expo_diff))));

    //Mantissa_b necesita ser alineada si exponent_a > exponent_b casos subnormales
    ALIGN_B_SUBNORM: assert ((!is_subnormal_a && is_subnormal_b && !is_zero_a && !is_special_a)->
                (mantissa_a_aligned == mantissa_a && (mantissa_b_aligned ==  mantissa_b >> (expo_diff - 1))));

    //Alineamiento cuando ambos son subnormales
    ALIGN_SUBNORMAL: assert ((is_subnormal_a && is_subnormal_b) -> 
                ((mantissa_b_aligned == mantissa_b) && (mantissa_a_aligned == mantissa_a))); 

    //El exponente resultante es el mayor
    ALIGN_EXP_NORMAL: assert ((!(is_subnormal_a || is_subnormal_b) && !is_special_a && !is_special_b) -> 
                (exponent_common) == ((exponent_a > exponent_b) ? exponent_a : exponent_b));

    //Exponente en ambos numeros subnormales
    ALIGN_EXP_SUBNORMAL: assert ((is_subnormal_a && is_subnormal_b) -> 
                (exponent_common) == 8'd0);

    //Suma de mantisas
    SUMA: assert ((sign_a == sign_b) -> 
                ((mantissa_sum == mantissa_a_aligned + mantissa_b_aligned) && (result_sign == sign_b)));
  
    //Resta de mantisas cuando es A mayor
    SUMA_RESTA_A_MAYOR: assert (((sign_a != sign_b) && (mantissa_a_aligned > mantissa_b_aligned))  -> 
                ((mantissa_sum == (mantissa_a_aligned - mantissa_b_aligned) && (result_sign == sign_a))));

    //Resta de mantisas cuando es A mayor
    SUMA_RESTA_B_MAYOR: assert (((sign_a != sign_b) && (mantissa_b_aligned > mantissa_a_aligned))  -> 
                ((mantissa_sum == (mantissa_b_aligned - mantissa_a_aligned) && (result_sign == sign_b))));
  
    //Resta de mantisas cuando es B mayor
    SUMA_RESTA_IGUALES: assert ((sign_a != sign_b && (mantissa_a_aligned == mantissa_b_aligned)) -> 
                ((mantissa_sum == 0) && (result_sign == 0))); //Solo por que samuel lo define asi, no se norma
  
    shift_amount = leading_zero_count(mantissa_sum[23:0]); //Calculo util para saber cuanto dezplazamiento en caso de shift

    //Si hay carry de la suma ajusta la mantizza
    NORM_CARRY_EXPO: assert ((mantissa_sum[24] && !is_subnormal_a && !is_subnormal_b) -> 
                ((exponent_out == exponent_common + 1)));

    //Carry si el bit implicito tambien es 1 en subnormales
    NORM_CARRY_EXPO_SUB: assert (( mantissa_sum[23] && (exponent_common == 8'b0) && mantissa_sum != 0) -> 
                ((exponent_out == exponent_common + 1)));
  
    //Si hay carry de la suma aumneta exponente en normalize
    NORM_CARRY_MANTISSA: assert ((mantissa_sum[24] && !is_subnormal_a && !is_subnormal_b) -> 
                ((mantissa_ext == {mantissa_sum,1'b0,1'b0})));  //{1'b0,mantissa_sum,1'b0}  
    
    //Carry si el bit implicito tambien es 1 en subnormales
    NORM_CARRY_MANTISSA_SUBN: assert (( mantissa_sum[23] && (exponent_common == 8'b0) && mantissa_sum != 0) -> 
                ((mantissa_ext[25:3] == mantissa_sum[23:0])));   

    //Ajuste normalize poner el primer 1 con shift a la derecha
    NORM_SHIFT_MANTISSA_NORMALES: assert (((mantissa_sum != 0) 
                                && (!mantissa_sum[24])
                                && (!mantissa_sum[23]) 
                                && (exponent_common > shift_amount)) ->
                (mantissa_ext[26:3] == (mantissa_sum[23:0]<<shift_amount)));

    NORM_SHIFT_EXPO_NORMALES: assert (((mantissa_sum != 0) 
                                && (!mantissa_sum[24]) 
                                && (!mantissa_sum[23]) 
                                && (exponent_common > shift_amount)) ->
                ((exponent_out == exponent_common - shift_amount)));

    //El resultado pasa de ser normal a subnormal
    NORM_SHIFT_MANTISSA_NORM_A_SUBN: assert (((mantissa_sum != 0)
                                && (!mantissa_sum[24])
                                && (!mantissa_sum[23])   
                                && (exponent_common > 0) 
                                && (exponent_common <= shift_amount)) ->
                ((mantissa_ext[25:3] == mantissa_sum[23:0] << (exponent_common))));

    NORM_SHIFT_EXPO_NORM_A_SUBN: assert (((mantissa_sum != 0)
                                && (!mantissa_sum[24])
                                && (!mantissa_sum[23])  
                                && (exponent_common > 0) 
                                && (exponent_common <= shift_amount)) ->
                ((exponent_out == 0)));
                
    //Suma de sub normales no ocupa corrimiento 
    NORM_SHIFT_MANTISSA_SUBN: assert (((mantissa_sum != 0)
                                && (!mantissa_sum[24]) 
                                && (!mantissa_sum[23])
                                && (exponent_common == 8'b0)) ->
                mantissa_ext[25:3] == mantissa_sum[23:0]);

    NORM_SHIFT_EXPO_SUBN: assert (((mantissa_sum != 0)
                                && (!mantissa_sum[24]) 
                                && (!mantissa_sum[23])
                                && (exponent_common == 8'b0)) ->
                ((exponent_out == exponent_common)));  
    
    //Redondeo al mas cercano (pares en empate)
    case ({mantissa_ext[2],(|mantissa_ext[1:0])}) 
      2'b00: mantissa_r = mantissa_ext[25:3];   
      2'b01: mantissa_r = mantissa_ext[25:3]; 
      2'b10: mantissa_r = mantissa_ext[3] ? mantissa_ext[25:3] + 1'b1 : mantissa_ext[25:3]; //si es impar redondea para arriba
      2'b11: mantissa_r = mantissa_ext[25:3] + 1'b1;
    //default: mantissa_r = mantissa_ext[25:3];
    endcase
    
    ROUND_RNZ: assert ((r_mode == 3'b000) -> mantissa_rounded == mantissa_r);

    //Redondeo hacia cero
    ROUND_RTZ: assert ((r_mode == 3'b001) -> mantissa_rounded == mantissa_ext[25:3]);

    //Redondeo hacia abajo
    case (result_sign)
      1'b0: mantissa_r = mantissa_ext[25:3];   
      1'b1: mantissa_r = mantissa_ext[25:3] + 1'b1; 
    //default: mantissa_r = mantissa_ext[25:3];
    endcase 

    ROUND_RDN: assert ((r_mode == 3'b010) -> mantissa_rounded == mantissa_r);
   
    //Redondeo hacia arriba
    case (result_sign)
      1'b0: mantissa_r = mantissa_ext[25:3] + 1'b1;   
      1'b1: mantissa_r = mantissa_ext[25:3]; 
    //default: mantissa_r = mantissa_ext[25:3];
    endcase    

    ROUND_RUP: assert ((r_mode == 3'b011) -> mantissa_rounded == mantissa_r);

    //Redondeo al mas cercano (maxima magnitud en empate)
    case (mantissa_ext[2])
      1'b0: mantissa_r = mantissa_ext[25:3];   
      1'b1: mantissa_r = mantissa_ext[25:3] + 1'b1; 
    //default: mantissa_r = mantissa_ext[25:3];
    endcase    

    ROUND_RMM: assert ((r_mode == 3'b100) -> mantissa_rounded == mantissa_r);

    //Se genera carry por redondeo
    carry = {1'b0, mantissa_ext[25:3]} + 1'b1;
    ROUND_CARRY: assert ((carry_out) -> ((carry [23]) && (mantissa_rounded == mantissa_ext[25:3] + 1'b1)));

    //Se enpaqueta bien devuelta 
    FP_PACK: assert (fp_result_wire == {result_sign, exponent_final, mantissa_rounded});

    UNDERFLOW: assert ((!is_zero_b) || (!is_zero_b) && (fp_result_wire[30:0] == 31'b0) -> underflow);

    OVERFLOW: assert (((exponent_common + carry_out + mantissa_sum[24]) >= 255) -> overflow);

    CASO_NAN_IN: assert (((fp_a[30:23] == 8'hFF && |fp_a[21:0]) ||
              (fp_b[30:23] == 8'hFF && |fp_b[21:0])) -> fp_result == 32'h7fc00000);

    CASO_NAN_INF: assert (((fp_a == 32'h7f800000 && fp_b == 32'hff800000) || 
                (fp_a == 32'hff800000 && fp_b == 32'h7f800000)) -> fp_result == 32'h7fc00000);
                ;
    
    CASO_INF_POSITIVO: assert (((fp_a == 32'h7f800000 && !(fp_b[30:23] == 8'hFF && |fp_b[22:0])) || 
                (fp_b == 32'h7f800000 && !(fp_a[30:23] == 8'hFF && |fp_a[22:0]))) -> fp_result == 32'h7f800000);
    
    CASO_INF_NEGATIVO: assert (((fp_a == 32'hff800000 && !(fp_b[30:23] == 8'hFF && |fp_b[22:0])) || 
                (fp_b == 32'hff800000 && !(fp_a[30:23] == 8'hFF && |fp_a[22:0]))) -> fp_result == 32'hff800000);

    PRUEBA_SUB: assert ((fp_a == 32'h000a0000 && fp_b == 32'h000a0000 && r_mode == 3'b001) ->
                          (fp_result == 32'h00140000));
                          
    PRUEBA_SUB_NORM: assert ((fp_a == 32'h01000000 && fp_b == 32'h00300000 && r_mode == 3'b001) ->
                          (fp_result == 32'h01180000));

    PRUEBA_NORM_NORM: assert ((fp_a == 32'h14300000 && fp_b == 32'h1FC00000&& r_mode == 3'b001) ->
                          (fp_result == 32'h1FC00001));
end  

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