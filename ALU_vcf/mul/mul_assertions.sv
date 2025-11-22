module fp_mul_checker (

    // Entradas principales
    input  logic [31:0]  fp_X,
    input  logic [31:0]  fp_Y,
    input  logic [31:0]  fp_Z,
    input  logic [2:0]   r_mode,
    input  logic         ovrf,
    input  logic         udrf,

    // Señales del bloque booth
    input  logic [47:0]  frc_Z_full,
    input  logic [22:0]  frc_X,
    input  logic [22:0]  frc_Y,

    // Señales del bloque norm
    input  logic [26:0]  frc_Z_norm,
    input  logic         norm_n,

    // Señales del bloque round
    input  logic         sign_Z,
    input  logic         norm_r,
    input  logic [22:0]  frc_Z,

    // Señales del bloque exponente
    input  logic [7:0]   exp_Z,
    input  logic         zer,
    input  logic         inf,
    input  logic         nan
);

  // =======================================
  // CLOCK VIRTUAL PARA VC FORMAL (VCF)
  // =======================================
  default clocking cb @(*) ; endclocking

  // =======================================
  // Variables auxiliares
  // =======================================
  logic Xsub, Xnif, XZero;
  logic Ysub, Ynif, YZero;

  logic [47:0] man_Z_full;
  logic [47:0] frc_Z_norm_check;

  logic [22:0] mantissa_r;
  logic [23:0] carry;

  logic [31:0] equi_norm1;
  logic [31:0] equi_norm2;
  logic [31:0] equi_sub1;
  logic [31:0] equi_sub2;
  logic [7:0]  bias;

  assign Xsub  = !(|fp_X[30:23]);
  assign Xnif  = (fp_X[30:23] == 8'hFF);
  assign XZero = (fp_X[30:0] == 31'b0);

  assign Ysub  = !(|fp_Y[30:23]);
  assign Ynif  = (fp_Y[30:23] == 8'hFF);
  assign YZero = (fp_Y[30:0] == 31'b0);

  assign equi_norm1 = 32'h402df854;
  assign equi_norm2 = 32'h40490fdb;
  assign equi_sub1  = 32'h002df854;
  assign equi_sub2  = 32'h00490fdb;

  assign frc_Z_norm_check = (frc_Z_full[47]) ? frc_Z_full : {frc_Z_full[46:0], 1'b0};

  assign carry = {1'b0, frc_Z_norm[25:3]} + 1'b1;

  assign bias = (norm_n || norm_r) ? 8'b01111110 : 8'b01111111;


  // =======================================
  // Assertions estilo formal (modo fp_adder)
  // =======================================

  MUL_SUB_SON_ZERO: assert property (
      ((Xsub && !Ynif) || (Ysub && !Xnif))
      -> (fp_Z == {(fp_X[31] ^ fp_Y[31]), 31'b0})
  );

  MUL_SUB_POR_SUB: assert property (
      (Xsub && Ysub)
      -> (fp_Z == {(fp_X[31] ^ fp_Y[31]), 31'b0})
  );

  MUL_ZERO_POR_ZERO: assert property (
      (XZero && YZero)
      -> (fp_Z == {(fp_X[31] ^ fp_Y[31]), 31'b0})
  );

  MUL_ZERO_POR_NUM: assert property (
      ((XZero && !Ynif) || (YZero && !Xnif))
      -> (fp_Z == {(fp_X[31] ^ fp_Y[31]), 31'b0})
  );

  BOOTH_NORM_X_NORM: assert property (
      ((frc_X == equi_norm1[22:0]) && (frc_Y == equi_norm2[22:0]))
      -> (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y})
  );

  BOOTH_MAXFRAC_X_NORM: assert property (
      ((fp_X == 32'h3fffffff) && (frc_Y == equi_norm2[22:0]))
      -> (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y})
  );

  BOOTH_MAXFRAC_X_MAXFRAC: assert property (
      ((fp_X == 32'h3fffffff) && (fp_Y == 32'h3fffffff))
      -> (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y})
  );

  BOOTH_NORM_X_SUB: assert property (
      ((frc_X == equi_sub1[22:0]) && (frc_Y == equi_norm2[22:0]))
      -> (frc_Z_full == {1'b0, frc_X} * {1'b1, frc_Y})
  );

  BOOTH_SUB_X_SUB: assert property (
      ((frc_X == equi_sub1[22:0]) && (frc_Y == equi_sub2[22:0]))
      -> (frc_Z_full == {1'b0, frc_X} * {1'b0, frc_Y})
  );

  BOOTH_MINFRAC: assert property (
      (!frc_X)
      -> (frc_Z_full[45:23] == frc_Y)
  );

  BOOTH_SUB_SON_ZERO: assert property (
      (Xsub)
      -> (frc_Z_full[45:23] == frc_Y)
  );

  NORM_SHIFT_MANTISSA: assert property (
      (frc_Z_norm[0] == |frc_Z_norm_check[21:0]) &&
      (frc_Z_norm[26:1] == frc_Z_norm_check[47:22]) &&
      (frc_Z_full[47] == norm_n)
  );

  NORM_MSB_UNO: assert property (
      (!Xsub && !Ynif && !Ysub && !Xnif)
      -> (frc_Z_norm[26] == 1'b1)
  );

  NORM_ZERO: assert property (
      ((fp_X == 31'b0) && !Ynif)
      -> (frc_Z_norm[25:3] == frc_Y)
  );

  NORM_SUB_SON_ZERO: assert property (
      (Xsub && !Ynif)
      -> (frc_Z_norm[25:3] == frc_Y)
  );

  ROUND_SIGN: assert property (
      (sign_Z == (fp_X[31] ^ fp_Y[31]))
  );

  // --- Rounding blocks replicated as properties ---

  ROUND_RNZ: assert property (
      (r_mode == 3'b000)
      -> (frc_Z == mantissa_r)
  );

  ROUND_RTZ: assert property (
      (r_mode == 3'b001)
      -> (frc_Z == frc_Z_norm[25:3])
  );

  ROUND_RDN: assert property (
      (r_mode == 3'b010)
      -> (frc_Z == mantissa_r)
  );

  ROUND_RUP: assert property (
      (r_mode == 3'b011)
      -> (frc_Z == mantissa_r)
  );

  ROUND_RMM: assert property (
      (r_mode == 3'b100)
      -> (frc_Z == mantissa_r)
  );

  ROUND_CARRY: assert property (
      (norm_r)
      -> (carry[23])
  );

  EXP_NORM: assert property (
      (exp_Z == fp_X[30:23] + fp_Y[30:23] - bias)
  );

  EXP_UDRF: assert property (
      (udrf -> ((fp_X[30:23] + fp_Y[30:23]) <= bias))
  );

  EXP_UDRF_MANTISA: assert property (
      (udrf && !Xsub && !Ysub)
      -> (frc_Z == 23'b0)
  );

  EXP_OVRF: assert property (
      (ovrf -> ((fp_X[30:23] + fp_Y[30:23]) >= (bias + 255)))
  );

  EXC_ZER: assert property (
      (udrf || Ysub || Xsub)
      -> (zer)
  );

  EXC_SUB_SON_ZERO: assert property (
      (Xsub)
      -> (zer)
  );

  EXC_INF: assert property (
      (inf -> (((fp_X[22:0] == 0) && &fp_X[30:23]) || ovrf ||
               ((fp_Y[22:0] == 0) && &fp_Y[30:23])))
  );

  EXC_NAN: assert property (
      (nan -> (((|fp_X[22:0]) && &fp_X[30:23]) ||
                (Ysub && ((fp_X[22:0] == 0) && &fp_X[30:23])) ||
                (Xsub && ((fp_Y[22:0] == 0) && &fp_Y[30:23])) ||
                ((|fp_Y[22:0]) && &fp_Y[30:23])))
  );

  Z_PRUEBA: assert property (
      (fp_X == 32'h40400000 && fp_Y == 32'h40400000 && r_mode == 3'b001)
      -> (fp_Z == 32'h41100000)
  );

  Z_PRUEBA_Underflow: assert property (
      (fp_X == 32'h20000000 && fp_Y == 32'h1F800000 && r_mode == 3'b001)
      -> (fp_Z == 32'h00400000 && !udrf)
  );

  Z_PRUEBA_ZERO: assert property (
      (fp_X == 32'h00000000 && fp_Y == 32'h00000000 && r_mode == 3'b001)
      -> (fp_Z == 32'h00000000 && !udrf)
  );

endmodule
