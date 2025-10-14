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

    man_Z_full = booth_radix4_multiply(frc_X, frc_Y);

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
    
    BOOTH_ENCODE: assert ((!Xsub && !Ynif && !Ysub && !Xnif)->(frc_Z_full == man_Z_full));
end

function automatic [47:0] booth_radix4_multiply(
    input logic [22:0] frc_X,
    input logic [22:0] frc_Y
);
    // Paso 1: Agregar el bit implícito '1' al MSB
    logic [23:0] mant_X = {1'b1, frc_X};
    logic [23:0] mant_Y = {1'b1, frc_Y};

    // Paso 2: Preparar para codificación Booth radix-4
    logic [47:0] product = 48'd0;
    logic [25:0] booth_Y = {mant_Y, 2'b0}; // 24 bits + 2 extra para radix-4

    // Paso 3: Codificación Booth radix-4
    for (int i = 0; i < 12; i++) begin
        logic [2:0] booth_bits = booth_Y[i*2 +: 3];
        logic signed [47:0] partial_product;
        logic signed [47:0] signed_mant_X = {24'd0, mant_X}; // cero-extensión

        case (booth_bits)
            3'b000, 3'b111: partial_product = 48'd0;
            3'b001, 3'b010: partial_product = signed_mant_X;
            3'b011:         partial_product = signed_mant_X <<< 1;
            3'b100:         partial_product = -(signed_mant_X <<< 1);
            3'b101, 3'b110: partial_product = -signed_mant_X;
            default:        partial_product = 48'd0;
        endcase

        product += partial_product <<< (2 * i);
    end

    return product;
endfunction



endmodule