//=====================================================
// Testbench para multiplicación de mantissas IEEE754
//=====================================================
`timescale 1ns/1ps

module tb_mantissa_mul;

  // --------------------------------------------------
  // Entradas (mantissas sin el bit implícito)
  // --------------------------------------------------
  logic [22:0] frc_X; 
  logic [22:0] frc_Y;

  // --------------------------------------------------
  // Salida (producto completo con bits extendidos)
  // --------------------------------------------------
  logic [47:0] man_Z_full;

  // --------------------------------------------------
  // Variables auxiliares (para mostrar valores IEEE754)
  // --------------------------------------------------
  logic [31:0] equi_norm1;  // -2.0
  logic [31:0] equi_norm2;  // +π ≈ 3.1415927

  initial begin
    // Inicialización
    equi_norm1 = 32'h002df854; // -2.0
    equi_norm2 = 32'h40490FDB; // +3.1415927

    frc_X = equi_norm1[22:0];
    frc_Y = equi_norm2[22:0];

    // --------------------------------------------------
    // Multiplicación de mantissas con bit implícito
    // --------------------------------------------------
    man_Z_full = {1'b0, frc_X} * {1'b1, frc_Y};

    // --------------------------------------------------
    // Impresión de resultados
    // --------------------------------------------------
    $display("==============================================");
    $display(" IEEE754 Mantissa Multiplication Test (VCS) ");
    $display("==============================================");
    $display("frc_X       = %b", frc_X);
    $display("frc_Y       = %b", frc_Y);
    $display("{1, frc_X}  = %b", {1'b1, frc_X});
    $display("{1, frc_Y}  = %b", {1'b1, frc_Y});
    $display("man_Z_full  = %b", man_Z_full);
    $display("man_Z_full (hex) = %h", man_Z_full);
    $display("man_Z_full[47:24] (24 bits normalizados?) = %b", man_Z_full[47:24]);
    $display("man_Z_full[46:24] (23 bits) = %b", man_Z_full[46:24]);
    $display("==============================================");

    $finish;
  end

endmodule
