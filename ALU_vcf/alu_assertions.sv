module fp_alu_checker #(
    parameter int ADDR_W = 3
)(
    input logic [ADDR_W-1:0] op_code_i,
    input logic [31:0]       fp_a_i,
    input logic [31:0]       fp_b_i,
    input logic [31:0]       fp_c_i,
    input logic [2:0]        r_mode_i,

    input logic [31:0]       fp_result_o,
    input logic              overflow_o,
    input logic              underflow_o,
    input logic              cmp_result_o,
    input logic              invalid_o
);

// Propiedad: ADD 0.0 + 0.0 = 0.0
property add_zero_zero;
  (op_code_i == 3'b000 && fp_a_i == 32'h00000000 && fp_b_i == 32'h00000000)
    |-> (fp_result_o == 32'h00000000 && overflow_o == 0 && underflow_o == 0);
endproperty
assert property(add_zero_zero);

// Propiedad: MUL por 0 → resultado 0
property mul_zero;
  (op_code_i == 3'b010 &&
   (fp_a_i == 32'h00000000 || fp_a_i == 32'h80000000 ||
    fp_b_i == 32'h00000000 || fp_b_i == 32'h80000000))
    |-> (fp_result_o == 32'h00000000 && overflow_o == 0 && underflow_o == 0);
endproperty
assert property(mul_zero);



