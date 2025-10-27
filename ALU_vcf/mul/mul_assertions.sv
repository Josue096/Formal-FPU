module fp_mul_checker (
    input  logic [31:0]  fp_X,
    input  logic [31:0]  fp_Y,
    input  logic [31:0]  fp_Z,
    input  logic [2:0]   r_mode,
    input  logic         ovrf, 
    input  logic         udrf,
    // Internas
    //booth
    input  logic [47:0]  frc_Z_full,
    input  logic [22:0]  frc_X, frc_Y,
    //norm
    input  logic [26:0]  frc_Z_norm,
    input  logic         norm_n,
    //round
    input  logic         sign_Z,
    input  logic         norm_r,
    input  logic [22:0]  frc_Z,
    //exponente
    input  logic [7:0]   exp_Z
);

    // Flags subnormales, infinitos y ceros
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
        
        equi_norm1 = 32'h402df854;
        equi_norm2 = 32'h40490fdb;

        equi_sub1 = 32'h002df854;
        equi_sub2 = 32'h00490fdb;

        // Producto Booth
        //man_Z_full = {1'b1, frc_X} * {1'b1, frc_Y};

        // Aserciones
        
        MUL_SUB_SON_ZERO: assert (((Xsub && !Ynif) || (Ysub && !Xnif)) ->
                                  (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        MUL_SUB_POR_SUB: assert ((Xsub && Ysub) ->
                                 (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        MUL_ZERO_POR_ZERO: assert ((XZero && YZero) ->
                                (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        MUL_ZERO_POR_NUM: assert (((XZero && !Ynif) || (YZero && !Xnif)) ->
                                (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        BOOTH_NORM_X_NORM: assert (((frc_X == equi_norm1[22:0]) && (frc_Y == equi_norm2[22:0])) ->
                                (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y}));

        BOOTH_MAXFRAC_X_NORM: assert (((fp_X == 32'h3fffffff) && (frc_Y == equi_norm2[22:0])) ->
                                (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y}));
        
        BOOTH_MAXFRAC_X_MAXFRAC: assert (((fp_X == 32'h3fffffff) && (fp_Y== 32'h3fffffff)) ->
                                (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y}));
        
        BOOTH_NORM_X_SUB: assert (((frc_X == equi_sub1[22:0]) && (frc_Y == equi_norm2[22:0])) ->
                                (frc_Z_full == {1'b0, frc_X} * {1'b1, frc_Y}));

        BOOTH_SUB_X_SUB: assert (((frc_X == equi_sub1[22:0]) && (frc_Y == equi_sub2[22:0])) ->
                                (frc_Z_full == {1'b0, frc_X} * {1'b0, frc_Y}));

        BOOTH_MINFRAC: assert ((!frc_X) ->
                                (frc_Z_full[45:23] == frc_Y));
                                
        BOOTH_SUB_SON_ZERO: assert ((Xsub) ->
                                (frc_Z_full[45:23] == frc_Y));

        frc_Z_norm_check = (frc_Z_full[47])? frc_Z_full : {frc_Z_full[46:0],1'b0};

        NORM_SHIFT_MANTISSA_NORMALES: assert ((frc_Z_norm[0] == |frc_Z_norm_check[21:0]) 
                                && (frc_Z_norm[26:1] == frc_Z_norm_check[47:22])
                                && (frc_Z_full[47] == norm_n));

        NORM_MSB_UNO: assert ((!Xsub && !Ynif && !Ysub && !Xnif) -> (frc_Z_norm[26] == 1'b1));

        NORM_ZERO: assert (((fp_X[31:0] == 31'b0) && !Ynif) -> (frc_Z_norm[25:3] == frc_Y));

        NORM_SUB_SON_ZERO: assert ((Xsub && !Ynif) -> (frc_Z_norm[25:3] == frc_Y));

        ROUND_SIGN: assert (sign_Z == fp_X[31] ^ fp_Y[31]);

        case ({frc_Z_norm[2],(|frc_Z_norm[1:0])})
            2'b00: mantissa_r = frc_Z_norm[25:3];   
            2'b01: mantissa_r = frc_Z_norm[25:3]; 
            2'b10: mantissa_r = frc_Z_norm[3] ? frc_Z_norm[25:3] + 1'b1 : frc_Z_norm[25:3]; //si es impar redondea para arriba
            2'b11: mantissa_r = frc_Z_norm[25:3] + 1'b1;
            //default: mantissa_r = frc_Z_norm[25:3];
        endcase

        ROUND_RNZ: assert ((r_mode == 3'b000) -> frc_Z == mantissa_r);

        ROUND_RTZ: assert ((r_mode == 3'b001) -> frc_Z == frc_Z_norm[25:3]);

        case (sign_Z)
            1'b0: mantissa_r = frc_Z_norm[25:3];   
            1'b1: mantissa_r = frc_Z_norm[25:3] + 1'b1; 
            //default: mantissa_r = frc_Z_norm[25:3];
        endcase 

        ROUND_RDN: assert ((r_mode == 3'b010) -> frc_Z == mantissa_r);

        case (sign_Z)
            1'b0: mantissa_r = frc_Z_norm[25:3] + 1'b1;   
            1'b1: mantissa_r = frc_Z_norm[25:3]; 
            //default: mantissa_r = frc_Z_norm[25:3];
        endcase    

        ROUND_RUP: assert ((r_mode == 3'b011) -> frc_Z == mantissa_r);

        case (frc_Z_norm[2])
            1'b0: mantissa_r = frc_Z_norm[25:3];   
            1'b1: mantissa_r = frc_Z_norm[25:3] + 1'b1; 
            //default: mantissa_r = frc_Z_norm[25:3];
        endcase    

        ROUND_RMM: assert ((r_mode == 3'b100) -> frc_Z == mantissa_r);
        
        carry = {1'b0, frc_Z_norm[25:3]} + 1'b1;

        ROUND_CARRY: assert ((norm_r) -> (carry [23]));

        bias = (norm_n||norm_r) ? 8'b01111110 : 8'b01111111; 
        EXP_NORM: assert (exp_Z == fp_X[30:23]+fp_Y[30:23]-bias);

        EXP_UDRF: assert (((fp_X[30:23]+fp_Y[30:23]) <= 8'd127) -> udrf);

        EXP_OVRF: assert (((fp_X[30:23]+fp_Y[30:23]) >= (bias + 255)) -> ovrf);

        Z_PRUEBA: assert ((fp_X == 32'h40400000 && fp_Y == 32'h40400000 && r_mode == 3'b001) ->
                          (fp_Z == 32'h41100000));
                        
    end

endmodule
