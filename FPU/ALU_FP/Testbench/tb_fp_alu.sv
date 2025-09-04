/****************************************************************************************
 * Archivo       : tb_fp_alu.sv
 * Proyecto      : Unidad en punto flotante estandar IEEE 754
 * Autor         : Samuel Cabrera A
 * Fecha         : 1S 2025
 * Descripción   :
 * Testbench para verificar la ALU en punto flotante IEEE-754 (binary32) mediante
 * operaciones aritméticas (FADD, FSUB, FMUL, FMA) y comparaciones (FEQ, FLT, FLE).
 * Incluye redondeo y pruebas con valores normales, subnormales, ceros,
 * infinitos y NaN. Se crean tareas para cada operacion y structs para los testcases
 * Se muestra en resumen de resultados obtenidos al final (PASS, FAIL, PRECISION)
 ****************************************************************************************/

module tb_fp_alu;

    // Parámetros
    localparam int ADDR_WIDTH = 3;
    localparam     RNE        = 3'b000;
    localparam     RTZ        = 3'b001;
    localparam     RDN        = 3'b010;
    localparam     RUP        = 3'b011;
    localparam     RMM        = 3'b100;

    real pass_rate;

    // Entradas
    logic [ADDR_WIDTH-1:0] op_code_i;
    logic [31:0]           fp_a_i;
    logic [31:0]           fp_b_i;
    logic [31:0]           fp_c_i;
    logic [2:0]            r_mode_i;

    // Salidas
    logic [31:0]           fp_result_o;
    logic                  overflow_o;
    logic                  underflow_o;
    logic                  cmp_result_o;
    logic                  invalid_o;

    int test_count  = 0;  // Contador total de test cases ejecutados
    int error_count = 0;  // Contador de pruebas con error
    int pass_count  = 0;  // Contador de pruebas correctas

    // DUT
    fp_alu #(
        .addr_width(ADDR_WIDTH)
    ) dut (
        .op_code_i   (op_code_i),
        .fp_a_i      (fp_a_i),
        .fp_b_i      (fp_b_i),
        .fp_c_i      (fp_c_i),
        .r_mode_i    (r_mode_i),
        .fp_result_o (fp_result_o),
        .overflow_o  (overflow_o),
        .underflow_o (underflow_o),
        .cmp_result_o(cmp_result_o),
        .invalid_o   (invalid_o)
    );

    // Funcion para comprobar si dos numeros de 32 bits son iguales
    // Cuenta con tolerancia de error debido a los cambios por redondeo
    function automatic void verify_output (
        input logic [31:0] actual_value, 
        input logic [31:0] expected_value, 
        input logic [31:0] tolerance = 32'h00000001
    );
        int value_int;
        int expected_int;
        int low_expected;
        int high_expected;

        begin
            test_count++;
            // Caso exacto
            if (actual_value === expected_value) begin
                pass_count++;
                $display("TC-%0d   PASS at time: %0t", test_count, $time);
            end 
            else begin
                // Comparación con tolerancia
                value_int     = $signed(actual_value);
                expected_int  = $signed(expected_value);
                low_expected  = expected_int - $signed(tolerance);
                high_expected = expected_int + $signed(tolerance);

                if ((value_int >= low_expected) && (value_int <= high_expected)) begin
                    pass_count++;
                    $display("TC-%0d   PASS at time: %0t", test_count, $time);
                end 
                else begin
                    error_count++;
                    $display("TC-%0d   FAIL at time: %0t", test_count, $time);
                end
            end
        end
    endfunction

    // Funcion para comprobar si dos bits son iguales, se usara para la salida de las comparaciones
    function automatic void verify_cmp (
        input logic actual,
        input logic expected
    );
        begin
            test_count++;
            if (actual == expected) begin
                pass_count++;
                $display("TC-%0d   PASS at time: %0t", test_count, $time);

            end else begin
                error_count++;
                $display(" TC-%0d  FAIL at time: %0t", test_count, $time);

            end
        end
    endfunction

    ////////////////////////////////
    // TASKS DE CASOS DE PRUEBA
    ////////////////////////////////

    task test_fadd(input logic [31:0] a, b, expected_val, logic [2:0] r, string label);
        begin
            op_code_i = 3'd0; // FADD
            fp_a_i = a;
            fp_b_i = b;
            fp_c_i = 32'd0;
            r_mode_i = r;

            #10;
            $display("----------------------------------------------");
            $display("-> SUMA (FADD) | %s", label);
            $display("----------------------------------------------");
            $display("   A         = %h", a);
            $display("   B         = %h", b);

            case (r)
                3'b000:  $display("   RMode      = Round To Nearest (RNE)");                   // RNE
                3'b001:  $display("   RMode      = Round Toward Zero (RTZ)");                  // RTZ
                3'b010:  $display("   RMode      = Round Down (toward -∞) (RDN)");             // RDN
                3'b011:  $display("   RMode      = Round Up (toward +∞) (RUP)");               // RUP
                3'b100:  $display("   RMode      = Round To Nearest, ties to Max Magn (RMM)"); // RMM
                default: $display("   RMode      = Unknown/RTZ (Default Behavior)");           // Default
            endcase

            $display("----------------------------------------------");
            $display("   Resultado = %h", fp_result_o);
            $display("   Esperado  = %h", expected_val);
            $display("----------------------------------------------");
            $display("   overflow  = %b, underflow = %b, invalid = %b", overflow_o, underflow_o, invalid_o);
            $display("----------------------------------------------");
            verify_output(fp_result_o, expected_val);
            $display("  ");
            $display("  ");
    
        end
    endtask

    task test_fsub(input logic [31:0] a, b, expected_val, logic [2:0] r ,string label);
        begin
            op_code_i = 3'd1; // FSUB
            fp_a_i = a;
            fp_b_i = b;
            fp_c_i = 32'd0;
            r_mode_i = r;

            #10;
            $display("----------------------------------------------");
            $display("-> RESTA (FSUB) | %s", label);
            $display("----------------------------------------------");
            $display("   A         = %h", a);
            $display("   B         = %h", b);
            case (r)
                3'b000:  $display("   RMode      = Round To Nearest (RNE)");                   // RNE
                3'b001:  $display("   RMode      = Round Toward Zero (RTZ)");                  // RTZ
                3'b010:  $display("   RMode      = Round Down (toward -∞) (RDN)");             // RDN
                3'b011:  $display("   RMode      = Round Up (toward +∞) (RUP)");               // RUP
                3'b100:  $display("   RMode      = Round To Nearest, ties to Max Magn (RMM)"); // RMM
                default: $display("   RMode      = Unknown/RTZ (Default Behavior)");           // Default
            endcase
            $display("----------------------------------------------");
            $display("   Resultado = %h", fp_result_o);
            $display("   Esperado  = %h", expected_val);
            $display("----------------------------------------------");
            $display("   overflow  = %b, underflow = %b, invalid = %b", overflow_o, underflow_o, invalid_o);
            $display("----------------------------------------------");
            verify_output(fp_result_o, expected_val);
            $display("  ");
            $display("  ");

        end
    endtask

    task test_fmul(input logic [31:0] a, b, expected_val, logic [2:0] r, string label);
        begin
            op_code_i = 3'd2; // FMUL
            fp_a_i = a;
            fp_b_i = b;
            fp_c_i = 32'd0;
            r_mode_i = r;

            #10;
            $display("----------------------------------------------");
            $display("-> MULTIPLICACIÓN (FMUL) | %s", label);
            $display("----------------------------------------------");
            $display("   A         = %h", a);
            $display("   B         = %h", b);
            case (r)
                3'b000:  $display("   RMode     = Round To Nearest (RNE)");                   // RNE
                3'b001:  $display("   RMode     = Round Toward Zero (RTZ)");                  // RTZ
                3'b010:  $display("   RMode     = Round Down (toward -∞) (RDN)");             // RDN
                3'b011:  $display("   RMode     = Round Up (toward +∞) (RUP)");               // RUP
                3'b100:  $display("   RMode     = Round To Nearest, ties to Max Magn (RMM)"); // RMM
                default: $display("   RMode     = Unknown/RTZ (Default Behavior)");           // Default
            endcase
            $display("----------------------------------------------");
            $display("   Resultado = %h", fp_result_o);
            $display("   Esperado  = %h", expected_val);
            $display("----------------------------------------------");
            $display("   overflow  = %b, underflow = %b, invalid = %b", overflow_o, underflow_o, invalid_o);
            $display("----------------------------------------------");
            verify_output(fp_result_o, expected_val);
            $display("  ");
            $display("  ");

        end
    endtask

    task test_fmadd(input logic [31:0] a, b, c, expected_val, logic [2:0] r, string label);
        begin
            op_code_i = 3'd3; // FMADD
            fp_a_i = a;
            fp_b_i = b;
            fp_c_i = c;
            r_mode_i = r;

            #10;
            $display("----------------------------------------------");
            $display("-> FMA POSITIVO (FMADD) | %s", label);
            $display("----------------------------------------------");
            $display("   A         = %h", a);
            $display("   B         = %h", b);
            $display("   C         = %h", c);
            case (r)
                3'b000:  $display("   RMode     = Round To Nearest (RNE)");                  // RNE
                3'b001:  $display("   RMode     = Round Toward Zero (RTZ)");                  // RTZ
                3'b010:  $display("   RMode     = Round Down (toward -∞) (RDN)");             // RDN
                3'b011:  $display("   RMode     = Round Up (toward +∞) (RUP)");               // RUP
                3'b100:  $display("   RMode     = Round To Nearest, ties to Max Magn (RMM)"); // RMM
                default: $display("   RMode     = Unknown/RTZ (Default Behavior)");           // Default
            endcase
            $display("----------------------------------------------");
            $display("   Resultado = %h", fp_result_o);
            $display("   Esperado  = %h", expected_val);
            $display("----------------------------------------------");
            $display("   overflow  = %b, underflow = %b, invalid = %b", overflow_o, underflow_o, invalid_o);
            $display("----------------------------------------------");
            verify_output(fp_result_o, expected_val);
            $display("  ");
            $display("  ");
 
        end
    endtask

    task test_fmsub(input logic [31:0] a, b, c, expected_val, logic [2:0] r, string label);
        begin
            op_code_i = 3'd4; // FMSUB
            fp_a_i = a;
            fp_b_i = b;
            fp_c_i = c;
            r_mode_i = r;

            #10;
            $display("----------------------------------------------");
            $display("-> FMA NEGATIVO (FMSUB) | %s", label);
            $display("----------------------------------------------");
            $display("   A         = %h", a);
            $display("   B         = %h", b);
            $display("   C         = %h", c);
            case (r)
                3'b000:  $display("   RMode     = Round To Nearest (RNE)");                   // RNE
                3'b001:  $display("   RMode     = Round Toward Zero (RTZ)");                  // RTZ
                3'b010:  $display("   RMode     = Round Down (toward -∞) (RDN)");             // RDN
                3'b011:  $display("   RMode     = Round Up (toward +∞) (RUP)");               // RUP
                3'b100:  $display("   RMode     = Round To Nearest, ties to Max Magn (RMM)"); // RMM
                default: $display("   RMode     = Unknown/RTZ (Default Behavior)");           // Default
            endcase
            $display("----------------------------------------------");
            $display("   Resultado = %h", fp_result_o);
            $display("   Esperado  = %h", expected_val);
            $display("----------------------------------------------");
            $display("   overflow  = %b, underflow = %b, invalid = %b", overflow_o, underflow_o, invalid_o);
            $display("----------------------------------------------");
            verify_output(fp_result_o, expected_val);
            $display("  ");
            $display("  ");

        end
    endtask

    task test_feq(input logic [31:0] a, b, string label , logic expected_cmp);
        begin
            op_code_i = 3'd5; // FEQ
            fp_a_i = a;
            fp_b_i = b;
            r_mode_i = 3'd0;
            #10;
            $display("----------------------------------------------");
            $display("-> COMPARACIÓN (FEQ) | %s", label);
            $display("----------------------------------------------");
            $display("   A         = %h", a);
            $display("   B         = %h", b);
            
            if (cmp_result_o) begin
                $display("   A == B ?  = %b (T)", cmp_result_o);
            end else begin
                $display("   A == B ?  = %b (F)", cmp_result_o);
            end

            $display("   invalid   = %b\n", invalid_o);
            $display("----------------------------------------------");
            verify_cmp(cmp_result_o, expected_cmp);
            $display("  ");
            $display("  ");
        end
    endtask

    task test_flt(input logic [31:0] a, b, string label, logic expected_cmp);
        begin
            op_code_i = 3'd6; // FLT
            fp_a_i = a;
            fp_b_i = b;
            r_mode_i = 3'd0;
            #10;
            $display("----------------------------------------------");
            $display("-> COMPARACIÓN (FLT) | %s", label);
            $display("----------------------------------------------");
            $display("   A         = %h", a);
            $display("   B         = %h", b);
            if (cmp_result_o) begin
                $display("   A < B ?   = %b (T)", cmp_result_o);
            end else begin
                $display("   A < B ?   = %b (F)", cmp_result_o);
            end
            
            $display("   invalid   = %b\n", invalid_o);
            $display("----------------------------------------------");
            verify_cmp(cmp_result_o, expected_cmp);
            $display("  ");
            $display("  ");
        end
    endtask

    task test_fle(input logic [31:0] a, b, string label, logic expected_cmp);
        begin
            op_code_i = 3'd7; // FLE
            fp_a_i = a;
            fp_b_i = b;
            r_mode_i = 3'd0;
            #10;
            $display("----------------------------------------------");
            $display("-> COMPARACIÓN (FLE) | %s", label);
            $display("----------------------------------------------");
            $display("   A         = %h", a);
            $display("   B         = %h", b);
            if (cmp_result_o) begin
                $display("   A <= B ?  = %b (T)", cmp_result_o);
            end else begin
                $display("   A <= B ?  = %b (F)", cmp_result_o);
            end

            $display("   invalid   = %b\n", invalid_o);
            $display("----------------------------------------------");
            verify_cmp(cmp_result_o, expected_cmp);
            $display("  ");
            $display("  ");
        end
    endtask



    ////////////////////////////////
    // Arreglos de numeros para pruebas 
    ////////////////////////////////
    typedef struct {
        logic [31:0] a;
        logic [31:0] b;
        string       label;
        logic        expected_cmp;
    } a_b_case_t;

    typedef struct {
        logic [31:0] a;
        logic [31:0] b;
        logic [31:0] expected;
        logic [2 :0] round;
        string       label;
    } a_b_e_case_t;

    typedef struct {
        logic [31:0] a;
        logic [31:0] b;
        logic [31:0] c;
        logic [31:0] expected;
        logic [2 :0] round;
        string       label;
    } a_b_c_e_case_t;

    // Test cases para el sumador
    a_b_e_case_t fadd_case[70] = '{
    // Normales
    '{32'h3f800000, 32'h40000000, 32'h40400000, RNE, "#0 -> (1.0) + (2.0) = 3.0"                                      },
    '{32'h40a00000, 32'h41200000, 32'h41700000, RTZ, "#1 -> (5.0) + (10.0) = 15.0"                                    },
    '{32'h3f000000, 32'h3f800000, 32'h3fc00000, RDN, "#2 -> (0.5) + (1.0) = 1.5"                                      },
    '{32'h42c80000, 32'h42c80000, 32'h43480000, RUP, "#3 -> (100.0) + (100.0) = 200.0"                                },
    '{32'hc2480000, 32'h42c80000, 32'h42480000, RMM, "#4 -> (-50.0) + (100.0) = 50.0"                                 },
    '{32'h3eaaaaab, 32'h3eaaaaab, 32'h3f2aaaab, RNE, "#5 -> (0.33333) + (0.33333) = 0.66667"                          },
    '{32'h3fc00000, 32'h3fc00000, 32'h40400000, RTZ, "#6 -> (1.5) + (1.5) = 3.0"                                      },
    '{32'h41200000, 32'hc1200000, 32'h00000000, RDN, "#7 -> (10.0) + (-10.0) = 0.0"                                   },
    '{32'h3e000000, 32'h3dcccccd, 32'h3e666666, RUP, "#8 -> (0.125) + (0.1) = 0.225"                                  },
    '{32'h47c35000, 32'h47c35000, 32'h48435000, RMM, "#9 -> (100000.0) + (100000.0) = 200000.0"                       },
    // Subnormales          
    '{32'h00000001, 32'h00000001, 32'h00000002, RNE, "#10 -> (subnormal min) + (subnormal min) = 0x00000002"          },
    '{32'h00000010, 32'h00000020, 32'h00000030, RTZ, "#11 -> (subnormal pequeño) + (subnormal pequeño) = 0x00000030"  },
    '{32'h000fffff, 32'h000fffff, 32'h001ffffe, RDN, "#12 -> (subnormal max) + (subnormal max) = 0x001ffffe"          },
    '{32'h00000001, 32'h00800000, 32'h00800001, RTZ, "#13 -> (subnormal min) + (limite subnormal-normal) = 0x00800001"},
    '{32'h000abcd0, 32'h00012345, 32'h000be015, RMM, "#14 -> (subnormal) + (subnormal) = 0x000be015"                  },
    '{32'h00000200, 32'h80000200, 32'h00000000, RNE, "#15 -> (subnormal positivo) + (subnormal negativo) = 0.0"       },
    '{32'h00000001, 32'h000fffff, 32'h00100000, RTZ, "#16 -> (subnormal min) + (subnormal max) = 0x00100000"          },
    '{32'h00080000, 32'h00040000, 32'h000c0000, RDN, "#17 -> (subnormal) + (subnormal) = 0x000c0000"                  },
    '{32'h00000002, 32'h00000004, 32'h00000006, RUP, "#18 -> (subnormal min) + (subnormal min) = 0x00000006"          },
    '{32'h80000a00, 32'h00000200, 32'h80000800, RMM, "#19 -> (subnormal negativo) + (subnormal positivo) = 0x80000800"},
    // Infinitos
    '{32'h7f800000, 32'h3f800000, 32'h7f800000, RNE, "#20 -> (+Inf) + (1.0) = +Inf"                           },
    '{32'h7f800000, 32'hff800000, 32'h7fc00000, RTZ, "#21 -> (+Inf) + (-Inf) = NaN"                           },
    '{32'h7f800000, 32'h7f800000, 32'h7f800000, RDN, "#22 -> (+Inf) + (+Inf) = +Inf"                          },
    '{32'hff800000, 32'hff800000, 32'hff800000, RUP, "#23 -> (-Inf) + (-Inf) = -Inf"                          },
    '{32'hff800000, 32'h3f800000, 32'hff800000, RMM, "#24 -> (-Inf) + (1.0) = -Inf"                           },
    '{32'hff800000, 32'hbf800000, 32'hff800000, RNE, "#25 -> (-Inf) + (-1.0) = -Inf"                          },
    '{32'h7f800000, 32'h00000000, 32'h7f800000, RTZ, "#26 -> (+Inf) + (0.0) = +Inf"                           },
    '{32'hff800000, 32'h00000000, 32'hff800000, RDN, "#27 -> (-Inf) + (0.0) = -Inf"                           },
    '{32'h7f800000, 32'h7f7fffff, 32'h7f800000, RUP, "#28 -> (+Inf) + (máximo número normal) = +Inf"          },
    '{32'hff800000, 32'hff7fffff, 32'hff800000, RMM, "#29 -> (-Inf) + (máximo número normal negativo) = -Inf" },
    // Not a number
    '{32'h7fc00000, 32'h40000000, 32'h7fc00000, RNE, "#30 -> (NaN) + (2.0) = NaN"                             },
    '{32'h7fc00000, 32'h7fc00000, 32'h7fc00000, RTZ, "#31 -> (NaN) + (NaN) = NaN"                             },
    '{32'h7fc00000, 32'h7f800000, 32'h7fc00000, RDN, "#32 -> (NaN) + (+Inf) = NaN"                            },
    '{32'h7fc00000, 32'hff800000, 32'h7fc00000, RUP, "#33 -> (NaN) + (-Inf) = NaN"                            },
    '{32'h7fc00000, 32'h00000000, 32'h7fc00000, RMM, "#34 -> (NaN) + (0.0) = NaN"                             },
    '{32'h7fc00000, 32'h80000000, 32'h7fc00000, RNE, "#35 -> (NaN) + (-0.0) = NaN"                            },
    '{32'h7fc00000, 32'h40400000, 32'h7fc00000, RTZ, "#36 -> (NaN) + (3.0) = NaN"                             },
    '{32'h7fc00000, 32'hc1200000, 32'h7fc00000, RDN, "#37 -> (NaN) + (-10.0) = NaN"                           },
    '{32'h7f800000, 32'hff800000, 32'h7fc00000, RUP, "#38 -> (+Inf) + (-Inf) = NaN"                           },
    '{32'h7fc00000, 32'h00000001, 32'h7fc00000, RMM, "#39 -> (NaN) + (subnormal mínimo) = NaN"                },
    // Ceros                
    '{32'h00000000, 32'h40000000, 32'h40000000, RNE, "#40 -> (0.0) + (2.0) = 2.0"                             },
    '{32'h80000000, 32'h3f800000, 32'h3f800000, RTZ, "#41 -> (-0.0) + (1.0) = 1.0"                            },
    '{32'h80000000, 32'h80000000, 32'h00000000, RDN, "#42 -> (-0.0) + (-0.0) = 0.0"                           },
    '{32'h00000000, 32'hc0000000, 32'hc0000000, RUP, "#43 -> (0.0) + (-2.0) = -2.0"                           },
    '{32'h80000000, 32'h00000000, 32'h00000000, RMM, "#44 -> (-0.0) + (0.0) = 0.0"                            },
    '{32'h00000000, 32'h00000000, 32'h00000000, RNE, "#45 -> (0.0) + (0.0) = 0.0"                             },
    '{32'h80000000, 32'hbf800000, 32'hbf800000, RTZ, "#46 -> (-0.0) + (-1.0) = -1.0"                          },
    '{32'h80000000, 32'h7f800000, 32'h7f800000, RDN, "#47 -> (-0.0) + (+Inf) = +Inf"                          },
    '{32'h00000000, 32'h7fc00000, 32'h7fc00000, RUP, "#48 -> (0.0) + (NaN) = NaN"                             },
    '{32'h80000000, 32'hff800000, 32'hff800000, RMM, "#49 -> (-0.0) + (-Inf) = -Inf"                          },
    // Normales y subnormales juntos                 
    '{32'h00000001, 32'h3f800000, 32'h3f800000, RNE, "#50 -> (subnormal min) + (1.0) = 1.0"                                },
    '{32'h00012345, 32'h40000000, 32'h40000000, RTZ, "#51 -> (subnormal pequeño) + (2.0) = 2.0"                            },
    '{32'h007fffff, 32'h3f000000, 32'h3f000000, RDN, "#52 -> (subnormal max) + (0.5) = 0.5"                                },
    '{32'h000abcd0, 32'hbf400000, 32'hbf400000, RUP, "#53 -> (subnormal grande) + (-0.75) = -0.75"                         },
    '{32'h00000010, 32'hbfc00000, 32'hbfc00000, RMM, "#54 -> (subnormal min) + (-1.5) = -1.5"                              },
    '{32'h00000001, 32'h7f7fffff, 32'h7f7fffff, RNE, "#55 -> (subnormal min) + (max normal) = max normal"                  },
    '{32'h000fffff, 32'hff7fffff, 32'hff7fffff, RTZ, "#56 -> (subnormal max) + (max normal negativo) = max normal negativo"},
    '{32'h80000200, 32'h40400000, 32'h40400000, RDN, "#57 -> (subnormal negativo) + (3.0) = 3.0"                           },
    '{32'h800abcd0, 32'hc0000000, 32'hc0000000, RUP, "#58 -> (subnormal negativo) + (-2.0) = -2.0"                         },
    '{32'h00800000, 32'h3e800000, 32'h3e800000, RMM, "#59 -> (limite subnormal-normal) + (0.25) = 0.25"                    },
    // Overflow
    '{32'h7f000000, 32'h7f000000, 32'h7f800000, RNE, "#60 -> (2^127) + (2^127) = +Inf (Overflow expected)"                 },
    '{32'h7f800000, 32'h7e800000, 32'h7f800000, RTZ, "#61 -> (+Inf) + (2^120) = +Inf (Already Inf)"                        },
    '{32'h7f7fffff, 32'h7f7fffff, 32'h7f800000, RDN, "#62 -> (max normal) + (max normal) = +Inf (Overflow expected)"       },
    '{32'h7e000000, 32'h7e000000, 32'h7e800000, RUP, "#63 -> (2^126) + (2^126) = 2^127 (No Overflow)"                      },
    '{32'h7f7fffff, 32'hff7fffff, 32'h00000000, RMM, "#64 -> (max normal) + (-max normal) = 0.0 (Cancellation)"            },
    '{32'h7f600000, 32'h7f700000, 32'h7f800000, RTZ, "#65 -> (~2.98e38) + (~3.19e38) = +Inf (Overflow expected)"           },
    // Underflow
    '{32'h00000001, 32'h00000001, 32'h00000002, RDN, "#66 -> (subnormal min) + (subnormal min) = subnormal (Underflow expected)"     },
    '{32'h000fffff, 32'h00000001, 32'h00100000, RUP, "#67 -> (subnormal grande) + (subnormal chico) = subnormal (Underflow expected)"},
    '{32'h000fffff, 32'h800fffff, 32'h00000000, RMM, "#68 -> (subnormal max) + (-subnormal max) = 0.0 (Underflow by cancellation)"   },
    '{32'h00800001, 32'h80800001, 32'h00000000, RNE, "#69 -> (tiny normal) + (-tiny normal) = 0.0 (Underflow)"                       }
    };


    // Test cases para el restador
    a_b_e_case_t fsub_case[40] = '{
    // Normales
    '{32'h40400000, 32'h3f800000, 32'h40000000, RNE, "#0  -> 3.0     - 1.0     = 2.0"        },  
    '{32'h41280000, 32'h40900000, 32'h40c00000, RTZ, "#1  -> 10.5    - 4.5     = 6.0"        },  
    '{32'h3f400000, 32'h3f000000, 32'h3e800000, RDN, "#2  -> 0.75    - 0.5     = 0.25"       },  
    '{32'h42c80000, 32'h42480000, 32'h42480000, RUP, "#3  -> 100.0   - 50.0    = 50.0"       },  
    '{32'hc1a00000, 32'hc1200000, 32'hc1200000, RMM, "#4  -> -20.0   - (-10.0) = -10.0"      },  
    '{32'h3fc00000, 32'h3fc00000, 32'h00000000, RNE, "#5  -> 1.5     - 1.5     = 0.0"        },  
    '{32'h41200000, 32'h41700000, 32'hc0a00000, RTZ, "#6  -> 10.0    - 15.0    = -5.0"       },  
    '{32'h3dcccccd, 32'h41a06666, 32'hc19f999a, RDN, "#7  -> 0.1     - 20.05   = -19.95"     },  
    '{32'h47c35000, 32'h47c35000, 32'h00000000, RUP, "#8  -> 100000  - 100000  = 0.0"        },  
    '{32'hc0600000, 32'h40200000, 32'hc0c00000, RMM, "#9  -> -3.5    - 2.5     = -6.0"       },
    // Casos Subnormales  
    '{32'h00000001, 32'h00000000, 32'h00000001, RNE, "#10 -> 1.4e-45 - 0        = 1.4e-45"  },  
    '{32'h00000004, 32'h00000002, 32'h00000002, RTZ, "#11 -> 5.6e-45 - 2.8e-45  = 2.8e-45"   },  
    '{32'h00000008, 32'h00000006, 32'h00000002, RDN, "#12 -> 1.12e-44 - 8.4e-45 = 2.8e-45"   },  
    '{32'h80000004, 32'h00000002, 32'h80000006, RUP, "#13 -> -5.6e-45 - 2.8e-45 = -8.4e-45"  },  
    '{32'h00000008, 32'h80000004, 32'h0000000c, RMM, "#14 -> 1.12e-44 - (-5.6e-45)=1.68e-44" },  
    '{32'h80000001, 32'h80000001, 32'h00000000, RNE, "#15 -> -1.4e-45 - (-1.4e-45) = 0.0"    },  
    '{32'h00000002, 32'h0000008f, 32'h8000008d, RTZ, "#16 -> 2.8e-45 - 20e-44    = -1.98e-43"},  
    '{32'h80000008, 32'h00000004, 32'h8000000c, RDN, "#17 -> -1.12e-44 - 5.6e-45 = -1.68e-44"},  
    '{32'h00000000, 32'h00000001, 32'h80000001, RUP, "#18 -> 7.0e-46 - 1.4e-45  = -7.0e-46"  },  
    '{32'h80000002, 32'h80000001, 32'h80000001, RMM, "#19 -> -2.8e-45 - (-1.4e-45)= -1.4e-45"},
    // Casos con Infinito 
    '{32'h7f800000, 32'h447a0000, 32'h7f800000, RNE, "#20 -> +Inf     - 1000.0     = +Inf"   },
    '{32'hff800000, 32'h43fa4000, 32'hff800000, RTZ, "#21 -> -Inf     - (-500.5)   = -Inf"   },
    '{32'h7f800000, 32'hff800000, 32'h7f800000, RDN, "#22 -> +Inf     - (-Inf)     = +Inf"   },
    '{32'hff800000, 32'h7f800000, 32'hff800000, RUP, "#23 -> -Inf     - (+Inf)     = -Inf"   },
    '{32'h7f800000, 32'h7f800000, 32'h7fc00000, RMM, "#24 -> +Inf     - (+Inf)     = NaN"    },
    '{32'hff800000, 32'hff800000, 32'h7fc00000, RNE, "#25 -> -Inf     - (-Inf)     = NaN"    },
    '{32'h7f800000, 32'h00000000, 32'h7f800000, RTZ, "#26 -> +Inf     - 0.0        = +Inf"   },
    '{32'hff800000, 32'h00000000, 32'hff800000, RDN, "#27 -> -Inf     - 0.0        = -Inf"   },
    '{32'h00000000, 32'h7f800000, 32'hff800000, RUP, "#28 -> 0.0       - (+Inf)     = -Inf"  },
    '{32'h00000000, 32'hff800000, 32'h7f800000, RMM, "#29 -> 0.0       - (-Inf)     = +Inf"  },
    // Casos con NaN 
    '{32'h7fc00000, 32'h40400000, 32'h7fc00000, RNE, "#30 -> NaN       - 3.0        = NaN"   },
    '{32'h40a00000, 32'h7fc00000, 32'h7fc00000, RTZ, "#31 -> 5.0        - NaN        = NaN"  },
    '{32'h7fc00000, 32'h7fc00000, 32'h7fc00000, RDN, "#32 -> NaN       - NaN        = NaN"   },
    '{32'h7fc00000, 32'hff800000, 32'h7fc00000, RUP, "#33 -> NaN       - (-Inf)     = NaN"   },
    '{32'h7f800000, 32'h7fc00000, 32'h7fc00000, RMM, "#34 -> +Inf      - NaN        = NaN"   },
    '{32'h7fc00000, 32'h00000000, 32'h7fc00000, RNE, "#35 -> NaN       - 0.0        = NaN"   },
    '{32'h80000000, 32'h7fc00000, 32'h7fc00000, RTZ, "#36 -> -0.0       - NaN        = NaN"  },
    '{32'h7fc00000, 32'h00000001, 32'h7fc00000, RDN, "#37 -> NaN       - subnormal  = NaN"   },
    '{32'h00000001, 32'h7fc00000, 32'h7fc00000, RUP, "#38 -> subnormal - NaN        = NaN"   },
    '{32'h7fc00000, 32'hffc00000, 32'h7fc00000, RMM, "#39 -> NaN       - (-NaN)     = NaN"   }
    };

    a_b_e_case_t fmul_case[30] = '{
    // Números Normales
    '{32'h3f800000, 32'h40000000, 32'h40000000, RNE, "#0  -> 1.0       * 2.0       = 2.0"        },
    '{32'h40400000, 32'h40800000, 32'h41400000, RTZ, "#1  -> 3.0       * 4.0       = 12.0"       },
    '{32'h3f000000, 32'h3f800000, 32'h3f000000, RDN, "#2  -> 0.5       * 1.0       = 0.5"        },
    '{32'h42c80000, 32'h3f800000, 32'h42c80000, RUP, "#3  -> 100.0     * 1.0       = 100.0"      },
    '{32'hc2480000, 32'h42c80000, 32'hc59c4000, RMM, "#4  -> -50.0     * 100.0     = -5000.0"    },
    '{32'h3eaaaa3b, 32'h3eaaaa3b, 32'h3de38d0f, RNE, "#5  -> 0.33333   * 0.33333   = ~0.1111"    },
    '{32'h3fc00000, 32'h3fc00000, 32'h40100000, RTZ, "#6  -> 1.5       * 1.5       = 2.25"       },
    '{32'h41200000, 32'hc1200000, 32'hc2c80000, RDN, "#7  -> 10.0      * -10.0     = -100.0"     },
    '{32'h3e000000, 32'h3dcccccd, 32'h3c4ccccd, RUP, "#8  -> 0.125     * 0.1       = 0.0125"     },
    '{32'h47c35000, 32'h3f800000, 32'h47c35000, RMM, "#9  -> 100000.0  * 1.0       = 100000.0"   },
    // Subnormales
    '{32'h00000001, 32'h3f800000, 32'h00000001, RNE, "#10 -> min_sub   * 1.0       = min_sub"    },
    '{32'h00000004, 32'h3f800000, 32'h00000004, RTZ, "#11 -> 6e-45     * 1.0       = 6e-45"      },
    '{32'h00000008, 32'h00000002, 32'h00000000, RDN, "#12 -> 1.1e-44   * 2.8e-45   = ~e-90..."   },
    '{32'h00000010, 32'h00000010, 32'h00000000, RUP, "#13 -> 2.2e-44   * 2.2e-44   = ~e-90..."   },
    '{32'h00000001, 32'h41200000, 32'h00000007, RUP, "#14 -> 1e-45     * 10.0      = 1e-44"      },
    '{32'h00000008, 32'h80000002, 32'h80000000, RNE, "#15 -> sub       * -sub      = -tiny"      },
    '{32'h00000000, 32'h00000001, 32'h00000000, RTZ, "#16 -> 0.0       * min_sub   = 0.0"        },
    '{32'h80000002, 32'h80000002, 32'h00000000, RDN, "#17 -> -sub      * -sub      = tiny+"      },
    '{32'h80000008, 32'h00000008, 32'h80000000, RUP, "#18 -> -sub      * +sub      = tiny-"      },
    '{32'h00000001, 32'h00000001, 32'h00000000, RMM, "#19 -> min_sub   * min_sub   = zero"       },
    // Infinitos 
    '{32'h7f800000, 32'h3f800000, 32'h7f800000, RNE, "#20 -> +Inf      * 1.0       = +Inf"       },
    '{32'hff800000, 32'h3f800000, 32'hff800000, RTZ, "#21 -> -Inf      * 1.0       = -Inf"       },
    '{32'h7f800000, 32'hff800000, 32'hff800000, RDN, "#22 -> +Inf      * -Inf      = -Inf"       },
    '{32'h7f800000, 32'h00000000, 32'h7fc00000, RUP, "#23 -> +Inf      * 0.0       = NaN"        },
    '{32'hff800000, 32'h00000000, 32'h7fc00000, RMM, "#24 -> -Inf      * 0.0       = NaN"        },
    // NaNs y Combinaciones 
    '{32'h7fc00000, 32'hff800000, 32'h7fc00000, RNE, "#25 -> NaN       * -Inf      = NaN"        },
    '{32'h7fc00000, 32'h7fc00000, 32'h7fc00000, RTZ, "#26 -> NaN       * NaN       = NaN"        },
    '{32'h7f800000, 32'h7f800000, 32'h7f800000, RDN, "#27 -> +Inf      * +Inf      = +Inf"       },
    '{32'hff800000, 32'hff800000, 32'h7f800000, RUP, "#28 -> -Inf      * -Inf      = +Inf"       },
    '{32'hff800000, 32'h7f800000, 32'hff800000, RMM, "#29 -> -Inf      * +Inf      = -Inf"       }

    };


    // Test cases para fmadd
    a_b_c_e_case_t fmadd_case[30] = '{
    // Números Normales 
    '{32'h3f800000, 32'h40000000, 32'h3f000000, 32'h40200000, RNE, "#0  -> (1.0 * 2.0) + 0.5    = 2.5"           },
    '{32'h3f000000, 32'h3f000000, 32'h3f800000, 32'h3fa00000, RTZ, "#1  -> (0.5 * 0.5) + 1.0    = 1.25"          },
    '{32'hc0000000, 32'h40000000, 32'h3f800000, 32'hc0400000, RDN, "#2  -> (-2.0 * 2.0) + 1.0   = -3.0"          },
    '{32'h3fc00000, 32'h40400000, 32'h3f800000, 32'h40b00000, RUP, "#3  -> (1.5 * 3.0) + 1.0    = 5.5"           },
    '{32'h3f800000, 32'hbf800000, 32'h3f800000, 32'h00000000, RMM, "#4  -> (1.0 * -1.0) + 1.0   = 0.0"           },
    '{32'h40400000, 32'h40400000, 32'h40400000, 32'h41400000, RNE, "#5  -> (3.0 * 3.0) + 3.0    = 12.0"          },
    '{32'hc1200000, 32'h41200000, 32'h00000000, 32'hc2c80000, RTZ, "#6  -> (-10.0 * 10.0) + 0.0 = -100.0"        },
    '{32'h3f800000, 32'h3f800000, 32'h3f800000, 32'h40000000, RDN, "#7  -> (1.0 * 1.0) + 1.0    = 2.0"           },
    '{32'h3f000000, 32'h3f000000, 32'h3f000000, 32'h3f400000, RUP, "#8  -> (0.5 * 0.5) + 0.5    = 0.75"          },
    '{32'h00000000, 32'h40400000, 32'h3f800000, 32'h3f800000, RMM, "#9  -> (0.0 * 3.0) + 1.0    = 1.0"           },
    // Subnormales 
    '{32'h00000001, 32'h3f800000, 32'h00000001, 32'h00000002, RNE, "#10 -> (min_sub * 1.0) + min_sub = 2*min_sub"},
    '{32'h00000002, 32'h00000002, 32'h00000001, 32'h00000002, RTZ, "#11 -> (2*sub * 2*sub) + sub     = ~sub"     },
    '{32'h00000004, 32'h3f800000, 32'h00000000, 32'h00000004, RDN, "#12 -> (sub * 1.0) + 0.0         = sub"      },
    '{32'h00000008, 32'h00000008, 32'h00000001, 32'h00000001, RUP, "#13 -> (1.1e-44 * 1.1e-44) + 1e-45 = 1e-45"  },
    '{32'h00000000, 32'h00000001, 32'h00000001, 32'h00000001, RMM, "#14 -> (0.0 * sub) + sub        = sub"       },
    '{32'h00000002, 32'h00000002, 32'h00000002, 32'h00000003, RNE, "#15 -> (sub * sub) + sub        = ~2sub"     },
    '{32'h00000008, 32'h00000004, 32'h00000002, 32'h00000002, RTZ, "#16 -> (1.1e-44 * 6e-45)+ 3e-45 = 3e-45"     },
    '{32'h80000001, 32'h3f800000, 32'h00000001, 32'h00000000, RDN, "#17 -> (-sub * 1.0) + sub       = 0.0"       },
    '{32'h00000001, 32'h00000001, 32'h80000001, 32'h80000000, RUP, "#18 -> (sub * sub) + (-sub)     = ~0.0"      },
    '{32'h80000002, 32'h80000002, 32'h80000001, 32'h80000002, RMM, "#19 -> (-sub * -sub) + (-sub)   = -tiny"     },
    // Infinitos
    '{32'h7f800000, 32'h3f800000, 32'h00000000, 32'h7f800000, RNE, "#20 -> (+Inf * 1.0) + 0.0       = +Inf"      },
    '{32'hff800000, 32'h3f800000, 32'h00000000, 32'hff800000, RTZ, "#21 -> (-Inf * 1.0) + 0.0       = -Inf"      },
    '{32'h7f800000, 32'h3f800000, 32'h7f800000, 32'h7f800000, RDN, "#22 -> (+Inf * 1.0) + +Inf      = +Inf"      },
    '{32'h7f800000, 32'h3f800000, 32'hff800000, 32'h7fc00000, RUP, "#23 -> (+Inf * 1.0) + -Inf      = NaN"       },
    '{32'h00000000, 32'h7f800000, 32'h7f800000, 32'h7fc00000, RMM, "#24 -> (0.0 * +Inf) + +Inf      = NaN"       },
    // NaN  
    '{32'h7fc00000, 32'h3f800000, 32'h3f800000, 32'h7fc00000, RNE, "#25 -> (NaN * 1.0) + 1.0         = NaN"      },
    '{32'h3f800000, 32'h7fc00000, 32'h3f800000, 32'h7fc00000, RTZ, "#26 -> (1.0 * NaN) + 1.0         = NaN"      },
    '{32'h3f800000, 32'h3f800000, 32'h7fc00000, 32'h7fc00000, RDN, "#27 -> (1.0 * 1.0) + NaN         = NaN"      },
    '{32'h7fc00000, 32'h7fc00000, 32'h7fc00000, 32'h7fc00000, RUP, "#28 -> (NaN * NaN) + NaN         = NaN"      },
    '{32'hff800000, 32'h00000000, 32'h7fc00000, 32'h7fc00000, RMM, "#29 -> (-Inf * 0.0) + NaN        = NaN"      }
    };


    // Test cases para el fmsub
    a_b_c_e_case_t fmsub_case[30] = '{
    // Números Normales 
    '{32'h3f800000, 32'h40000000, 32'h3f000000, 32'h3fc00000, RNE, "#0  -> (1.0 * 2.0) - 0.5    = 1.5"       },
    '{32'h3f000000, 32'h3f000000, 32'h3f800000, 32'hbf400000, RTZ, "#1  -> (0.5 * 0.5) - 1.0    = -0.75"     },
    '{32'hc0000000, 32'h40000000, 32'h3f800000, 32'hc0a00000, RDN, "#2  -> (-2.0 * 2.0) - 1.0   = -5.0"      },
    '{32'h3fc00000, 32'h40400000, 32'h3f800000, 32'h40600000, RUP, "#3  -> (1.5 * 3.0) - 1.0    = 3.5"       },
    '{32'h3f800000, 32'hbf800000, 32'h3f800000, 32'hc0000000, RMM, "#4  -> (1.0 * -1.0) - 1.0   = -2.0"      },
    '{32'h40400000, 32'h40400000, 32'h40000000, 32'h40e00000, RNE, "#5  -> (3.0 * 3.0) - 2.0    = 7.0"       },
    '{32'hc1200000, 32'h41200000, 32'h41200000, 32'hc2dc0000, RTZ, "#6  -> (-10 * 10) - 10      = -110.0"    },
    '{32'h3f800000, 32'h3f800000, 32'h3f000000, 32'h3f000000, RDN, "#7  -> (1.0 * 1.0) - 0.5    = 0.5"       },
    '{32'h3f000000, 32'h3f800000, 32'h3e800000, 32'h3e800000, RUP, "#8  -> (0.5 * 1.0) - 0.25   = 0.25"      },
    '{32'h40400000, 32'h00000000, 32'h3f800000, 32'hbf800000, RMM, "#9  -> (3.0 * 0.0) - 1.0    = -1.0"      },
    // Subnormales 
    '{32'h00000001, 32'h3f800000, 32'h00000001, 32'h00000000, RNE, "#10 -> (sub * 1.0) - sub    = 0"         },
    '{32'h00000002, 32'h00000002, 32'h00000001, 32'h80000001, RTZ, "#11 -> (sub * sub) - sub        = -sub"  },
    '{32'h00000004, 32'h40000000, 32'h00000001, 32'h00000007, RDN, "#12 -> (5.6e-45 *2.0)- (1e-45)= 1.02e-44"},
    '{32'h00000008, 32'h00000008, 32'h00000008, 32'h80000008, RUP, "#13 -> (big_sub * big_sub)-sub  =  -sub "},
    '{32'h00000000, 32'h00000001, 32'h00000001, 32'h80000001, RMM, "#14 -> (0.0 * sub) - sub        = -sub"  },
    '{32'h00000002, 32'h00000002, 32'h00000002, 32'h80000002, RNE, "#15 -> (sub * sub) - 3e-45      = -3e-45"},
    '{32'h00000008, 32'h00000004, 32'h00000002, 32'h80000002, RTZ, "#16 -> (sub * sub) - 3e-45      = -3e-45"},
    '{32'h80000001, 32'h3f800000, 32'h00000001, 32'h80000002, RDN, "#17 -> (-sub * 1.0) - sub       = -2sub" },
    '{32'h00000001, 32'h00000001, 32'h80000001, 32'h00000002, RUP, "#18 -> (sub * sub) - (-sub)     = 2sub"  },
    '{32'h80000002, 32'h80000002, 32'h80000001, 32'h00000001, RMM, "#19 -> (-sub * -sub) - (-sub)   = +tiny" },
    // Infinitos 
    '{32'h7f800000, 32'h3f800000, 32'h00000000, 32'h7f800000, RNE, "#20 -> (+Inf * 1.0) - 0.0       = +Inf"  },
    '{32'hff800000, 32'h3f800000, 32'h00000000, 32'hff800000, RTZ, "#21 -> (-Inf * 1.0) - 0.0       = -Inf"  },
    '{32'h7f800000, 32'h3f800000, 32'hff800000, 32'h7f800000, RDN, "#22 -> (+Inf * 1.0) - (-Inf)    = +inf"  },
    '{32'h7f800000, 32'h3f800000, 32'h7f800000, 32'h7fc00000, RUP, "#23 -> (+Inf * 1.0) - (+Inf)    = NaN"   },
    '{32'h00000000, 32'h7f800000, 32'hff800000, 32'h7fc00000, RMM, "#24 -> (0.0 * +Inf) - (-Inf)    = NaN"   },
    // 
    '{32'h7fc00000, 32'h3f800000, 32'h3f800000, 32'h7fc00000, RNE, "#25 -> (NaN * 1.0) - 1.0         = NaN"  },
    '{32'h3f800000, 32'h7fc00000, 32'h3f800000, 32'h7fc00000, RTZ, "#26 -> (1.0 * NaN) - 1.0         = NaN"  },
    '{32'h3f800000, 32'h3f800000, 32'h7fc00000, 32'h7fc00000, RDN, "#27 -> (1.0 * 1.0) - NaN         = NaN"  },
    '{32'h7fc00000, 32'h7fc00000, 32'h7fc00000, 32'h7fc00000, RUP, "#28 -> (NaN * NaN) - NaN         = NaN"  },
    '{32'hff800000, 32'h00000000, 32'h7fc00000, 32'h7fc00000, RMM, "#29 -> (-Inf * 0.0) - NaN        = NaN"  }
    };


    // Test cases para comparar igualdad
    a_b_case_t feq_case[26] = '{
    // Números normales
    '{32'h3f800000, 32'h3f800000, "#0  -> 1.0 == 1.0", 1           },
    '{32'h3f800000, 32'h40000000, "#1  -> 1.0 == 2.0", 0           },
    '{32'hc2480000, 32'hc2480000, "#2  -> -50.0 == -50.0", 1       },
    // Ceros con signo        
    '{32'h00000000, 32'h80000000, "#3  -> +0.0 == -0.0", 1         },
    // Subnormales     
    '{32'h00000001, 32'h00000001, "#4  -> submin == submin", 1     },
    '{32'h00000010, 32'h00000020, "#5  -> subsmall != subsmall+", 0},
    // Infinitos 
    '{32'h7f800000, 32'h7f800000, "#6  -> +Inf == +Inf", 1         },
    '{32'hff800000, 32'hff800000, "#7  -> -Inf == -Inf", 1         },
    '{32'h7f800000, 32'hff800000, "#8  -> +Inf != -Inf", 0         },
    // NaN         
    '{32'h7fc00000, 32'h7fc00000, "#9  -> NaN == NaN", 0           },
    '{32'h7fc00000, 32'h3f800000, "#10 -> NaN == 1.0", 0           },
    // Casos generales
    '{32'h3eaaaaab, 32'h3eaaaaab, "#11 -> 0.33333 == 0.33333", 1   },
    '{32'h3fc00000, 32'h3f800000, "#12 -> 1.5 != 1.0", 0           },
    '{32'h41200000, 32'hc1200000, "#13 -> 10.0 != -10.0", 0        },
    '{32'h47c35000, 32'h47c35000, "#14 -> 100000.0 == 100000.0", 1 },
    '{32'h00000002, 32'h00000004, "#15 -> submin+1 != submin+2", 0 },
    //No iguales
    '{32'h3f800000, 32'h40000000, "#16 -> 1.0 != 2.0", 0           },
    '{32'hc2480000, 32'h42480000, "#17 -> -50.0 != 50.0", 0        },
    '{32'h7f800000, 32'hff800000, "#18 -> +Inf != -Inf", 0         },
    '{32'h3f800001, 32'h3f800000, "#19 -> 1.0000001 != 1.0", 0     },
    '{32'h3fc00000, 32'h3f800000, "#20 -> 1.5 != 1.0", 0           },
    // Sí son iguales 
    '{32'h00000000, 32'h80000000, "#21 -> +0.0 == -0.0", 1         },
    '{32'h3f800000, 32'h3f800000, "#22 -> 1.0 == 1.0", 1           },
    '{32'hc1200000, 32'hc1200000, "#23 -> -10.0 == -10.0", 1       },
    '{32'h7f800000, 32'h7f800000, "#24 -> +Inf == +Inf", 1         },
    '{32'hff800000, 32'hff800000, "#25 -> -Inf == -Inf", 1         }
    };


    // Test cases para comparar menor que 
    a_b_case_t flt_case[26] = '{
    // Números normales
    '{32'h3f000000, 32'h3f800000, "#0  -> 0.5 < 1.0", 1        },
    '{32'h3f800000, 32'h40000000, "#1  -> 1.0 < 2.0", 1        },
    '{32'h40000000, 32'h3f800000, "#2  -> 2.0 < 1.0", 0        },
    '{32'hc0000000, 32'h00000000, "#3  -> -2.0 < 0.0", 1       },
    '{32'h40400000, 32'h40400000, "#4  -> 3.0 < 3.0", 0        },
    // Ceros con signo      
    '{32'h00000000, 32'h80000000, "#5  -> +0.0 < -0.0", 0      },
    '{32'h80000000, 32'h00000000, "#6  -> -0.0 < +0.0", 0      },
    // Subnormales  
    '{32'h00000001, 32'h00000002, "#7  -> sub1 < sub2", 1      },
    '{32'h00000002, 32'h00000001, "#8  -> sub2 < sub1", 0      },
    '{32'h00000001, 32'h3f800000, "#9  -> sub1 < 1.0", 1       },
    // Infinitos  
    '{32'h7f800000, 32'hff800000, "#10 -> +Inf < -Inf", 0      },
    '{32'hff800000, 32'h7f800000, "#11 -> -Inf < +Inf", 0      },
    '{32'h7f800000, 32'h7f800000, "#12 -> +Inf < +Inf", 0      },
    '{32'hff800000, 32'hff800000, "#13 -> -Inf < -Inf", 0      },
    // NaNs      
    '{32'h7fc00000, 32'h3f800000, "#14 -> NaN < 1.0", 0        },
    '{32'h3f800000, 32'h7fc00000, "#15 -> 1.0 < NaN", 0        },
    '{32'h7fc00000, 32'h7fc00000, "#16 -> NaN < NaN", 0        },
    // Valores negativos     
    '{32'hc1200000, 32'h41200000, "#17 -> -10.0 < 10.0", 1     },
    '{32'h41200000, 32'hc1200000, "#18 -> 10.0 < -10.0", 0     },
    // Muy cercanos 
    '{32'h3f800000, 32'h3f800001, "#19 -> 1.0 < 1.0000001", 1  },
    '{32'h3f800000, 32'h3f800011, "#20 -> 1.0 < 1.0000003", 1  },
    '{32'h3f800001, 32'h3f800000, "#21 -> 1.0000001 < 1.0", 0  },
    '{32'h3f7fffff, 32'h3f800000, "#22 -> 0.9999999 < 1.0", 1  },
    '{32'h3f800000, 32'h3f7fffff, "#23 -> 1.0 < 0.9999999", 0  },
    '{32'h3f000000, 32'h3f000001, "#24 -> 0.5 < 0.5000001", 1  },
    '{32'h3f000001, 32'h3f000000, "#25 -> 0.5000001 < 0.5", 0  }
    };


    // Test cases para comparar igualdad o menor que 
    a_b_case_t fle_case[26] = '{
    // Números normales
    '{32'h3f000000, 32'h3f800000, "#0  -> 0.5 <= 1.0", 1        },
    '{32'h3f800000, 32'h3f800000, "#1  -> 1.0 <= 1.0", 1        },
    '{32'h40000000, 32'h3f800000, "#2  -> 2.0 <= 1.0", 0        },
    '{32'hc0000000, 32'h00000000, "#3  -> -2.0 <= 0.0", 1       },
    '{32'h40400000, 32'h40400000, "#4  -> 3.0 <= 3.0", 1        },
    // Ceros con signo     
    '{32'h00000000, 32'h80000000, "#5  -> +0.0 <= -0.0", 1      },
    '{32'h80000000, 32'h00000000, "#6  -> -0.0 <= +0.0", 1      },
    // Subnormales     
    '{32'h00000001, 32'h00000002, "#7  -> sub1 <= sub2", 1      },
    '{32'h00000002, 32'h00000001, "#8  -> sub2 <= sub1", 0      },
    '{32'h00000001, 32'h3f800000, "#9  -> sub1 <= 1.0", 1       },
    // Infinitos      
    '{32'h7f800000, 32'hff800000, "#10 -> +Inf <= -Inf", 0      },
    '{32'hff800000, 32'h7f800000, "#11 -> -Inf <= +Inf", 0      },
    '{32'h7f800000, 32'h7f800000, "#12 -> +Inf <= +Inf", 1      },
    '{32'hff800000, 32'hff800000, "#13 -> -Inf <= -Inf", 1      },
    // NaNs      
    '{32'h7fc00000, 32'h3f800000, "#14 -> NaN <= 1.0", 0        },
    '{32'h3f800000, 32'h7fc00000, "#15 -> 1.0 <= NaN", 0        },
    '{32'h7fc00000, 32'h7fc00000, "#16 -> NaN <= NaN", 0        },
    // Valores negativos      
    '{32'hc1200000, 32'h41200000, "#17 -> -10.0 <= 10.0", 1     },
    '{32'h41200000, 32'hc1200000, "#18 -> 10.0 <= -10.0", 0     },
    // Muy cercanos
    '{32'h3f800000, 32'h3f800001, "#19 -> 1.0 <= 1.0000001", 1  },
    '{32'h3f800000, 32'h3f800002, "#20 -> 1.0 <= 1.0000002", 1  },
    '{32'h3f800001, 32'h3f800000, "#21 -> 1.0000001 <= 1.0", 0  },
    '{32'h3f7fffff, 32'h3f800000, "#22 -> 0.9999999 <= 1.0", 1  },
    '{32'h3f800000, 32'h3f7fffff, "#23 -> 1.0 <= 0.9999999", 0  },
    '{32'h3f000000, 32'h3f000001, "#24 -> 0.5 <= 0.5000001", 1  },
    '{32'h3f000001, 32'h3f000000, "#25 -> 0.5000001 <= 0.5", 0  }
    };


    ////////////////////////////////
    // SECUENCIA DE PRUEBAS
    ////////////////////////////////

    initial begin
        $display("\n========== INICIO DE SIMULACIÓN ==========\n");

        // Test cases para el sumador
        for (int i = 0; i < $size(fadd_case); i++) begin
            test_fadd(
            fadd_case[i].a,
            fadd_case[i].b,
            fadd_case[i].expected,
            fadd_case[i].round,
            fadd_case[i].label
            );
        end 

        // Test cases para el restador
        for (int i = 0; i < $size(fsub_case); i++) begin
            test_fsub(
                fsub_case[i].a,
                fsub_case[i].b,
                fsub_case[i].expected,
                fsub_case[i].round,
                fsub_case[i].label
            );
        end

        // Test cases para el multiplicador
         for (int i = 0; i < $size(fmul_case); i++) begin
            test_fmul(
                fmul_case[i].a,
                fmul_case[i].b,
                fmul_case[i].expected,
                fmul_case[i].round,
                fmul_case[i].label
            );
        end

        // Test cases para fmadd
        for (int i = 0; i < $size(fmadd_case); i++) begin
            test_fmadd(
                fmadd_case[i].a,
                fmadd_case[i].b,
                fmadd_case[i].c,
                fmadd_case[i].expected,
                fmadd_case[i].round,
                fmadd_case[i].label
            );
        end        

        // Test cases para el fmsub
        for (int i = 0; i < $size(fmsub_case); i++) begin
            test_fmsub(
                fmsub_case[i].a,
                fmsub_case[i].b,
                fmsub_case[i].c,
                fmsub_case[i].expected,
                fmsub_case[i].round,
                fmsub_case[i].label
            );
        end       
 
        // Test cases para comparar igualdad
        for (int i = 0; i < $size(feq_case); i++) begin
            test_feq(
                feq_case[i].a,
                feq_case[i].b,
                feq_case[i].label,
                feq_case[i].expected_cmp
            );
        end

        // Test cases para comparar menor que 
        for (int i = 0; i < $size(flt_case); i++) begin
            test_flt(
                flt_case[i].a,
                flt_case[i].b,
                flt_case[i].label,
                flt_case[i].expected_cmp
            );
        end
 
        // Test cases para comparar igualdad o menor que
        for (int i = 0; i < $size(fle_case); i++) begin
            test_fle(
                fle_case[i].a,
                fle_case[i].b,
                fle_case[i].label,
                fle_case[i].expected_cmp
            );
        end 
  
        pass_rate = 100.0 * pass_count / test_count;
        $display("========================================");
        $display("||  ");
        $display("||          TOTAL TESTS : %0d", test_count );
        $display("||          TOTAL PASS  : %0d", pass_count );
        $display("||          TOTAL FAIL  : %0d", error_count);
        $display("||          PRECISION   : %.2f%%", pass_rate);
        $display("||  ");
        $display("========================================");
        $display("========== FIN DE SIMULACIÓN ===========");
        $display("========================================");
        $display("  ");
        $finish;

    end

endmodule
