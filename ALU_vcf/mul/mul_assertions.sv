module fp_mul_checker (
    input  logic [31:0]  fp_X,
    input  logic [31:0]  fp_Y,
    input  logic [31:0]  fp_Z,
    input  logic [2:0]   r_mode,
    input  logic         ovrf, 
    input  logic         udrf,

    // Señales del bloque booth
    input  logic [47:0]  frc_Z_full,
    input  logic [22:0]  frc_X, frc_Y,

    // Señales del bloque norm
    input  logic [26:0]  frc_Z_norm,
    input  logic         norm_n,

    // Señales del bloque round
    input  logic         sign_Z,
    input  logic         norm_r,
    input  logic [22:0]  frc_Z,

    // Señales del bloque exponente
    input  logic [7:0]   exp_Z,
    input  logic         zer, inf, nan
);

    // Flags subnormales, infinitos y ceros (combinacional)
    logic Xsub = !(|fp_X[30:23]); // subnormal o cero
    logic Xnif = (fp_X[30:23] == 8'hFF); // NaN o inf
    logic XZero = (fp_X[30:0] == 31'b0);

    logic Ysub = !(|fp_Y[30:23]);
    logic Ynif = (fp_Y[30:23] == 8'hFF);
    logic YZero = (fp_Y[30:0] == 31'b0);

    // Constantes/valores de test
    logic [31:0] equi_norm1 = 32'h402df854;
    logic [31:0] equi_norm2 = 32'h40490fdb;
    logic [31:0] equi_sub1  = 32'h002df854;
    logic [31:0] equi_sub2  = 32'h00490fdb;

    // Ajuste de frc_Z_full (combinacional)
    logic [47:0] frc_Z_norm_check;
    assign frc_Z_norm_check = (frc_Z_full[47]) ? frc_Z_full : {frc_Z_full[46:0],1'b0}; // diagrama

    // Variables internas para round (evitan drivers múltiples)
    logic [22:0] mantissa_r_rne;
    logic [22:0] mantissa_r_rdn;
    logic [22:0] mantissa_r_rup;
    logic [22:0] mantissa_r_rmm;
    logic [22:0] mantissa_r_local;
    logic [23:0] carry_local;
    logic [7:0]  bias_local;

    // BLOQUE COMBINACIONAL: cálculo de mantissa_r, carry y bias
    always_comb begin
        // defaults
        mantissa_r_rne = frc_Z_norm[25:3];
        mantissa_r_rdn = frc_Z_norm[25:3];
        mantissa_r_rup = frc_Z_norm[25:3];
        mantissa_r_rmm = frc_Z_norm[25:3];
        carry_local    = 24'd0;
        bias_local     = 8'd127; // default bias

        // ROUND TO NEAREST EVEN (RNE)
        unique case ({frc_Z_norm[2], (|frc_Z_norm[1:0])})
            2'b00: mantissa_r_rne = frc_Z_norm[25:3];
            2'b01: mantissa_r_rne = frc_Z_norm[25:3];
            2'b10: mantissa_r_rne = (frc_Z_norm[3]) ? (frc_Z_norm[25:3] + 1) : frc_Z_norm[25:3];
            2'b11: mantissa_r_rne = frc_Z_norm[25:3] + 1;
        endcase

        // RDN (round toward -inf): if sign=1 (negative) round away from zero
        if (sign_Z)
            mantissa_r_rdn = frc_Z_norm[25:3] + 1;
        else
            mantissa_r_rdn = frc_Z_norm[25:3];

        // RUP (round toward +inf): if sign=0 (positive) round away from zero
        if (!sign_Z)
            mantissa_r_rup = frc_Z_norm[25:3] + 1;
        else
            mantissa_r_rup = frc_Z_norm[25:3];

        // RMM (round to max magnitude on tie)
        if (frc_Z_norm[2])
            mantissa_r_rmm = frc_Z_norm[25:3] + 1;
        else
            mantissa_r_rmm = frc_Z_norm[25:3];

        // Selección final según r_mode
        unique case (r_mode)
            3'b000: mantissa_r_local = mantissa_r_rne; // RNE
            3'b001: mantissa_r_local = frc_Z_norm[25:3]; // RTZ
            3'b010: mantissa_r_local = mantissa_r_rdn; // RDN
            3'b011: mantissa_r_local = mantissa_r_rup; // RUP
            3'b100: mantissa_r_local = mantissa_r_rmm; // RMM
            default: mantissa_r_local = mantissa_r_rne;
        endcase

        // carry derivado del redondeo (para evaluar carry_out si lo necesitás)
        carry_local = {1'b0, frc_Z_norm[25:3]} + 1'b1;

        // bias: si hubo normalización o round carry, ajustar
        bias_local = (norm_n || norm_r) ? 8'b01111110 : 8'b01111111;
    end

    // Asignamos la salida (sin driver multiple)
    assign mantissa_r = mantissa_r_local;
    // no se usa carry como salida, pero lo dejamos si quieres monitorizar
    assign carry = carry_local;
    assign bias  = bias_local;

    // ============================
    // ASSERTIONS (COMBINACIONALES)
    // ============================

    // Números subnormales producen el mismo resultado que cero (si no hay NaN/Inf)
    MUL_SUB_SON_ZERO: assert property ( ((Xsub && !Ynif) || (Ysub && !Xnif)) -> (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}) );

    // Multiplicación de dos subnormales -> 0
    MUL_SUB_POR_SUB: assert property ( (Xsub && Ysub) -> (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}) );

    // 0 * 0 -> 0
    MUL_ZERO_POR_ZERO: assert property ( (XZero && YZero) -> (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}) );

    // 0 * num (no inf/NaN) -> 0
    MUL_ZERO_POR_NUM: assert property ( ((XZero && !Ynif) || (YZero && !Xnif)) -> (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}) );

    // Booth: mantisas normales (test vector)
    BOOTH_NORM_X_NORM: assert property ( ((frc_X == equi_norm1[22:0]) && (frc_Y == equi_norm2[22:0])) -> (frc_Z_full == ({1'b1, frc_X} * {1'b1, frc_Y})) );

    // Booth: max frac * normal
    BOOTH_MAXFRAC_X_NORM: assert property ( ((fp_X == 32'h3fffffff) && (frc_Y == equi_norm2[22:0])) -> (frc_Z_full == ({1'b1, frc_X} * {1'b1, frc_Y})) );

    // Booth: max * max
    BOOTH_MAXFRAC_X_MAXFRAC: assert property ( ((fp_X == 32'h3fffffff) && (fp_Y == 32'h3fffffff)) -> (frc_Z_full == ({1'b1, frc_X} * {1'b1, frc_Y})) );

    // Booth: subnormal * normal (mantissa leading zero)
    BOOTH_NORM_X_SUB: assert property ( ((frc_X == equi_sub1[22:0]) && (frc_Y == equi_norm2[22:0])) -> (frc_Z_full == ({1'b0, frc_X} * {1'b1, frc_Y})) );

    // Booth: sub * sub
    BOOTH_SUB_X_SUB: assert property ( ((frc_X == equi_sub1[22:0]) && (frc_Y == equi_sub2[22:0])) -> (frc_Z_full == ({1'b0, frc_X} * {1'b0, frc_Y})) );

    // Booth: min frac -> propagación simple
    BOOTH_MINFRAC: assert property ( (!frc_X) -> (frc_Z_full[45:23] == frc_Y) );

    // Check: subnormales -> cero
    BOOTH_SUB_SON_ZERO: assert property ( Xsub -> (frc_Z_full[45:23] == frc_Y) );

    // Normalización: forma y sticky
    NORM_SHIFT_MANTISSA: assert property (
        ((frc_Z_norm[0] == |frc_Z_norm_check[21:0]) &&
         (frc_Z_norm[26:1] == frc_Z_norm_check[47:22]) &&
         (frc_Z_full[47] == norm_n))
        -> 1'b1
    );

    // Después de normalización, MSB = 1 si resultado no es subnormal
    NORM_MSB_UNO: assert property ( ((!Xsub && !Ynif && !Ysub && !Xnif)) -> (frc_Z_norm[26] == 1'b1) );

    // Normalización al multiplicar por 0
    NORM_ZERO: assert property ( ((fp_X == 32'h00000000) && !Ynif) -> (frc_Z_norm[25:3] == frc_Y) );

    // Subnormales -> mismo resultado que cero (normalización)
    NORM_SUB_SON_ZERO: assert property ( (Xsub && !Ynif) -> (frc_Z_norm[25:3] == frc_Y) );

    // Signo del resultado
    ROUND_SIGN: assert property ( (sign_Z) -> (sign_Z == (fp_X[31] ^ fp_Y[31])) );

    // Redondeos: compara frc_Z (salida) con mantissa_r_local calculada
    ROUND_RNZ: assert property ( (r_mode == 3'b000) -> (frc_Z == mantissa_r_local) );
    ROUND_RTZ: assert property ( (r_mode == 3'b001) -> (frc_Z == frc_Z_norm[25:3]) );
    ROUND_RDN: assert property ( (r_mode == 3'b010) -> (frc_Z == mantissa_r_rdn) );
    ROUND_RUP: assert property ( (r_mode == 3'b011) -> (frc_Z == mantissa_r_rup) );
    ROUND_RMM: assert property ( (r_mode == 3'b100) -> (frc_Z == mantissa_r_rmm) );

    // Carry producido por round (si se necesita chequear)
    ROUND_CARRY: assert property ( (norm_r) -> (carry_local[23]) );

    // Bias y exponente
    EXP_NORM: assert property ( (exp_Z == (fp_X[30:23] + fp_Y[30:23] - bias_local)) );

    // Underflow/Overflow checks (ejemplos)
    EXP_UDRF: assert property ( (udrf) -> ((fp_X[30:23] + fp_Y[30:23]) <= bias_local) );
    EXP_UDRF_MANTISA: assert property ( (udrf && !Xsub && !Ysub) -> (frc_Z == 23'b0) );
    EXP_OVRF: assert property ( (ovrf) -> ((fp_X[30:23] + fp_Y[30:23]) >= (bias_local + 8'd255)) );

    // Excepciones
    EXC_ZER: assert property ( (udrf || Ysub || Xsub) -> zer );
    EXC_SUB_SON_ZERO: assert property ( Xsub -> zer );

    EXC_INF: assert property ( inf -> ( ((fp_X[22:0] == 0) && &fp_X[30:23]) || ovrf || ((fp_Y[22:0] == 0) && &fp_Y[30:23]) ) );

    EXC_NAN: assert property ( nan -> (
                        ((|fp_X[22:0]) && &fp_X[30:23]) ||
                        (Ysub && ((fp_X[22:0] == 0) && &fp_X[30:23])) ||
                        (Xsub && ((fp_Y[22:0] == 0) && &fp_Y[30:23])) ||
                        ((|fp_Y[22:0]) && &fp_Y[30:23])
                      ) );

    // Pruebas concretas
    Z_PRUEBA: assert property ( (fp_X == 32'h40400000 && fp_Y == 32'h40400000 && r_mode == 3'b001) -> (fp_Z == 32'h41100000) );
    Z_PRUEBA_Underflow: assert property ( (fp_X == 32'h20000000 && fp_Y == 32'h1F800000 && r_mode == 3'b001) -> (fp_Z == 32'h00400000 && !udrf) );
    Z_PRUEBA_ZERO: assert property ( (fp_X == 32'h00000000 && fp_Y == 32'h00000000 && r_mode == 3'b001) -> ((fp_Z == 32'h00000000) && !udrf) );

endmodule
