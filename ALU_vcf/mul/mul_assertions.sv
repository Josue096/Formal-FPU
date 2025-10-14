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

logic [47:0] man_Z_full;

always_comb begin
    Xsub  = !(|fp_X[30:23]);
    Xnif  = (fp_X[30:23] == 8'hff) ? 1 : 0;
    XZero = (fp_X[30:0] == 31'b0) ? 1 : 0;

    Ysub  = !(|fp_Y[30:23]);
    Ynif  = (fp_Y[30:23] == 8'hff) ? 1 : 0;
    YZero = (fp_Y[30:0] == 31'b0) ? 1 : 0;

    man_Z_full = booth_radix4(frc_X, frc_Y);

    // MUN
    // Dice que los numeros subnormales
    MUL_SUB_SON_ZERO: assert ((((Xsub && !Ynif) || (Ysub && !Xnif))) ->
                    (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));
    // Dice que los numeros subnormales
    MUL_SUB_POR_SUB: assert (((Xsub && Ysub)) ->
                    (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));
    
    MUL_ZERO_POR_ZERO: assert (((XZero && YZero)) ->
                    (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));

    MUL_ZERO_POR_NUM: assert ((((XZero && !Ynif) || (YZero && !Xnif))) ->
                    (fp_Z == {(fp_X[31] ^ fp_Y[31]),31'b0}));
    
    BOOTH_ENCODE: assert (fp_Z == man_Z_full);
end

function automatic logic signed [47:0] booth_radix4 (
    input logic [22:0] frc_X,   // mantisa X sin bit implícito
    input logic [22:0] frc_Y    // mantisa Y sin bit implícito
);
    // Parámetros locales
    localparam int WIDTH  = 24;               // 23 + 1 (bit implícito)
    localparam int DIGITS = (WIDTH + 1) / 2;  // 12 grupos radix-4

    // Variables internas
    logic [WIDTH:0] Y_ext;                    // multiplicador extendido
    logic signed [47:0] result;
    integer i;

    // función decodificadora de 3 bits a -2..+2
    function automatic signed [2:0] booth_decode(input logic [2:0] bits);
        case (bits)
            3'b000: booth_decode =  0;
            3'b001: booth_decode = +1;
            3'b010: booth_decode = +1;
            3'b011: booth_decode = +2;
            3'b100: booth_decode = -2;
            3'b101: booth_decode = -1;
            3'b110: booth_decode = -1;
            3'b111: booth_decode =  0;
            default: booth_decode = 0;
        endcase
    endfunction

    // Extender el multiplicador (bit implícito + y[-1]=0)
    Y_ext = {1'b1, frc_Y, 1'b0};

    // Inicializar acumulador
    result = '0;

    // Generar los productos parciales y acumular
    for (i = 0; i < DIGITS; i++) begin
        logic [2:0] triple = Y_ext[2*i +: 3];
        automatic signed [2:0] digit = booth_decode(triple);

        // multiplicando extendido a 48 bits
        logic signed [47:0] X_ext = {{(48-WIDTH){1'b0}}, frc_X};

        // generar producto parcial según digit
        logic signed [47:0] partial;
        case (digit)
            +2: partial =  (X_ext <<< 1);
            +1: partial =   X_ext;
             0: partial =  48'sd0;
            -1: partial = -(X_ext);
            -2: partial = -(X_ext <<< 1);
            default: partial = 48'sd0;
        endcase

        // desplazar según el peso del grupo (2*i)
        partial = partial <<< (2*i);

        // acumular en el resultado
        result += partial;
    end

    return result;
endfunction


endmodule