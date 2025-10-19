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
                              (frc_Z_full == {1'b1,frc_X }* {1'b1,frc_Y }));
    end

    
endmodule
