/****************************************************************************************
 * Archivo       : align_exponents.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Alinea las mantisas de dos operandos flotantes cuando sus exponentes 
 *                 son distintos. Esta alineación es necesaria para poder suma o resta.
 * Instancias    : fp_alu, fp_adder, fp_sub, fp_madd, fp_msub
 ****************************************************************************************/


module align_exponents (
    input  logic [23:0] mantissa_a,         // Mantisa del operando A
    input  logic [23:0] mantissa_b,         // Mantisa del operando B
    input  logic [7:0]  exponent_a,         // Exponente de A
    input  logic [7:0]  exponent_b,         // Exponente de B
    input  logic        is_subnormal_a,     // A es subnormal
    input  logic        is_subnormal_b,     // B es subnormal

    output logic [23:0] mantissa_a_aligned, // Mantisa A alineada
    output logic [23:0] mantissa_b_aligned, // Mantisa B alineada
    output logic [7:0]  exponent_common     // Exponente común
);
    logic [7:0] exp_diff;

    always_comb begin
        // Ambos subnormales: asignar exp común = 1 y escalar mantissas
        if (is_subnormal_a && is_subnormal_b) begin
            exponent_common    = 8'd1;
            mantissa_a_aligned = mantissa_a << 1;  // simula bit implícito perdido
            mantissa_b_aligned = mantissa_b << 1;

        // Caso: solo A es subnormal A se desplaza, B mantiene su exponente
        end else if (is_subnormal_a) begin
            exp_diff           = exponent_b - 1;
            exponent_common    = exponent_b;
            mantissa_a_aligned = (exp_diff > 23) ? 24'd0 : (mantissa_a << 1) >> exp_diff;
            mantissa_b_aligned = mantissa_b;

        // Caso: solo B es subnormal B se desplaza, A mantiene su exponente
        end else if (is_subnormal_b) begin
            exp_diff           = exponent_a - 1;
            exponent_common    = exponent_a;
            mantissa_a_aligned = mantissa_a;
            mantissa_b_aligned = (exp_diff > 23) ? 24'd0 : (mantissa_b << 1) >> exp_diff;

        // Caso: A tiene mayor exponente, B se alinea
        end else if (exponent_a > exponent_b) begin
            exp_diff           = exponent_a - exponent_b;
            exponent_common    = exponent_a;
            mantissa_a_aligned = mantissa_a;
            mantissa_b_aligned = (exp_diff > 23) ? 24'd0 : mantissa_b >> exp_diff;

        // Caso: B tiene mayor o igual exponente, A se alinea
        end else begin
            exp_diff           = exponent_b - exponent_a;
            exponent_common    = exponent_b;
            mantissa_a_aligned = (exp_diff > 23) ? 24'd0 : mantissa_a >> exp_diff;
            mantissa_b_aligned = mantissa_b;
        end
    end
endmodule
