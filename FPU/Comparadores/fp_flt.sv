/****************************************************************************************
 * Archivo       : fp_flt.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Compara dos numeros en formato IEEE-754, realiza comparacion de 'A' menor que 'B'
                   Bit de salida en 1 si se cumple la condicion, en 0 si no lo son.
 * Instancias    : fp_alu, fp_flt, fp_fle
 ****************************************************************************************/


module fp_flt (
    input  logic [31:0] fp_a, // Primero numero para comparacion
    input  logic [31:0] fp_b, // Segundo numero para comparacion
 
    output logic        lt    // 1 si A < B, 0 si no
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

    // Detectar si los números son infinitos
    logic  is_inf_a, is_inf_b;
    assign is_inf_a = (exponent_a == 8'hFF) && (mantissa_a == 24'b0);
    assign is_inf_b = (exponent_b == 8'hFF) && (mantissa_b == 24'b0);

    always_comb begin
        if ((is_special_a && !is_inf_a) || (is_special_b && !is_inf_b)) begin
            // Si alguno es NaN, la comparación siempre es falsa
            lt = 1'b0;
        end 
        else if (is_zero_a && is_zero_b) begin
            // -0.0 y +0.0 son iguales en IEEE 754, por lo que NO son menores
            lt = 1'b0;
        end
        else if (is_inf_a && is_inf_b) begin
            // Inf no puede ser menor que otro Inf
            lt = 1'b0;
        end 
        else if (is_inf_a && !sign_a) begin
            // Si A es +Inf, nunca es menor
            lt = 1'b0;
        end 
        else if (is_inf_a && sign_a) begin
            // Si A es -Inf, siempre es menor a cualquier número finito
            lt = 1'b1;
        end 
        else if (is_inf_b && !sign_b) begin
            // Si B es +Inf, A siempre es menor
            lt = 1'b1;
        end
        else if (sign_a != sign_b) begin
            // Si los signos son diferentes, el número negativo es menor
            lt = sign_a;
        end 
        else if (sign_a == 1'b0) begin
            // Ambos son positivos, comparación normal
            if (exponent_a < exponent_b)
                lt = 1'b1;
            else if (exponent_a > exponent_b)
                lt = 1'b0;
            else
                lt = (mantissa_a < mantissa_b); // NO incluye igualdad
        end 
        else begin
            // Ambos son negativos, el mayor exponente es menor
            if (exponent_a > exponent_b)
                lt = 1'b1;
            else if (exponent_a < exponent_b)
                lt = 1'b0;
            else
                lt = (mantissa_a > mantissa_b); // Para negativos, mayor mantisa es menor
        end
    end
endmodule

