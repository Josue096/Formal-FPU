/****************************************************************************************
 * Archivo       : add_sub_mantissas.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Realiza la operación de suma o resta entre mantisas de 24 bits (con bit implicito) y determina
 *                 el signo del resultado. La operación se determina automáticamente con base 
 *                 en los signos de entrada.
 * Instancias    : fp_alu, fp_adder, fp_sub, fp_madd, fp_msub
 ****************************************************************************************/


module add_sub_mantissas (
    input  logic [23:0] mantissa_a,      // Mantisa A 
    input  logic [23:0] mantissa_b,      // Mantisa B 
    input  logic        sign_a,          // Signo de A
    input  logic        sign_b,          // Signo de B

    output logic [24:0] mantissa_sum,    // Resultado de la operación (25 bits para carry)
    output logic        result_sign      // Signo del resultado final
);

    always_comb begin
        // Caso 1: signos iguales -> suma directa
        if (sign_a == sign_b) begin
            mantissa_sum = mantissa_a + mantissa_b;
            result_sign  = sign_a;
        
        // Caso 2: signos distintos
        end else begin
            // Si son exactamente iguales el resultado es cero
            if (mantissa_a == mantissa_b) begin
                mantissa_sum = 0;
                result_sign  = 0;

            // Resta A - B si A > B
            end else if (mantissa_a > mantissa_b) begin
                mantissa_sum = mantissa_a - mantissa_b;
                result_sign  = sign_a;
            
            // Resta B - A si B > A
            end else begin
                mantissa_sum = mantissa_b - mantissa_a;
                result_sign  = sign_b;
            end
        end
    end
endmodule
