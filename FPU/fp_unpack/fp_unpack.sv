/****************************************************************************************
 * Archivo       : fp_unpack.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Desempacado de los numeros en punto flotante {signo,exponente,mantisa}
                   Clasifica los numeros como especial (inf o NaN), subnormal o cero.
 * Instancias    : fp_alu, fp_adder, fp_sub, fp_feq, fp_flt, fp_fle, fp_madd, fp_msub
 ****************************************************************************************/


module fp_unpack (
    input  logic [31:0] fp_in,
    output logic        sign,
    output logic [7:0]  exponent,
    output logic [23:0] mantissa,
    output logic        is_special,
    output logic        is_subnormal,
    output logic        is_zero
);
    always_comb begin
        // Extrae signo y exponente 
        sign         = fp_in[31];
        exponent     = fp_in[30:23];

        // Detecta condiciones especiales
        is_special   = (exponent == 8'hFF);
        is_subnormal = (exponent == 8'h00) && (fp_in[22:0] != 23'b0);
        is_zero      = (fp_in[30:0] == 31'b0);

        // Asignacion de bit implicito 
        if (is_special) begin
            mantissa = {1'b0, fp_in[22:0]};
        end else if (is_subnormal) begin
            mantissa = {1'b0, fp_in[22:0]};
            exponent = 8'd0;   
        end else begin
            mantissa = {1'b1, fp_in[22:0]}; 
        end
    end
endmodule