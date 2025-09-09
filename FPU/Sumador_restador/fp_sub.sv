/****************************************************************************************
 * Archivo       : fp_sub.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Implementa la operación de resta en punto flotante bajo el estándar 
                   IEEE 754 simple precisión. La operación A - B se realiza convirtiendo el operando B 
                   a su valor negado (-B) y luego reutilizando el módulo de suma `fp_adder` para 
                   realizar A + (-B), aprovechando toda la lógica de alineación, normalización y redondeo.
 * Instancias    : fp_alu, fp_sub, fp_madd, fp_msub
 ****************************************************************************************/


module fp_sub (
    input  logic [31:0] fp_a,       // Operando A en formato IEEE 754
    input  logic [31:0] fp_b,       // Operando B en formato IEEE 754
    input  logic [2:0]  r_mode,     // Modo de redondeo IEEE 754 

    output logic [31:0] fp_result,  // Resultado final de la suma
    output logic        overflow,   // Bandera de overflow
    output logic        underflow   // Bandera de underflow
);
    // Señales intermedias
    logic [31:0]        fp_bsub;

    ///////////////////////////////////////////////////////
    // Etapa 1: inversión de signo del operando B (B => -B)
    ///////////////////////////////////////////////////////
    change_sign sub_fp_b (
        .fp_b      (fp_b),
        .fp_bsub   (fp_bsub)
    );

    /////////////////////////////////////////////////////////////////
    // Etapa 2: Instancia del sumador para realizar A + (-B) = A - B
    /////////////////////////////////////////////////////////////////
    fp_adder fp_adder_for_sub (
        .fp_a      (fp_a),
        .fp_b      (fp_bsub),
        .r_mode    (r_mode),
        .fp_result (fp_result),
        .overflow  (overflow),
        .underflow (underflow)
    );


endmodule
