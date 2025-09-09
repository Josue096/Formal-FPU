/****************************************************************************************
 * Archivo       : fp_feq.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Compara dos numeros en formato IEEE-754, realiza comparacion de igualdad
                   Bit de salida en 1 si se cumple la condicion, en 0 si no lo son.
 * Instancias    : fp_alu, fp_feq, fp_fle
 ****************************************************************************************/


module fp_feq (
    input  logic [31:0] fp_a, // Primero numero para comparacion
    input  logic [31:0] fp_b, // Segundo numero para comparacion

    output logic        eq    // 1 si A = B, 0 si no
);
    logic sign_a, is_special_a, is_subnormal_a, is_zero_a;
    logic [7:0]  exponent_a;
    logic [23:0] mantissa_a;

    logic sign_b, is_special_b, is_subnormal_b, is_zero_b;
    logic [7:0]  exponent_b;
    logic [23:0] mantissa_b;

    // Instancias del módulo fp_unpack 1
    fp_unpack unpack_a (
        .fp_in       (fp_a),
        .sign        (sign_a),
        .exponent    (exponent_a),
        .mantissa    (mantissa_a),
        .is_special  (is_special_a),
        .is_subnormal(is_subnormal_a),
        .is_zero     (is_zero_a)
    );

    // Instancias del módulo fp_unpack 2
    fp_unpack unpack_b (
        .fp_in       (fp_b),
        .sign        (sign_b),
        .exponent    (exponent_b),
        .mantissa    (mantissa_b),
        .is_special  (is_special_b),
        .is_subnormal(is_subnormal_b),
        .is_zero     (is_zero_b)
    );

    // Detectar si los números son infinitos directamente en fp_compare_eq
    logic is_inf_a, is_inf_b;
    assign is_inf_a = (exponent_a == 8'hFF) && (mantissa_a == 24'b0); // Exp=255 y mantisa=0 => Inf
    assign is_inf_b = (exponent_b == 8'hFF) && (mantissa_b == 24'b0); // Exp=255 y mantisa=0 => Inf

    always_comb begin
        if ((is_special_a && !is_inf_a) || (is_special_b && !is_inf_b)) begin
            // Si alguno es NaN, la comparación es falsa
            eq = 1'b0;
        end 
        else if (is_inf_a && is_inf_b) begin
            // Si ambos son infinitos, deben ser del mismo signo para ser iguales
            eq = (sign_a == sign_b);
        end
        else if (is_zero_a && is_zero_b) begin
            // +0.0 y -0.0 son considerados iguales
            eq = 1'b1;
        end 
        else begin
            // Comparar signo, exponente y mantisa
            eq = (sign_a == sign_b) &&
                 (exponent_a == exponent_b) &&
                 (mantissa_a == mantissa_b);
        end
    end
endmodule
