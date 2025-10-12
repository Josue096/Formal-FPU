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

always_comb begin
// MUL
MUL_IMPLICITO: assert (((|fp_X[30:23] == 0) || (|fp_Y[30:23] == 0)) ->
                (fp_Z[30:0] == 31'b0));
end

endmodule