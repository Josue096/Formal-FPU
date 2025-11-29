module fp_comm_wrapper;

// =========================================================
//  Conmutatividad del Multiplicador IEEE754 (FP32)
//  Optimizaciones para VC Formal — listo para usar
// =========================================================

  // Entradas FP32 y modo de redondeo
  logic [31:0] a, b;
  logic [2:0]  rmode;

  // Resultados de ambas instancias
  logic [31:0] zab, zba;
  logic ov1, ov2;
  logic ud1, ud2;

  // =========================================================
  //  DUT ORIGINAL (a * b)
  // =========================================================
  fp_mul dut_ab (
    .fp_X(a),
    .fp_Y(b),
    .r_mode(rmode),
    .fp_Z(zab),
    .ovrf(ov1),
    .udrf(ud1)
  );

  // =========================================================
  //  DUT INTERCAMBIADO (b * a)
  // =========================================================
  fp_mul dut_ba (
    .fp_X(b),
    .fp_Y(a),
    .r_mode(rmode),
    .fp_Z(zba),
    .ovrf(ov2),
    .udrf(ud2)
  );

  // =========================================================
  //  Funciones auxiliares IEEE754
  // =========================================================

  // ¿Es NaN?
  function automatic logic isNaN(input logic [31:0] x);
      return (&x[30:23]) && (|x[22:0]); 
  endfunction

  // ¿Es cero? (±0)
  function automatic logic isZero(input logic [31:0] x);
      return (x[30:23] == 8'h00) && (x[22:0] == 23'd0);
  endfunction

  // Orden total LEXICOGRÁFICO SINTÁCTICO para IEEE754:
  // (signo, exponente, mantissa)
  function automatic logic fp32_lex_le(input logic [31:0] x,
                                       input logic [31:0] y);

      logic sx, sy;
      logic [7:0] ex, ey;
      logic [22:0] mx, my;

      {sx, ex, mx} = x;
      {sy, ey, my} = y;

      return (sx < sy) ||
             (sx == sy && ex <  ey) ||
             (sx == sy && ex == ey && mx <= my);
  endfunction


    always_comb begin
        // =========================================================
        //  SYMMETRY REDUCTION (crucial para que converge en VCF)
        // =========================================================

        // Casos con +0/-0 deben dejarse sin ordenar para no romper IEEE
        assume ( !(isZero(a) && isZero(b)) -> fp32_lex_le(a, b) );

        // Permitir NaN en cualquiera, pero no doble NaN sin orden
        assume ( !(isNaN(a) && isNaN(b)) );

        // =========================================================
        //  PROPIEDADES DE CONMUTATIVIDAD
        // =========================================================

        // Resultado completo
        COMM_FULL: assert (zab == zba);

        // Signo, exponente, mantissa son conmutativos
        COMM_SIGNO:     assert (zab[31]      == zba[31]);
        COMM_EXPONENTE: assert (zab[30:23]   == zba[30:23]);
        COMM_MANTISSA:  assert (zab[22:0]    == zba[22:0]);

        // Flags
        COMM_OV: assert (ov1 == ov2);
        COMM_UD: assert (ud1 == ud2);

    end
  
endmodule
