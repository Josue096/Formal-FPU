/****************************************************************************************
 * Archivo       : fp_fle.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Compara dos numeros en formato IEEE-754, realiza comparacion de 'A' menor o igual que 'B'
                   Bit de salida en 1 si se cumple la condicion, en 0 si no lo son.
 * Instancias    : fp_alu, fp_fle
 ****************************************************************************************/


module fp_fle (
    input  logic [31:0] fp_a, // Primero numero para comparacion
    input  logic [31:0] fp_b, // Segundo numero para comparacion

    output logic        le    // 1 si A ≤ B, 0 si no
);
    logic eq, lt;

    // Instancia del comparador de igualdad (A == B)
    fp_feq cmp_eq (
        .fp_a(fp_a),
        .fp_b(fp_b),
        .eq  (eq)
    );

    // Instancia del comparador de menor que (A < B)
    fp_flt cmp_lt (
        .fp_a(fp_a),
        .fp_b(fp_b),
        .lt  (lt)
    );

    // Operacion OR, si alguna de las dos comparaciones anteriores son postitivas la salida es '1'
    // (A ≤ B) si (A < B) o (A == B)
    assign le = lt | eq;

endmodule
