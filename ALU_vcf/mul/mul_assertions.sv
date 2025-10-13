module fp_mul_checker (
    input logic [31:0]  fp_X,
    input logic [31:0]  fp_Y,
    input logic [31:0]  fp_Z,
    input logic [2:0]   r_mode,
    input logic         ovrf, 
    input logic         udrf,
    //internas
    input logic [47:0]  frc_Z_full,
    input logic [22:0]  frc_X, frc_Y
);
logic Xsub;
logic Xnif;
logic XZero;
logic Ysub;
logic Ynif;
logic YZero;
always_comb begin
    Xsub  = !(|fp_X[30:23]);
    Xnif  = (fp_X[30:23] == 8'hff) ? 1 : 0;
    XZero = (fp_X[30:0] == 31'b0) ? 1 : 0;

    Ysub  = !(|fp_Y[30:23]);
    Ynif  = (fp_X[30:23] == 8'hff) ? 1 : 0;
    YZero = (fp_Y[30:0] == 31'b0) ? 1 : 0;

    // MUN
    // Dice que los numeros subnormales
    MUL_SUB_SON_ZERO: assert (((Xsub ^ Ysub) && !Xnif && !Ynif) ->
                    (fp_Z[30:0] == 31'b0));
    // Dice que los numeros subnormales
    MUL_SUB_POR_SUB: assert (((Xsub && Ysub)) ->
                    (fp_Z[30:0] == 31'b0));

    MUL_ZERO_POR_NUM: assert (((fp_X[30:0] == 31'b0) && (fp_Y[30:0] == 31'b0)) ->
                    (fp_Z[30:0] == 31'b0));
end

endmodule