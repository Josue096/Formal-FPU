/****************************************************************************************
 * Archivo       : change_sign.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Este módulo se encarga de cambiar el signo a un numero en formato IEEE754
                   si es el numero es un NaN no cambia el signo para no cambiar la representacion
 * Instancias    : fp_alu, fp_sub, fp_msub
 ****************************************************************************************/


module change_sign (
    input  logic [31:0] fp_b,  
    
    output logic [31:0] fp_bsub  
);
    always_comb begin
        // Si fp_b es NaN (exp=255, mantisa≠0), mantenerlo sin cambio de signo
        if (fp_b[30:23] == 8'hFF && fp_b[22:0] != 0) begin
            fp_bsub = fp_b;  
        end else begin
            fp_bsub = {~fp_b[31], fp_b[30:0]}; // Invertir signo
        end
    end
endmodule
