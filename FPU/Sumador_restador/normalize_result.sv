/****************************************************************************************
 * Archivo       : normalize_result.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Normaliza el resultado de una operación, después de la suma o resta.
 *                 Ajusta la mantisa y el exponentes egún el caso:
 *                 overflow, normalización a la izquierda, o subnormal.
 * Instancias    : fp_alu, fp_adder, fp_sub, fp_madd, fp_msub
 ****************************************************************************************/

module normalize_result (
    input  logic [24:0] mantissa_sum,        // Resultado crudo de la suma/resta
    input  logic [7:0]  exponent_common,     // Exponente común alineado

    output logic [26:0] mantissa_ext,        // Mantisa extendida: [26:3]=mant, [2]=G, [1]=R, [0]=S
    output logic [7:0]  exponent_out         // Exponente ajustado tras normalización
);
    logic [7:0]  shift_amount;
    logic [23:0] shifted_mantissa;
    logic [1:0]  round_bits;
    logic        sticky_bit;
    logic [47:0] mantissa_preshift;
    logic [23:0] mantissa_shifted_check;

    always_comb begin
        mantissa_ext  = 27'd0;
        exponent_out  = 8'd0;

        // Caso: resultado es exactamente cero
        if (mantissa_sum == 0) begin
            mantissa_ext  = 27'd0;
            exponent_out  = 8'd0;

        // Caso: overflow por carry en la suma (bit 24 activo)
        end else if (mantissa_sum[24]) begin
            // Overflow con carry en la suma
            mantissa_ext[26:3] = mantissa_sum[24:1];
            mantissa_ext[2]    = mantissa_sum[0];  // guard
            mantissa_ext[1]    = 1'b0;
            mantissa_ext[0]    = 1'b0;
            exponent_out       = exponent_common + 1;

        end else begin
            // Normalización a la izquierda o subnormal
            shift_amount = leading_zero_count(mantissa_sum[23:0]);
            mantissa_shifted_check = mantissa_sum[23:0] << shift_amount;

            if ((exponent_common > shift_amount) && mantissa_shifted_check[23]) begin
                // --- Número normal ---
                shifted_mantissa     = mantissa_sum[23:0] << shift_amount;
                mantissa_ext[26:3]   = shifted_mantissa;

                if ((23 - shift_amount) >= 1)
                    round_bits = {
                        mantissa_sum[23 - shift_amount],
                        mantissa_sum[23 - shift_amount - 1]
                    };
                else
                    round_bits = 2'b00;

                sticky_bit = 1'b0;
                for (int i = 0; i < (23 - shift_amount - 1); i++)
                    sticky_bit |= mantissa_sum[i];

                mantissa_ext[2] = round_bits[1]; // guard
                mantissa_ext[1] = round_bits[0]; // round
                mantissa_ext[0] = sticky_bit;    // sticky

                exponent_out = exponent_common - shift_amount;

            end else begin
                // ----------------- Caso SUBNORMAL -----------------

                // Exponente insuficiente
                logic [7:0] shift_sub = leading_zero_count(mantissa_sum[23:0]);

                mantissa_preshift = {1'b0, mantissa_sum, 22'd0} << shift_sub;

                // capturar mantissa desde bit 46, no 47
                mantissa_ext[26:3] = mantissa_preshift[46:23];  // mantissa precisa
                mantissa_ext[2]    = mantissa_preshift[22];     // guard
                mantissa_ext[1]    = mantissa_preshift[21];     // round
                mantissa_ext[0]    = |mantissa_preshift[20:0];  // sticky

                exponent_out = 8'd0;
            end
        end
    end

    // Función auxiliar: cuenta ceros a la izquierda (priority encoder)
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
