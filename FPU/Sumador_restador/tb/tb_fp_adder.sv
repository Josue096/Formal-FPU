
module tb_fp_adder;

    logic [31:0] fp_a;
    logic [31:0] fp_b;
    logic [31:0] fp_result;
    logic [2:0]  r_mode = 3'b001; // RTZ
    logic        overflow;
    logic underflow;

    fp_adder dut (
        .fp_a(fp_a),
        .fp_b(fp_b),
        .r_mode(r_mode),
        .fp_result(fp_result),
        .overflow(overflow),
        .underflow(underflow)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fp_adder);


        $display("Modo de redondeo: RTZ (Round Toward Zero)");
        // -------------------------  Números Normales -------------------------
        fp_a = 32'h3f800000; fp_b = 32'h40000000; #10; 
        $display("Caso 0 => (1.0) + (2.0):                              Result = %h, Expected = 40400000", fp_result);

        fp_a = 32'h40a00000; fp_b = 32'h41200000; #10;
        $display("Caso 1 => (5.0) + (10.0):                             Result = %h, Expected = 41700000", fp_result);

        fp_a = 32'h3f000000; fp_b = 32'h3f800000; #10;
        $display("Caso 2 => (0.5) + (1.0):                              Result = %h, Expected = 3fc00000", fp_result);

        fp_a = 32'h42c80000; fp_b = 32'h42c80000; #10;
        $display("Caso 3 => (100.0) + (100.0):                          Result = %h, Expected = 43480000", fp_result);

        fp_a = 32'hc2480000; fp_b = 32'h42c80000; #10;
        $display("Caso 4 => (-50.0) + (100.0):                          Result = %h, Expected = 42480000", fp_result);

        fp_a = 32'h3eaaaaab; fp_b = 32'h3eaaaaab; #10;
        $display("Caso 5 => (0.33333) + (0.33333):                      Result = %h, Expected = 3f2aaaab", fp_result);

        fp_a = 32'h3fc00000; fp_b = 32'h3fc00000; #10;
        $display("Caso 6 => (1.5) + (1.5):                              Result = %h, Expected = 40400000", fp_result);

        fp_a = 32'h41200000; fp_b = 32'hc1200000; #10;
        $display("Caso 7 => (10.0) + (-10.0):                           Result = %h, Expected = 00000000", fp_result);

        fp_a = 32'h3e000000; fp_b = 32'h3dcccccd; #10;
        $display("Caso 8 => (0.125) + (0.1):                            Result = %h, Expected = 3e666666", fp_result);

        fp_a = 32'h47c35000; fp_b = 32'h47c35000; #10;
        $display("Caso 9 => (100000.0) + (100000.0):                    Result = %h, Expected = 48435000", fp_result);

        // -------------------------  Números Subnormales -------------------------

        // Caso 10: Subnormal más pequeño + Subnormal más pequeño
        fp_a = 32'h00000001; fp_b = 32'h00000001; #10;
        $display("Caso 10 => (subnormal min) + (subnormal min):           Result = %h, Expected = 00000002", fp_result);

        // Caso 11: Subnormales pequeños
        fp_a = 32'h00000010; fp_b = 32'h00000020; #10; 
        $display("Caso 11 => (subnormal pequeño) + (subnormal pequeño):   Result = %h, Expected = 00000030", fp_result);

        // Caso 12: Subnormal más grande + Subnormal más grande
        fp_a = 32'h000fffff; fp_b = 32'h000fffff; #10;
        $display("Caso 12 => (subnormal max) + (subnormal max):           Result = %h, Expected = 001ffffe", fp_result);

        // Caso 13: Subnormal mínimo + Límite subnormal-normal
        fp_a = 32'h00000001; fp_b = 32'h00800000; #10;
        $display("Caso 13 => (subnormal min) + (limite subnormal-normal): Result = %h, Expected = 00800001", fp_result);

        // Caso 14: Dos subnormales grandes con diferente magnitud
        fp_a = 32'h000abcd0; fp_b = 32'h00012345; #10;
        $display("Caso 14 => (subnormal) + (subnormal):                   Result = %h, Expected = 000be015", fp_result);

        // Caso 15: Subnormal positivo + Subnormal negativo (casi iguales)
        fp_a = 32'h00000200; fp_b = 32'h80000200; #10;
        $display("Caso 15 => (subnormal positivo) + (subnormal negativo): Result = %h, Expected = 00000000", fp_result);

        // Caso 16: Subnormal muy pequeño + Subnormal muy grande
        fp_a = 32'h00000001; fp_b = 32'h000fffff; #10;
        $display("Caso 16 => (subnormal min) + (subnormal max):           Result = %h, Expected = 00100000", fp_result);

        // Caso 17: Subnormal con mayor bit de mantisa + Otro subnormal
        fp_a = 32'h00080000; fp_b = 32'h00040000; #10;
        $display("Caso 17 => (subnormal) + (subnormal):                   Result = %h, Expected = 000c0000", fp_result);

        // Caso 18: Suma de dos subnormales muy pequeños que no cambian el exponente
        fp_a = 32'h00000002; fp_b = 32'h00000004; #10;
        $display("Caso 18 => (subnormal min) + (subnormal min):           Result = %h, Expected = 00000006", fp_result);

        // Caso 19: Subnormal negativo + Subnormal positivo (no iguales)
        fp_a = 32'h80000a00; fp_b = 32'h00000200; #10;
        $display("Caso 19 => (subnormal negativo) + (subnormal positivo): Result = %h, Expected = 80000800", fp_result);


        // -------------------------  Infinitos (10 casos) -------------------------

        // Caso 20: +Inf + 1.0
        fp_a = 32'h7f800000; fp_b = 32'h3f800000; #10;
        $display("Caso 20 => (+Inf) + (1.0):            Result = %h, Expected = 7f800000", fp_result);

        // Caso 21: +Inf + -Inf (debe dar NaN)
        fp_a = 32'h7f800000; fp_b = 32'hff800000; #10;
        $display("Caso 21 => (+Inf) + (-Inf):           Result = %h, Expected = 7fc00000", fp_result);

        // Caso 22: +Inf + +Inf (debe seguir siendo +Inf)
        fp_a = 32'h7f800000; fp_b = 32'h7f800000; #10;
        $display("Caso 22 => (+Inf) + (+Inf):           Result = %h, Expected = 7f800000", fp_result);

        // Caso 23: -Inf + -Inf (debe seguir siendo -Inf)
        fp_a = 32'hff800000; fp_b = 32'hff800000; #10;
        $display("Caso 23 => (-Inf) + (-Inf):           Result = %h, Expected = ff800000", fp_result);

        // Caso 24: -Inf + 1.0 (debe seguir siendo -Inf)
        fp_a = 32'hff800000; fp_b = 32'h3f800000; #10;
        $display("Caso 24 => (-Inf) + (1.0):            Result = %h, Expected = ff800000", fp_result);

        // Caso 25: -Inf + -1.0 (debe seguir siendo -Inf)
        fp_a = 32'hff800000; fp_b = 32'hbf800000; #10;
        $display("Caso 25 => (-Inf) + (-1.0):           Result = %h, Expected = ff800000", fp_result);

        // Caso 26: +Inf + 0.0 (debe seguir siendo +Inf)
        fp_a = 32'h7f800000; fp_b = 32'h00000000; #10;
        $display("Caso 26 => (+Inf) + (0.0):            Result = %h, Expected = 7f800000", fp_result);

        // Caso 27: -Inf + 0.0 (debe seguir siendo -Inf)
        fp_a = 32'hff800000; fp_b = 32'h00000000; #10;
        $display("Caso 27 => (-Inf) + (0.0):            Result = %h, Expected = ff800000", fp_result);

        // Caso 28: +Inf + número normal grande (debe seguir siendo +Inf)
        fp_a = 32'h7f800000; fp_b = 32'h7f7fffff; #10;
        $display("Caso 28 => (+Inf) + (máximo número normal): Result = %h, Expected = 7f800000", fp_result);

        // Caso 29: -Inf + número normal grande negativo (debe seguir siendo -Inf)
        fp_a = 32'hff800000; fp_b = 32'hff7fffff; #10;
        $display("Caso 29 => (-Inf) + (máximo número normal negativo): Result = %h, Expected = ff800000", fp_result);


        // -------------------------  NaN (10 casos) -------------------------

        // Caso 30: NaN + 2.0 (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'h40000000; #10;
        $display("Caso 30 => (NaN) + (2.0):             Result = %h, Expected = 7fc00000", fp_result);

        // Caso 31: NaN + NaN (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'h7fc00000; #10;
        $display("Caso 31 => (NaN) + (NaN):             Result = %h, Expected = 7fc00000", fp_result);

        // Caso 32: NaN + +Inf (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'h7f800000; #10;
        $display("Caso 32 => (NaN) + (+Inf):            Result = %h, Expected = 7fc00000", fp_result);

        // Caso 33: NaN + -Inf (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'hff800000; #10;
        $display("Caso 33 => (NaN) + (-Inf):            Result = %h, Expected = 7fc00000", fp_result);

        // Caso 34: NaN + 0.0 (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'h00000000; #10;
        $display("Caso 34 => (NaN) + (0.0):             Result = %h, Expected = 7fc00000", fp_result);

        // Caso 35: NaN + -0.0 (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'h80000000; #10;
        $display("Caso 35 => (NaN) + (-0.0):            Result = %h, Expected = 7fc00000", fp_result);

        // Caso 36: NaN + número normal (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'h40400000; #10;
        $display("Caso 36 => (NaN) + (3.0):             Result = %h, Expected = 7fc00000", fp_result);

        // Caso 37: NaN + número negativo (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'hc1200000; #10;
        $display("Caso 37 => (NaN) + (-10.0):           Result = %h, Expected = 7fc00000", fp_result);

        // Caso 38: NaN generado por Inf - Inf (debe seguir siendo NaN)
        fp_a = 32'h7f800000; fp_b = 32'hff800000; #10;
        $display("Caso 38 => (+Inf) + (-Inf):           Result = %h, Expected = 7fc00000", fp_result);

        // Caso 39: NaN + subnormal (debe seguir siendo NaN)
        fp_a = 32'h7fc00000; fp_b = 32'h00000001; #10;
        $display("Caso 39 => (NaN) + (subnormal mínimo): Result = %h, Expected = 7fc00000", fp_result);


        // -------------------------  Ceros (10 casos) -------------------------

        // Caso 40: 0.0 + 2.0 (debe dar 2.0)
        fp_a = 32'h00000000; fp_b = 32'h40000000; #10;
        $display("Caso 40 => (0.0) + (2.0):             Result = %h, Expected = 40000000", fp_result);

        // Caso 41: -0.0 + 1.0 (debe dar 1.0)
        fp_a = 32'h80000000; fp_b = 32'h3f800000; #10;
        $display("Caso 41 => (-0.0) + (1.0):            Result = %h, Expected = 3f800000", fp_result);

        // Caso 42: -0.0 + -0.0 (debe seguir siendo 0.0)
        fp_a = 32'h80000000; fp_b = 32'h80000000; #10;
        $display("Caso 42 => (-0.0) + (-0.0):           Result = %h, Expected = 80000000", fp_result);

        // Caso 43: 0.0 + -2.0 (debe dar -2.0)
        fp_a = 32'h00000000; fp_b = 32'hc0000000; #10;
        $display("Caso 43 => (0.0) + (-2.0):            Result = %h, Expected = c0000000", fp_result);

        // Caso 44: -0.0 + 0.0 (debe seguir siendo 0.0)
        fp_a = 32'h80000000; fp_b = 32'h00000000; #10;
        $display("Caso 44 => (-0.0) + (0.0):            Result = %h, Expected = 00000000", fp_result);

        // Caso 45: 0.0 + 0.0 (debe seguir siendo 0.0)
        fp_a = 32'h00000000; fp_b = 32'h00000000; #10;
        $display("Caso 45 => (0.0) + (0.0):             Result = %h, Expected = 00000000", fp_result);

        // Caso 46: -0.0 + -1.0 (debe dar -1.0)
        fp_a = 32'h80000000; fp_b = 32'hbf800000; #10;
        $display("Caso 46 => (-0.0) + (-1.0):           Result = %h, Expected = bf800000", fp_result);

        // Caso 47: -0.0 + Inf (debe seguir siendo Inf)
        fp_a = 32'h80000000; fp_b = 32'h7f800000; #10;
        $display("Caso 47 => (-0.0) + (+Inf):           Result = %h, Expected = 7f800000", fp_result);

        // Caso 48: 0.0 + NaN (debe seguir siendo NaN)
        fp_a = 32'h00000000; fp_b = 32'h7fc00000; #10;
        $display("Caso 48 => (0.0) + (NaN):             Result = %h, Expected = 7fc00000", fp_result);

        // Caso 49: -0.0 + -Inf (debe seguir siendo -Inf)
        fp_a = 32'h80000000; fp_b = 32'hff800000; #10;
        $display("Caso 49 => (-0.0) + (-Inf):           Result = %h, Expected = ff800000", fp_result);


        // -------------------------  Números Normales (Casos 50 - 64) -------------------------

        // Caso 50: 0.75 + 0.25 = 1.0
        fp_a = 32'h3f400000; fp_b = 32'h3e800000; #10;
        $display("Caso 50 => (0.75) + (0.25):           Result = %h, Expected = 3f800000", fp_result);

        // Caso 51: -3.5 + 2.5 = -1.0
        fp_a = 32'hc0600000; fp_b = 32'h40200000; #10;
        $display("Caso 51 => (-3.5) + (2.5):            Result = %h, Expected = bf800000", fp_result);

        // Caso 52: 1.999 + 0.001 = 2.0 (Verificación de precisión)
        fp_a = 32'h3fffdf3b; fp_b = 32'h3a83126f; #10;
        $display("Caso 52 => (1.999) + (0.001):         Result = %h, Expected = 40000000", fp_result);

        // Caso 53: 25.75 + 0.25 = 26.0
        fp_a = 32'h41ce0000; fp_b = 32'h3e800000; #10;
        $display("Caso 53 => (25.75) + (0.25):          Result = %h, Expected = 41d00000", fp_result);

        // Caso 54: -128.5 + 128.5 = 0.0
        fp_a = 32'hc0804000; fp_b = 32'h40804000; #10;
        $display("Caso 54 => (-128.5) + (128.5):        Result = %h, Expected = 00000000", fp_result);

        // Caso 55: 1.4e-45 (mínimo normalizado) + 1.0 = 1.0
        fp_a = 32'h00800000; fp_b = 32'h3f800000; #10;
        $display("Caso 55 => (min normalizado) + (1.0): Result = %h, Expected = 3f800000", fp_result);

        // Caso 56: 524288.0 + 0.5 = 524288.5
        fp_a = 32'h49000000; fp_b = 32'h3f000000; #10;
        $display("Caso 56 => (524288.0) + (0.5):        Result = %h, Expected = 49000008", fp_result);

        // Caso 57: -1024.0 + -512.0 = -1536.0
        fp_a = 32'hc4800000; fp_b = 32'hc4000000; #10;
        $display("Caso 57 => (-1024.0) + (-512.0):      Result = %h, Expected = c4c00000", fp_result);

        // Caso 58: 8388607.0 + 1.0 = 8388608.0 (Overflow en mantisa)
        fp_a = 32'h4b7fffff; fp_b = 32'h3f800000; #10;
        $display("Caso 58 => (8388607.0) + (1.0):       Result = %h, Expected = 4b800000", fp_result);

        // Caso 59: 0.15625 + 0.09375 = 0.25
        fp_a = 32'h3e200000; fp_b = 32'h3dc00000; #10;
        $display("Caso 59 => (0.15625) + (0.09375):     Result = %h, Expected = 3e800000", fp_result);

        // Caso 60: 1.5e-38 (número muy pequeño normalizado) + 1.0 = 1.0
        fp_a = 32'h00800000; fp_b = 32'h3f800000; #10;
        $display("Caso 60 => (1.5e-38) + (1.0):         Result = %h, Expected = 3f800000", fp_result);

        // Caso 61: 2.25 + 2.25 = 4.5
        fp_a = 32'h40100000; fp_b = 32'h40100000; #10;
        $display("Caso 61 => (2.25) + (2.25):           Result = %h, Expected = 40900000", fp_result);

        // Caso 62: -16.75 + 8.375 = -8.375
        fp_a = 32'hc1860000; fp_b = 32'h41060000; #10;
        $display("Caso 62 => (-16.75) + (8.375):        Result = %h, Expected = c1060000", fp_result);

        // Caso 63: 0.015625 + 0.015625 = 0.03125
        fp_a = 32'h3c800000; fp_b = 32'h3c800000; #10;
        $display("Caso 63 => (0.015625) + (0.015625): Result = %h, Expected = 3d000000", fp_result);

        // Caso 64: 1.75 + -3.5 = -1.75
        fp_a = 32'h3fe00000; fp_b = 32'hc0600000; #10;
        $display("Caso 64 => (1.75) + (-3.5):          Result = %h, Expected = bfe00000", fp_result);

        // -------------------------  Números Negativos (Casos 65 - 74) -------------------------

        // Caso 65: -2.0 + -0.5 = -2.5
        fp_a = 32'hc0000000; fp_b = 32'hbf000000; #10;
        $display("Caso 65 => (-2.0) + (-0.5):           Result = %h, Expected = c0200000", fp_result);

        // Caso 66: 0.1 + (-0.125) = -0.025
        fp_a = 32'h3dcccccd; fp_b = 32'hbe000000; #10;
        $display("Caso 66 => (0.1) + (-0.125):          Result = %h, Expected = bccccccd", fp_result);

        // Caso 67: -10.75 + -3.25 = -14.0
        fp_a = 32'hc12c0000; fp_b = 32'hc0500000; #10;
        $display("Caso 67 => (-10.75) + (-3.25):        Result = %h, Expected = c1600000", fp_result);

        // Caso 68: -0.0078125 + -0.0078125 = -0.015625
        fp_a = 32'hbb800000; fp_b = 32'hbb800000; #10;
        $display("Caso 68 => (-0.0078125) + (-0.0078125): Result = %h, Expected = bc000000", fp_result);

        // Caso 69: -50.0 + -75.0 = -125.0
        fp_a = 32'hc2480000; fp_b = 32'hc2960000; #10;
        $display("Caso 69 => (-50.0) + (-75.0):         Result = %h, Expected = c2fa0000", fp_result);

        // Caso 70: -0.0000152588 + -0.0000076294 = -0.0000228882
        fp_a = 32'hb7800006; fp_b = 32'hb7000006; #10;
        $display("Caso 70 => (-0.0000152588) + (-0.0000076294): Result = %h, Expected = b7c00009", fp_result);

        // Caso 71: -0.2 + -0.3 = -0.5
        fp_a = 32'hbe4ccccd; fp_b = 32'hbe99999a; #10;
        $display("Caso 71 => (-0.2) + (-0.3):           Result = %h, Expected = bf000000", fp_result);

        // Caso 72: -1024.25 + -512.125 = -1536.375
        fp_a = 32'hc4800800; fp_b = 32'hc4000800; #10;
        $display("Caso 72 => (-1024.25) + (-512.125):   Result = %h, Expected = c4c00c00", fp_result);

        // Caso 73: -0.0625 + -0.1875 = -0.25
        fp_a = 32'hbd800000; fp_b = 32'hbe400000; #10;
        $display("Caso 73 => (-0.0625) + (-0.1875):     Result = %h, Expected = be800000", fp_result);

        // Caso 74: -500000.0 + -1000000.0 = -1500000.0
        fp_a = 32'hc8f42400; fp_b = 32'hc9742400; #10;
        $display("Caso 74 => (-500000.0) + (-1000000.0): Result = %h, Expected = c9b71b00", fp_result);


        // -------------------------  Números Subnormales + Normales (Casos 74 - 84) -------------------------

        // Caso 74: Subnormal mínimo + 1.0
        fp_a = 32'h00000001; fp_b = 32'h3f800000; #10;
        $display("Caso 74 => (subnormal min) + (1.0):       Result = %h, Expected = 3f800000", fp_result);

        // Caso 75: Subnormal pequeño + 2.0
        fp_a = 32'h00012345; fp_b = 32'h40000000; #10;
        $display("Caso 75 => (subnormal pequeño) + (2.0):   Result = %h, Expected = 40000000", fp_result);

        // Caso 76: Subnormal máximo + 0.5
        fp_a = 32'h007fffff; fp_b = 32'h3f000000; #10;
        $display("Caso 76 => (subnormal max) + (0.5):       Result = %h, Expected = 3f000000", fp_result);

        // Caso 77: Subnormal grande + -0.75
        fp_a = 32'h000abcd0; fp_b = 32'hbf400000; #10;
        $display("Caso 77 => (subnormal grande) + (-0.75):  Result = %h, Expected = bf400000", fp_result);

        // Caso 78: Subnormal muy pequeño + -1.5
        fp_a = 32'h00000010; fp_b = 32'hbfc00000; #10;
        $display("Caso 78 => (subnormal min) + (-1.5):      Result = %h, Expected = bfc00000", fp_result);

        // Caso 79: Subnormal mínimo + máximo número normal
        fp_a = 32'h00000001; fp_b = 32'h7f7fffff; #10;
        $display("Caso 79 => (subnormal min) + (max normal): Result = %h, Expected = 7f7fffff", fp_result);

        // Caso 80: Subnormal grande + -máximo número normal negativo
        fp_a = 32'h000fffff; fp_b = 32'hff7fffff; #10;
        $display("Caso 80 => (subnormal max) + (max normal negativo): Result = %h, Expected = ff7fffff", fp_result);

        // Caso 81: Subnormal pequeño negativo + 3.0
        fp_a = 32'h80000200; fp_b = 32'h40400000; #10;
        $display("Caso 81 => (subnormal negativo) + (3.0):          Result = %h, Expected = 40400000", fp_result);

        // Caso 82: Subnormal negativo grande + -2.0
        fp_a = 32'h800abcd0; fp_b = 32'hc0000000; #10;
        $display("Caso 82 => (subnormal negativo) + (-2.0):         Result = %h, Expected = c0000000", fp_result);

        // Caso 83: Límite entre subnormal y normal + 0.25
        fp_a = 32'h00800000; fp_b = 32'h3e800000; #10;
        $display("Caso 83 => (limite subnormal-normal) + (0.25):    Result = %h, Expected = 3e800000", fp_result);

        // Caso 84: Número normal pequeño + subnormal pequeño
        fp_a = 32'h3e000000; fp_b = 32'h00000010; #10;
        $display("Caso 84 => (pequeño normal) + (subnormal pequeño): Result = %h, Expected = 3e000001", fp_result);

        // ------------------------- Casos de Overflow -------------------------


        // Caso 0: 2^127 + 2^127 → Overflow esperado
        fp_a = 32'h7f000000;  // 2^127
        fp_b = 32'h7f000000;  // 2^127
        #10;
        $display("Overflow Caso 0 => Result = %h, Overflow = %b (Expected = 7f800000, 1)", fp_result, overflow);

        // Caso 1: 2^128 + 2^120 → Overflow esperado
        fp_a = 32'h7f800000;  // Inf
        fp_b = 32'h7e800000;  // 2^120
        #10;
        $display("Overflow Caso 1 => Result = %h, Overflow = %b (Expected = 7f800000, 0 - ya es Inf)", fp_result, overflow);

        // Caso 2: Número muy grande + número casi igual (suma exacta)
        fp_a = 32'h7f7fffff;  // Máximo número normal positivo (~3.4e38)
        fp_b = 32'h7f7fffff;  // Idem
        #10;
        $display("Overflow Caso 2 => Result = %h, Overflow = %b (Expected = 7f800000, 1)", fp_result, overflow);

        // Caso 3 (nuevo): 2^126 + 2^126 = 2^127 → válido, no overflow
        fp_a = 32'h7e000000;  // 2^126
        fp_b = 32'h7e000000;  // 2^126
        #10;
        $display("Overflow Caso 3 => Result = %h, Overflow = %b (Expected = 7e800000, 0)", fp_result, overflow);


        // Caso 4: Suma entre número positivo y negativo de misma magnitud — no debe haber overflow
        fp_a = 32'h7f7fffff;      // Máximo número normal
        fp_b = 32'hff7fffff;      // Mismo valor pero negativo
        #10;
        $display("Overflow Caso 4 => Result = %h, Overflow = %b (Expected = 00000000, 0)", fp_result, overflow);

        // Caso 5: Valor grande positivo + número normal muy grande → Overflow esperado
        fp_a = 32'h7f600000;  // ~2.9774707e38
        fp_b = 32'h7f700000;  // ~3.1901472e38
        #10;
        $display("Overflow Caso 5 => Result = %h, Overflow = %b (Expected = 7f800000, 1)", fp_result, overflow);


        // ------------------------- PRUEBAS DE UNDERFLOW -------------------------
        
        // Caso und 0 Subnormal min + subnormal min → aún subnormal
        fp_a = 32'h00000001; fp_b = 32'h00000001; #10;
        $display("Underflow Caso 0 => Result = %h, Underflow = %b (Expected ≠ 0, 1)", fp_result, underflow);

        // Caso und 1: Subnormal grande + subnormal chico → subnormal
        fp_a = 32'h000fffff; fp_b = 32'h00000001; #10;
        $display("Underflow Caso 1 => Result = %h, Underflow = %b (Expected ≠ 0, 1)", fp_result, underflow);

        // Caso und 2: Subnormal máximo + (-subnormal máximo) → Cero (por cancelación)
        fp_a = 32'h000fffff; fp_b = 32'h800fffff; #10;
        $display("Underflow Caso 2 => Result = %h, Underflow = %b (Expected = 00000000, 1)", fp_result, underflow);

        // Caso und 3: Número muy pequeño + número negativo ≈ 0 (cancelación total)
        fp_a = 32'h00800001; fp_b = 32'h80800001; #10;
        $display("Underflow Caso 3 => Result = %h, Underflow = %b (Expected = 00000000, 1)", fp_result, underflow);

        // Caso und 4: Suma de normales que produce número menor a subnormal mínimo
        fp_a = 32'h00800000; fp_b = 32'h80000001; #10;
        $display("Underflow Caso 4 => Result = %h, Underflow = %b (Expected ≈ 0, 1)", fp_result, underflow);


        $finish;
    end
endmodule
