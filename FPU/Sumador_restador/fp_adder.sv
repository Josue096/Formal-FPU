/****************************************************************************************
 * Archivo       : fp_adder.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Implementa una suma en punto flotante bajo el estándar IEEE 754.
 *                 Internamente realiza el desempaquetado de los operandos, alineación de exponentes,
 *                 suma/resta de mantisas (dependiendo del signo), normalización del resultado,
 *                 redondeo según el modo indicado y detección de condiciones especiales.
 * Instancias    : fp_alu, fp_adder, fp_sub, fp_madd, fp_msub
 ****************************************************************************************/


module fp_adder (
    input  logic [31:0] fp_a,       // Operando A en formato IEEE 754
    input  logic [31:0] fp_b,       // Operando B en formato IEEE 754
    input  logic [2:0]  r_mode,     // Modo de redondeo IEEE 754 

    output logic [31:0] fp_result,  // Resultado final de la suma
    output logic        overflow,   // Bandera de overflow
    output logic        underflow   // Bandera de underflow
);

    logic sign_a, sign_b, result_sign;
    logic [7:0]  exponent_a, exponent_b, exponent_common, exponent_out, exponent_final;
    logic [23:0] mantissa_a, mantissa_b, mantissa_a_aligned, mantissa_b_aligned;
    logic [24:0] mantissa_sum;
    logic [26:0] mantissa_ext;
    logic [22:0] mantissa_rounded;
    logic is_special_a, is_special_b, is_subnormal_a, is_subnormal_b, is_zero_a, is_zero_b;
    logic carry_out;
    logic overflow_internal;
    logic [31:0] fp_result_wire;

    // Desempaquetado de entradas
    fp_unpack u1 (
        .fp_in             (fp_a),
        .sign              (sign_a),
        .exponent          (exponent_a),
        .mantissa          (mantissa_a),
        .is_special        (is_special_a),
        .is_subnormal      (is_subnormal_a),
        .is_zero           (is_zero_a)
    );

    fp_unpack u2 (
        .fp_in             (fp_b),
        .sign              (sign_b),
        .exponent          (exponent_b),
        .mantissa          (mantissa_b),
        .is_special        (is_special_b),
        .is_subnormal      (is_subnormal_b),
        .is_zero           (is_zero_b)
    );

    // Alineación de exponentes
    align_exponents u3 (
        .mantissa_a        (mantissa_a),
        .mantissa_b        (mantissa_b),
        .exponent_a        (exponent_a),
        .exponent_b        (exponent_b),
        .is_subnormal_a    (is_subnormal_a),
        .is_subnormal_b    (is_subnormal_b),
        .mantissa_a_aligned(mantissa_a_aligned),
        .mantissa_b_aligned(mantissa_b_aligned),
        .exponent_common   (exponent_common)
    );

    // Suma/resta de mantisas
    add_sub_mantissas u4 (
        .mantissa_a        (mantissa_a_aligned),
        .mantissa_b        (mantissa_b_aligned),
        .sign_a            (sign_a),
        .sign_b            (sign_b),
        .mantissa_sum      (mantissa_sum),
        .result_sign       (result_sign)
    );

    // Normalización de resultado
    normalize_result u5 (
        .mantissa_sum      (mantissa_sum),
        .exponent_common   (exponent_common),
        .mantissa_ext      (mantissa_ext),
        .exponent_out      (exponent_out)
    );

    // Redondeo
    round u6 (
        .Z_in              (mantissa_ext),
        .sign_Z            (result_sign),
        .r_mode            (r_mode),
        .carry_out         (carry_out),
        .Z_out             (mantissa_rounded)
    );

    assign exponent_final = carry_out ? (exponent_out + 1) : exponent_out;


    // Detección de underflow (monitoreo)
    assign underflow = (exponent_out == 8'd0);
    // Empaquetado sin casos especiales
    fp_pack u7 (
        .sign(result_sign),
        .exponent(exponent_final),
        .mantissa(mantissa_rounded),
        .fp_out(fp_result_wire)
    );
    

    // Casos especiales y manejo de overflow
    always_comb begin
        overflow_internal = 1'b0;

        // Caso: alguno de los operandos es NaN → propagar NaN
        if ((fp_a[30:23] == 8'hFF && fp_a[22:0] != 0) ||
            (fp_b[30:23] == 8'hFF && fp_b[22:0] != 0)) begin
            fp_result = 32'h7fc00000;  // NaN

        // Caso: uno de los operandos es ±Inf
        end else if (is_special_a || is_special_b) begin

            // Caso conflictivo: +Inf + -Inf => NaN
            if ((fp_a == 32'h7f800000 && fp_b == 32'hff800000) || 
                (fp_a == 32'hff800000 && fp_b == 32'h7f800000)) begin
                fp_result = 32'h7fc00000;  // NaN
            end else begin
                // Si solo uno es especial, propagarlo
                fp_result = is_special_a ? fp_a : fp_b;
            end

        // Caso: ambos operandos son cero
        end else if (is_zero_a && is_zero_b) begin
            fp_result = 32'h00000000;

        // Caso: solo A es cero => resultado = B
        end else if (is_zero_a) begin
            fp_result = fp_b;

        // Caso: solo B es cero => resultado = A
        end else if (is_zero_b) begin
            fp_result = fp_a;

        // Caso general
        end else begin
            // Detectar overflow en el exponente final
            if (exponent_final >= 8'hFF) begin
                fp_result = {result_sign, 8'hFF, 23'b0};  // ±Inf
                overflow_internal = 1'b1;
            end else begin
                fp_result = fp_result_wire;
            end
        end
    end

    // Conectar la señal de overflow
    assign overflow = overflow_internal;

endmodule
