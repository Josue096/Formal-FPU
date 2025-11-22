module fp_mul_checker (
    input  logic [31:0]  fp_X,
    input  logic [31:0]  fp_Y,
    input  logic [31:0]  fp_Z,
    input  logic [2:0]   r_mode,
    input  logic         ovrf, 
    input  logic         udrf,

    //Senales del bloque booth
    input  logic [47:0]  frc_Z_full,
    input  logic [22:0]  frc_X, frc_Y,

    //Senales del bloque norm
    input  logic [26:0]  frc_Z_norm,
    input  logic         norm_n,

    //Senales del bloque round
    input  logic         sign_Z,
    input  logic         norm_r,
    input  logic [22:0]  frc_Z,

    //Senales del bloque exponente
    input  logic [7:0]   exp_Z,
    input  logic         zer, inf, nan
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

    logic [31:0]  z;

    // Combinacional
    always_comb begin
        // Flags X
        Xsub  = !(|fp_X[30:23]); //Sub o cero
        Xnif  = (fp_X[30:23] == 8'hFF); //Nan o inf
        XZero = (fp_X[30:0] == 31'b0);

        // Flags Y
        Ysub  = !(|fp_Y[30:23]); //Sub o cero
        Ynif  = (fp_Y[30:23] == 8'hFF); //Nan o inf
        YZero = (fp_Y[30:0] == 31'b0);
        
        equi_norm1 = 32'h402df854;
        equi_norm2 = 32'h40490fdb;

        equi_sub1 = 32'h002df854;
        equi_sub2 = 32'h00490fdb;

        //man_Z_full = {1'b1, frc_X} * {1'b1, frc_Y};

        // Aserciones
        
        //Numeros subnormales producen el mismo resultado que cero
        MUL_SUB_SON_ZERO: assert (((Xsub && !Ynif) || (Ysub && !Xnif)) ->
                                  (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        //Multiplicacion de dos numeros subnormales
        MUL_SUB_POR_SUB: assert ((Xsub && Ysub) ->
                                 (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        //Multiplicacion de 0 * 0
        MUL_ZERO_POR_ZERO: assert ((XZero && YZero) ->
                                (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        //Multiplicacion de cero por cualquier numero que no se infinito o NaN
        MUL_ZERO_POR_NUM: assert (((XZero && !Ynif) || (YZero && !Xnif)) ->
                                (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

        //Booth encoding de las mantisas de dos numeros normales
        BOOTH_NORM_X_NORM: assert (((frc_X == equi_norm1[22:0]) && (frc_Y == equi_norm2[22:0])) ->
                                (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y}));//frc_Z_full = {1'b1, frc_X} * {1'b1, frc_Y};

        //Booth encoding de las mantisas de valor maximo por un normal
        BOOTH_MAXFRAC_X_NORM: assert (((fp_X == 32'h3fffffff) && (frc_Y == equi_norm2[22:0])) ->
                                (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y}));
        
        //Booth encoding de 2 mantisas de valor maximo  
        BOOTH_MAXFRAC_X_MAXFRAC: assert (((fp_X == 32'h3fffffff) && (fp_Y== 32'h3fffffff)) ->
                                (frc_Z_full == {1'b1, frc_X} * {1'b1, frc_Y}));
        
        //Booth encoding de las mantisas subnormal por un normal
        BOOTH_NORM_X_SUB: assert (((frc_X == equi_sub1[22:0]) && (frc_Y == equi_norm2[22:0])) ->
                                (frc_Z_full == {1'b0, frc_X} * {1'b1, frc_Y}));

        //Booth encoding de las mantisas subnormal por un subnormal
        BOOTH_SUB_X_SUB: assert (((frc_X == equi_sub1[22:0]) && (frc_Y == equi_sub2[22:0])) ->
                                (frc_Z_full == {1'b0, frc_X} * {1'b0, frc_Y}));
    
        //Booth encoding de las mantisas valor minimo por cualquier valor
        BOOTH_MINFRAC: assert ((!frc_X) ->
                                (frc_Z_full[45:23] == frc_Y));

        //Chechk: numeros subnormales producen el mismo resultado que cero                       
        BOOTH_SUB_SON_ZERO: assert ((Xsub) ->
                                (frc_Z_full[45:23] == frc_Y));

        frc_Z_norm_check = (frc_Z_full[47])? frc_Z_full : {frc_Z_full[46:0],1'b0};//Dado el diagrama de Vianney

        //Normalizacion de numeros 
        NORM_SHIFT_MANTISSA: assert ((frc_Z_norm[0] == |frc_Z_norm_check[21:0]) 
                                && (frc_Z_norm[26:1] == frc_Z_norm_check[47:22])
                                && (frc_Z_full[47] == norm_n));

        //Despues de la normalizacion siempre el primer bit es 1 si el resultado no es subnormal
        NORM_MSB_UNO: assert ((!Xsub && !Ynif && !Ysub && !Xnif) -> (frc_Z_norm[26] == 1'b1));

        //Normalizacion de multiplicar por 0
        NORM_ZERO: assert (((fp_X[31:0] == 31'b0) && !Ynif) -> (frc_Z_norm[25:3] == frc_Y));

        //Chechk: numeros subnormales producen el mismo resultado que cero  
        NORM_SUB_SON_ZERO: assert ((Xsub && !Ynif) -> (frc_Z_norm[25:3] == frc_Y));

        //Calculo del signo
        ROUND_SIGN: assert (sign_Z == fp_X[31] ^ fp_Y[31]);

        //Redondeo al mas cercano (pares en empate)
        case ({frc_Z_norm[2],(|frc_Z_norm[1:0])})
            2'b00: mantissa_r = frc_Z_norm[25:3];   
            2'b01: mantissa_r = frc_Z_norm[25:3]; 
            2'b10: mantissa_r = frc_Z_norm[3] ? frc_Z_norm[25:3] + 1'b1 : frc_Z_norm[25:3]; //si es impar redondea para arriba
            2'b11: mantissa_r = frc_Z_norm[25:3] + 1'b1;
            //default: mantissa_r = frc_Z_norm[25:3];
        endcase

        ROUND_RNZ: assert ((r_mode == 3'b000) -> frc_Z == mantissa_r);

        //Redondeo hacia cero
        ROUND_RTZ: assert ((r_mode == 3'b001) -> frc_Z == frc_Z_norm[25:3]);

        //Redondeo hacia abajo
        case (sign_Z)
            1'b0: mantissa_r = frc_Z_norm[25:3];   
            1'b1: mantissa_r = frc_Z_norm[25:3] + 1'b1; 
            //default: mantissa_r = frc_Z_norm[25:3];
        endcase 

        ROUND_RDN: assert ((r_mode == 3'b010) -> frc_Z == mantissa_r);

        //Redondeo hacia arriba
        case (sign_Z)
            1'b0: mantissa_r = frc_Z_norm[25:3] + 1'b1;   
            1'b1: mantissa_r = frc_Z_norm[25:3]; 
            //default: mantissa_r = frc_Z_norm[25:3];
        endcase    

        ROUND_RUP: assert ((r_mode == 3'b011) -> frc_Z == mantissa_r);

        //Redondeo al mas cercano (maxima magnitud en empate)
        case (frc_Z_norm[2])
            1'b0: mantissa_r = frc_Z_norm[25:3];   
            1'b1: mantissa_r = frc_Z_norm[25:3] + 1'b1; 
            //default: mantissa_r = frc_Z_norm[25:3];
        endcase    

        ROUND_RMM: assert ((r_mode == 3'b100) -> frc_Z == mantissa_r);

        //Se genera carry por redondeo
        carry = {1'b0, frc_Z_norm[25:3]} + 1'b1;
        ROUND_CARRY: assert ((norm_r) -> (carry [23]));

        bias = (norm_n||norm_r) ? 8'b01111110 : 8'b01111111; //si hubo un carry por round o normalizacion

        //Calculo del exponenete
        EXP_NORM: assert (exp_Z == fp_X[30:23]+fp_Y[30:23]-bias);

        //Si ocurre un underflow por exponente
        EXP_UDRF: assert (udrf -> ((fp_X[30:23]+fp_Y[30:23]) <= bias));
        EXP_UDRF_MANTISA: assert ((udrf && !Xsub && !Ysub) -> ((frc_Z) == 23'b0));
        //Si ocurre un overflow
        EXP_OVRF: assert (ovrf -> ((fp_X[30:23]+fp_Y[30:23]) >= (bias + 255)));

        //Si algun input es subnormal, zero o se produce un underflow
        EXC_ZER: assert ((udrf||Ysub||Xsub) -> zer);

        //Chechk: numeros subnormales producen el mismo resultado que cero 
        EXC_SUB_SON_ZERO: assert ((Xsub) -> zer);

        //Si algun input es inf o se produce un overflow
        EXC_INF: assert (inf ->
                        (( (fp_X[22:0] == 0) && &fp_X[30:23]) || ovrf
                        || ((fp_Y[22:0] == 0) && &fp_Y[30:23])));

        //Si algun input es NaN o se esta intentando multiplicar un inf por cero
        EXC_NAN: assert (nan-> 
                        (((|fp_X[22:0]) && &fp_X[30:23]) 
                        || (Ysub && ((fp_X[22:0] == 0) && &fp_X[30:23])) 
                        || (Xsub && ((fp_Y[22:0] == 0) && &fp_Y[30:23]))
                        || ((|fp_Y[22:0]) && &fp_Y[30:23])));
        z = {sign_Z, exp_Z, frc_Z};
        NET_NAN: assert (nan -> fp_Z == 32'h7fc00000);

        NET_INF: assert (inf -> fp_Z == {z[31], 8'hff, 23'b0});

        NET_ZERO: assert (zer -> fp_Z == {z[31], 8'h0, 23'b0});

        NET_Z: assert (!nan && !inf && !zer && (z!=33'hffc00000) -> fp_Z == z);

        //Z_PRUEBA: assert ((fp_X == 32'h40400000 && fp_Y == 32'h40400000 && r_mode == 3'b001) ->
        //                  (fp_Z == 32'h41100000));           
        //Z_PRUEBA_Underflow: assert ((fp_X == 32'h20000000 && fp_Y == 32'h1F800000 && r_mode == 3'b001) ->
        //                  (fp_Z == 32'h00400000 && !udrf));     
        //Z_PRUEBA_ZERO: assert ((fp_X == 32'h00000000 && fp_Y == 32'h00000000 && r_mode == 3'b001) ->
        //                  (fp_Z == 32'h00000000) && !udrf);
    end
endmodule