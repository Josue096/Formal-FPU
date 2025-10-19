module fp_mul_checker (
    input  logic [31:0]  fp_X,
    input  logic [31:0]  fp_Y,
    input  logic [31:0]  fp_Z,
    input  logic [2:0]   r_mode,
    input  logic         ovrf, 
    input  logic         udrf,
    // Internas
    input  logic [47:0]  frc_Z_full,
    input  logic [22:0]  frc_X, frc_Y
);

    // Flags subnormales, infinitos y ceros
    logic Xsub, Xnif, XZero;
    logic Ysub, Ynif, YZero;

    logic [47:0] man_Z_full;

    // Combinacional
    always_comb begin
        // Flags X
        Xsub  = !(|fp_X[30:23]);
        Xnif  = (fp_X[30:23] == 8'hFF);
        XZero = (fp_X[30:0] == 31'b0);

        // Flags Y
        Ysub  = !(|fp_Y[30:23]);
        Ynif  = (fp_Y[30:23] == 8'hFF);
        YZero = (fp_Y[30:0] == 31'b0);

        // Producto Booth
        man_Z_full = booth_radix4_multiply({1'b1, frc_X}, {1'b1, frc_Y});

        // Aserciones
        MUL_SUB_SON_ZERO: assert (((Xsub && !Ynif) || (Ysub && !Xnif)) ->
                                  (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        MUL_SUB_POR_SUB: assert ((Xsub && Ysub) ->
                                 (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        MUL_ZERO_POR_ZERO: assert ((XZero && YZero) ->
                                   (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        MUL_ZERO_POR_NUM: assert (((XZero && !Ynif) || (YZero && !Xnif)) ->
                                  (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        BOOTH_ENCODE: assert ((!Xsub && !Ynif && !Ysub && !Xnif) ->
                              (frc_Z_full == man_Z_full));
    end

    // ======================
    // Función Radix-4 Encoder
    // ======================
    function automatic logic [2:0] radix4_encoder(input logic [2:0] inp);
        return {inp[2] & (~inp[1] | ~inp[0]),
                (~inp[2] & inp[1] & inp[0]) | (inp[2] & ~inp[1] & ~inp[0]),
                (~inp[1] & inp[0]) | (inp[1] & ~inp[0])};
    endfunction

    // ========================================
    // Función Extend 24 bits (eM, eM_bar, eM2)
    // ========================================
    function automatic void extend_24_func(
        input  logic [23:0] M,
        output logic [47:0] eM,
        output logic [47:0] eM_bar,
        output logic [47:0] eM2,
        output logic [47:0] eM2_bar
    );
        eM      = M[23] ? {24'hFFFFFF, M} : {24'h000000, M};
        eM_bar  = -eM;
        eM2     = eM << 1;
        eM2_bar = -eM2;
    endfunction

    // ========================================
    // Función Booth Radix-4 Multiply
    // ========================================
    function automatic [47:0] booth_radix4_multiply(input logic [23:0] m, input logic [23:0] M);
        logic [2:0] code [0:11];
        logic [47:0] eM, eM_bar, eM2, eM2_bar;
        logic [47:0] v [0:11];

        // Codificación Booth
        code[0]  = radix4_encoder({m[1],  m[0],  1'b0});
        code[1]  = radix4_encoder({m[3],  m[2],  m[1]});
        code[2]  = radix4_encoder({m[5],  m[4],  m[3]});
        code[3]  = radix4_encoder({m[7],  m[6],  m[5]});
        code[4]  = radix4_encoder({m[9],  m[8],  m[7]});
        code[5]  = radix4_encoder({m[11], m[10], m[9]});
        code[6]  = radix4_encoder({m[13], m[12], m[11]});
        code[7]  = radix4_encoder({m[15], m[14], m[13]});
        code[8]  = radix4_encoder({m[17], m[16], m[15]});
        code[9]  = radix4_encoder({m[19], m[18], m[17]});
        code[10] = radix4_encoder({m[21], m[20], m[19]});
        code[11] = radix4_encoder({m[23], m[22], m[21]});

        // Extensión de M
        extend_24_func(M, eM, eM_bar, eM2, eM2_bar);

        // Productos parciales
        for (int i = 0; i < 12; i++) begin
            v[i] = (code[i] == 3'b000) ? 48'd0 :
                   (code[i][1] ? (code[i][2] ? eM2_bar : eM2) :
                                 (code[i][2] ? eM_bar  : eM));
        end

        // Suma de productos parciales
        booth_radix4_multiply = 0;
        for (int i = 0; i < 12; i++) begin
            booth_radix4_multiply += (v[i] << (2*i));
        end
    endfunction

endmodule
