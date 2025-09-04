/****************************************************************************************
 * Archivo       : round.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Implementa la lógica de redondeo IEEE-754 para la mantisa extendida.
 *                 Recibe una mantisa de 27 bits con bits de guardia (G), redondeo (R) y sticky (S),
 *                 y aplica el redondeo correspondiente.
 * Instancias    : fp_alu, fp_adder, fp_sub, fp_madd, fp_msub
 ****************************************************************************************/


module round (
    input  logic [26:0] Z_in,       // [26:3] = mantissa, [2] = guard, [1] = round, [0] = sticky
    input  logic        sign_Z,     // signo del resultado
    input  logic [2:0]  r_mode,     // modo de redondeo IEEE-754

    output logic        carry_out,  // se activa si hay overflow en mantissa
    output logic [22:0] Z_out       // mantisa redondeada
);

    logic [24:0] Z_plus, Z_up, Z_down, Z_near_even, Z_near_max;
    logic [24:0] Z_round;

    // Round up (LSB + 1)
    assign Z_plus = Z_in[26:3] + 25'd1;

    // Round toward ±infinito
    assign Z_up   = sign_Z ? Z_in[26:3] : Z_plus;
    assign Z_down = sign_Z ? Z_plus     : Z_in[26:3];

    // Round to nearest, ties to even
    assign Z_near_even = !Z_in[2] ? Z_in[26:3] :
                         (|Z_in[1:0] ? Z_plus :
                          (Z_in[3] ? Z_plus : Z_in[26:3]));

    // Round to nearest, ties to max magnitude
    assign Z_near_max = !Z_in[2] ? Z_in[26:3] : Z_plus;

    // Selector de modo de redondeo
    always_comb begin
        case (r_mode)
            3'b000: Z_round = Z_near_even;   // Round to Nearest, Even
            3'b001: Z_round = Z_in[26:3];    // Round Toward Zero (RTZ) 
            3'b010: Z_round = Z_down;        // Round Down (toward -∞)
            3'b011: Z_round = Z_up;          // Round Up (toward +∞)
            3'b100: Z_round = Z_near_max;    // Round to Nearest, Max Magnitude
            default: Z_round = Z_in[26:3];   // Fallback: truncar RTZ
        endcase
    end

    // Detecta overflow en la mantissa (bit 24 activado)
    assign carry_out = Z_round[24];

    // Salida final de mantissa
    assign Z_out = carry_out ? Z_round[23:1] : Z_round[22:0];

endmodule

