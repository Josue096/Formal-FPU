/****************************************************************************************
 * Archivo       : fp_pack.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Empaqueta por medio de contatenacion los bits de signo, mantisa y exponente 
                   para formar el numero en formato IEEE 754.
 * Instancias    : fp_alu, fp_adder, fp_sub, fp_madd, fp_msub
 ****************************************************************************************/



module fp_pack (
    input  logic        sign,
    input  logic [7:0]  exponent,
    input  logic [22:0] mantissa,
    output logic [31:0] fp_out
);
    // Concatenacion de las entradas
    assign fp_out = {sign, exponent, mantissa[22:0]};
endmodule
