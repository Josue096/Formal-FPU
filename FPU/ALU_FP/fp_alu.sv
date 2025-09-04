/****************************************************************************************
 * Archivo       : fp_alu.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   : Modulo principal del proyecto. Es el núcleo del proyecto y se conecta 
                   directamente a los demas módulos. Según el valor de `op_code_i`, direcciona 
                   las entradas hacia el módulo correspondiente activando únicamente el bloque 
                   necesario mediante lógica de gating completamente combinacional.
 ****************************************************************************************/
 
 
module fp_alu #(
    parameter int addr_width = 3
)(
    // INPUTS
    input  logic [addr_width-1 :0] op_code_i,
    input  logic [31:0]            fp_a_i,
    input  logic [31:0]            fp_b_i,
    input  logic [31:0]            fp_c_i,
    input  logic [2:0]             r_mode_i,

    // OUTPUTS
    output logic [31:0]            fp_result_o,
    output logic                   overflow_o,
    output logic                   underflow_o,
    output logic                   cmp_result_o,
    output logic                   invalid_o
);

    // Constantes para la seleccion de cada modulo de acuerdo con op_code_i
    typedef enum logic [addr_width-1 :0] {
        FADD   = 3'd0,
        FSUB   = 3'd1,
        FMUL   = 3'd2,
        FMADD  = 3'd3,
        FMSUB  = 3'd4,
        FEQ    = 3'd5,
        FLT    = 3'd6,
        FLE    = 3'd7
    } fp_op_code_e;

    ///////////////////////////////////
    // Señales para el manejo de gating 
    ///////////////////////////////////

    // Señales para las entradas de cada modulo
    logic [31:0] a_add,  b_add,  a_sub, b_sub;                
    logic [31:0] a_mul,  b_mul;
    logic [31:0] a_madd, b_madd, c_madd;
    logic [31:0] a_msub, b_msub, c_msub;
    logic [31:0] a_eq,   b_eq,   a_lt, b_lt, a_le, b_le;

    // Señales para los redondeos de cada modulo aritmetico
    logic [2:0]  rm_add, rm_sub, rm_mul, rm_madd, rm_msub;

    // Señales de los resultados de cada modulo
    logic [31:0] add_res, sub_res, mul_res, madd_res, msub_res; 
    logic        eq_res,  lt_res,  le_res;

    // Señales para resultados de overflow_o/underflow_o
    logic        add_ovr,  add_udr;
    logic        sub_ovr,  sub_udr;
    logic        mul_ovr,  mul_udr;
    logic        madd_ovr, madd_udr;
    logic        msub_ovr, msub_udr;


    //////////////////////
    // Gating de entrada
    //////////////////////

    // assigns para el gating del sumador
    assign a_add   = (op_code_i == FADD)  ? fp_a_i   : 32'd0;
    assign b_add   = (op_code_i == FADD)  ? fp_b_i   : 32'd0;
    assign rm_add  = (op_code_i == FADD)  ? r_mode_i : 3'd0;
    
    // assigns para el gating del restados
    assign a_sub   = (op_code_i == FSUB)  ? fp_a_i   : 32'd0;
    assign b_sub   = (op_code_i == FSUB)  ? fp_b_i   : 32'd0;
    assign rm_sub  = (op_code_i == FSUB)  ? r_mode_i : 3'd0;

    // assigns para el gating del multiplicador
    assign a_mul   = (op_code_i == FMUL)  ? fp_a_i   : 32'd0;
    assign b_mul   = (op_code_i == FMUL)  ? fp_b_i   : 32'd0;
    assign rm_mul  = (op_code_i == FMUL)  ? r_mode_i : 3'd0;

    // assigns para el gating de (axb)+c
    assign a_madd  = (op_code_i == FMADD) ? fp_a_i   : 32'd0;
    assign b_madd  = (op_code_i == FMADD) ? fp_b_i   : 32'd0;
    assign c_madd  = (op_code_i == FMADD) ? fp_c_i   : 32'd0;
    assign rm_madd = (op_code_i == FMADD) ? r_mode_i : 3'd0;

    // assigns para el gating de (axb)-c
    assign a_msub  = (op_code_i == FMSUB) ? fp_a_i   : 32'd0;
    assign b_msub  = (op_code_i == FMSUB) ? fp_b_i   : 32'd0;
    assign c_msub  = (op_code_i == FMSUB) ? fp_c_i   : 32'd0;
    assign rm_msub = (op_code_i == FMSUB) ? r_mode_i : 3'd0;

    // assigns para el gating de a=b
    assign a_eq    = (op_code_i == FEQ)   ? fp_a_i   : 32'd0;
    assign b_eq    = (op_code_i == FEQ)   ? fp_b_i   : 32'd0;

    // assigns para el gating de a<b
    assign a_lt    = (op_code_i == FLT)   ? fp_a_i   : 32'd0;
    assign b_lt    = (op_code_i == FLT)   ? fp_b_i   : 32'd0;

    // assigns para el gating de a<=b
    assign a_le    = (op_code_i == FLE)   ? fp_a_i   : 32'd0;
    assign b_le    = (op_code_i == FLE)   ? fp_b_i   : 32'd0;


    ///////////////////////////////////////////////////////////////
    // Instanciación de módulos, entradas controladas por el gating
    ///////////////////////////////////////////////////////////////

    // Instancia sumador
    fp_adder u_add (
        .fp_a       (a_add),
        .fp_b       (b_add),
        .r_mode     (rm_add),
        .fp_result  (add_res),
        .overflow   (add_ovr),
        .underflow  (add_udr)
    );

    // Instancia restador
    fp_sub u_sub (
        .fp_a       (a_sub),
        .fp_b       (b_sub),
        .r_mode     (rm_sub),
        .fp_result  (sub_res),
        .overflow   (sub_ovr),
        .underflow  (sub_udr)
    );

    // Instancia multiplicador
    fp_mul u_mul (
        .fp_X       (a_mul),
        .fp_Y       (b_mul),
        .r_mode     (rm_mul),
        .fp_Z       (mul_res),
        .ovrf       (mul_ovr),
        .udrf       (mul_udr)
    );

    // Instancia (a x b)+c
    fp_madd u_madd (
        .fp_a       (a_madd),
        .fp_b       (b_madd),
        .fp_c       (c_madd),
        .r_mode     (rm_madd),
        .fp_result  (madd_res),
        .overflow   (madd_ovr),
        .underflow  (madd_udr)
    );

    // Instancia (a x b)-c
    fp_msub u_msub (
        .fp_a       (a_msub),
        .fp_b       (b_msub),
        .fp_c       (c_msub),
        .r_mode     (rm_msub),
        .fp_result  (msub_res),
        .overflow   (msub_ovr),
        .underflow  (msub_udr)
    );

    // Instancia a=b
    fp_feq u_feq (
        .fp_a       (a_eq),
        .fp_b       (b_eq),
        .eq         (eq_res)
    );

    // Instancia a<b
    fp_flt u_flt (
        .fp_a       (a_lt),
        .fp_b       (b_lt),
        .lt         (lt_res)
    );

    // Instancia a<=b
    fp_fle u_fle (
        .fp_a       (a_le),
        .fp_b       (b_le),
        .le         (le_res)
    );

    // Lógica de selección de salida
    always_comb begin
        fp_result_o  = 32'd0;
        overflow_o   = 1'b0;
        underflow_o  = 1'b0;
        cmp_result_o = 1'b0;
        invalid_o    = 1'b0;

        // Salidas controladas por op_code_i
        case (op_code_i)

            FADD: begin
                fp_result_o  = add_res;
                overflow_o   = add_ovr;
                underflow_o  = add_udr;
            end

            FSUB: begin
                fp_result_o  = sub_res;
                overflow_o   = sub_ovr;
                underflow_o  = sub_udr;
            end

            FMUL: begin
                fp_result_o  = mul_res;
                overflow_o   = mul_ovr;
                underflow_o  = mul_udr;
            end

            FMADD: begin
                fp_result_o  = madd_res;
                overflow_o   = madd_ovr;
                underflow_o  = madd_udr;
            end

            FMSUB: begin
                fp_result_o  = msub_res;
                overflow_o   = msub_ovr;
                underflow_o  = msub_udr;
            end

            FEQ: begin 
                cmp_result_o = eq_res;
            end

            FLT: begin 
                cmp_result_o = lt_res;
            end

            FLE: begin 
                cmp_result_o = le_res;
            end
            default: begin
                fp_result_o  = 32'd0;
                overflow_o   = 1'b0;
                underflow_o  = 1'b0;
                cmp_result_o = 1'b0;
            end
        endcase

        // Señal invalid : NaN o under/overflow_o
        if (op_code_i inside {FADD, FSUB, FMUL, FMADD, FMSUB}) begin
            
            invalid_o = (fp_result_o == 32'h7fc00000) || overflow_o || underflow_o;

        end else begin
            invalid_o = 1'b0;

        end
    end

endmodule
