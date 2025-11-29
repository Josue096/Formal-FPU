// fp_mul_comm_check_improved.sv
//
// Conmutatividad FP32 — versión descompuesta para VC Formal
// - maneja NaN/Inf/Zero/Denorm/Finite por separado
// - restringe rmode a 0..4 (modos IEEE)
// - añade covers para encontrar CE rápidamente
//

module fp_comm_wrapper;

  // Entradas FP32 y modo de redondeo
  logic [31:0] a, b;
  logic [2:0]  rmode;

  // Resultados de ambas instancias
  logic [31:0] zab, zba;
  logic ov1, ov2;
  logic ud1, ud2;

  // DUT ORIGINAL (a*b) y DUT INTERCAMBIADO (b*a)
  fp_mul dut_ab (.fp_X(a), .fp_Y(b), .r_mode(rmode), .fp_Z(zab), .ovrf(ov1), .udrf(ud1));
  fp_mul dut_ba (.fp_X(b), .fp_Y(a), .r_mode(rmode), .fp_Z(zba), .ovrf(ov2), .udrf(ud2));

  // -----------------------
  // Helpers IEEE754 FP32
  // -----------------------
  function automatic logic isNaN(input logic [31:0] x);
    return (&x[30:23]) && (|x[22:0]); // exp == 0xFF && frac != 0
  endfunction

  function automatic logic isInf(input logic [31:0] x);
    return (&x[30:23]) && (x[22:0] == 23'd0); // exp == 0xFF && frac == 0
  endfunction

  function automatic logic isZero(input logic [31:0] x);
    return (x[30:23] == 8'h00) && (x[22:0] == 23'd0); // exp == 0 && frac == 0
  endfunction

  function automatic logic isDenorm(input logic [31:0] x);
    return (x[30:23] == 8'h00) && (x[22:0] != 23'd0); // exp == 0 && frac != 0
  endfunction

  function automatic logic isFinite(input logic [31:0] x);
    return (~&x[30:23]); // exp != 0xFF
  endfunction

  // Orden lexicográfico sintáctico (sign,exp,frac)
  function automatic logic fp32_lex_le(input logic [31:0] x, input logic [31:0] y);
    logic sx, sy;
    logic [7:0] ex, ey;
    logic [22:0] mx, my;
    {sx, ex, mx} = x;
    {sy, ey, my} = y;
    return (sx < sy) ||
           (sx == sy && ex <  ey) ||
           (sx == sy && ex == ey && mx <= my);
  endfunction

  // -----------------------
  // Reducción de simetría
  // -----------------------
  // Limita rmode a los modos estándar IEEE-754 (0..4)
  // (0: nearest even, 1: toward zero, 2: toward +inf, 3: toward -inf, 4: nearest away?) 
  // Ajusta si tu implementación usa otro encoding.
  always_comb begin
    assume (rmode <= 3'd4);

    // Para evitar duplicar casos simétricos imponemos orden sobre tuplas
    // excepto cuando ambos son ±0 (dejar ambos ordenes) o cuando ambos son NaN
    assume ( !(isZero(a) && isZero(b)) -> fp32_lex_le(a, b) );
    assume ( !(isNaN(a) && isNaN(b)) );

    // -----------------------
    // COVERS (encuentra CE rápido)
    // -----------------------
    // Si alguna propiedad falla, estos covers ayudan a localizar el tipo de caso
    cover (isNaN(a) && !isNaN(b));
    cover (isNaN(b) && !isNaN(a));
    cover (isInf(a) && isZero(b));
    cover (isDenorm(a) || isDenorm(b));
    cover (isFinite(a) && isFinite(b));

    // -----------------------
    // PROPIEDADES DESCOMPUESTAS
    // -----------------------

    // 1) Si cualquiera de las entradas es NaN => resultado debe ser NaN (ambos)
    //    (algunas ISAs pueden quietar payloads, así que comprobamos isNaN en salida)
    assert (
      (isNaN(a) || isNaN(b)) ->
        (isNaN(zab) && isNaN(zba))
    );

    // 2) Si ninguna entrada es NaN y ambas son finitas (incluye denormales y ceros),
    //    entonces el resultado completo debe ser idéntico
    assert (
      (!(isNaN(a) || isNaN(b)) && isFinite(a) && isFinite(b)) ->
        (zab == zba)
    );

    // 3) Casos con infinito: si alguno es Inf (y no hay NaN), la salida debe coincidir
    //    (Inf * 0 => NaN; pero ambos órdenes producen NaN — queda cubierto por la regla NaN)
    assert (
      (!(isNaN(a) || isNaN(b)) && (isInf(a) || isInf(b))) ->
        (zab == zba)
    );

    // 4) Casos específicos de cero: ambos ceros o mix con finite deben coincidir
    assert (
      (!(isNaN(a) || isNaN(b)) && (isZero(a) || isZero(b))) ->
        (zab == zba)
    );

    // 5) Propiedades parciales (más pequeñas) por campos — si las anteriores fallan,
    //    estas son más fáciles de probar individualmente:
    //    signo debe ser igual (sx^sy independientemente del orden)
    assert (
      (!(isNaN(a) || isNaN(b))) ->
        (zab[31] == zba[31])
    );

    //    exponente debe coincidir
    assert (
      (!(isNaN(a) || isNaN(b))) ->
        (zab[30:23] == zba[30:23])
    );

    //    mantisa (fraction) debe coincidir (para la representación final)
    assert (
      (!(isNaN(a) || isNaN(b))) ->
        (zab[22:0] == zba[22:0])
    );

    // Flags de overflow/underflow
    assert ( (!(isNaN(a) || isNaN(b))) -> (ov1 == ov2) );
    assert ( (!(isNaN(a) || isNaN(b))) -> (ud1 == ud2) );

    // -----------------------
    // Diagnostics: si algo queda inconcluso
    // - Sugerencia: expone señales internas del DUT (signo, exp, mant antes de round)
    //   y crea asserts similares para esas señales. Eso permite probar el datapath.
    // -----------------------
  end
endmodule
