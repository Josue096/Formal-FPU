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

    man_Z_full = booth_radix4_multiply({1'b1,frc_X}, {1'b1,frc_Y});

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

function automatic [47:0] booth_radix4_multiply;
    input [23:0] m, M;

    reg signed [47:0] eM, eM_bar, eM2, eM2_bar;
    reg signed [47:0] partial [0:11];
    integer i;

    reg [2:0] code;

    begin
        // Extiende el multiplicando M
        eM      = {{24{M[23]}}, M};           // Sign-extend M to 48 bits
        eM_bar  = -eM;
        eM2     = eM <<< 1;                   // Multiplica por 2
        eM2_bar = -eM2;

        // Genera los 12 códigos radix-4
        for (i = 0; i < 12; i = i + 1) begin
            case ({m[2*i+1], m[2*i], (i == 0 ? 1'b0 : m[2*i-1])})
                3'b000, 3'b111: code = 3'b000; // 0
                3'b001, 3'b010: code = 3'b001; // +1
                3'b011:         code = 3'b010; // +2
                3'b100:         code = 3'b101; // -2
                3'b101, 3'b110: code = 3'b100; // -1
                default:        code = 3'b000;
            endcase

            // Asigna el valor parcial según el código
            case (code)
                3'b000: partial[i] = 48'd0;
                3'b001: partial[i] = eM;
                3'b010: partial[i] = eM2;
                3'b100: partial[i] = eM_bar;
                3'b101: partial[i] = eM2_bar;
                default: partial[i] = 48'd0;
            endcase

            // Desplaza el parcial según su posición
            partial[i] = partial[i] <<< (2 * i);
        end

        // Suma todos los parciales
        booth_radix4_multiply = 48'd0;
        for (i = 0; i < 12; i = i + 1)
            booth_radix4_multiply = booth_radix4_multiply + partial[i];
    end
endfunction




endmodule