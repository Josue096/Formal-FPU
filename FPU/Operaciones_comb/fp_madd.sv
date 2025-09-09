/****************************************************************************************
 * Archivo       : fp_madd.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Implementa la operación de multiplicación y suma en punto flotante
 *                 bajo el estándar IEEE 754, también conocida como FMA (Fused Multiply-Add): (A × B) + C
 * Instancias    : fp_alu, fp_madd
 ****************************************************************************************/
 

module fp_madd (

    input  logic [31:0] fp_a,        // Operando A en IEEE 754 
    input  logic [31:0] fp_b,        // Operando B en IEEE 754 
    input  logic [31:0] fp_c,        // Operando C en IEEE 754 
    input  logic [2:0]  r_mode,      // Modo de redondeo IEEE 754

    output logic [31:0] fp_result,   // Resultado final redondeado
    output logic        overflow,    // Bandera de overflow
    output logic        underflow    // Bandera underflow
);

    logic [31:0]    fp_z;
    logic           ovrf_mul, ovrf_add;
    logic           udrf_mul, udrf_add;

    ////////////////////////////////
    // Etapa 1: multiplicación A * B
    ////////////////////////////////
    fp_mul mul (
        .r_mode (3'b000), //RNE, mantener la mayor precisión con el menor redondeo intermedio posible
        .fp_X   (fp_a),
        .fp_Y   (fp_b),
        .fp_Z   (fp_z),
        .ovrf   (ovrf_mul),
        .udrf   (udrf_mul)
    );  

    ////////////////////////////////
    // Etapa 2: suma con C
    ////////////////////////////////
    fp_adder adder (
        .fp_a      (fp_z),
        .fp_b      (fp_c),
        .r_mode    (r_mode),
        .fp_result (fp_result),
        .overflow  (ovrf_add),
        .underflow (udrf_add)
    );

    assign overflow  = ovrf_mul | ovrf_add;
    assign underflow = udrf_mul | udrf_add;

endmodule