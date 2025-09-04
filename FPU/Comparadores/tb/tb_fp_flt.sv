

module tb_fp_flt;


    // Entradas y salida del comparador
    reg [31:0] fp_a;
    reg [31:0] fp_b;
    wire       lt;

    // Instancia del comparador "menor o igual"
    fp_flt dut (
        .fp_a(fp_a),
        .fp_b(fp_b),
        .lt (lt)
    );

    // Bloque de prueba
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fp_flt);

        // -------------------------  10 Casos donde A < B -------------------------
        fp_a = 32'h3f000000; fp_b = 32'h3f800000; #10;  // 0.5 < 1.0
        $display("Caso 1: 0.5 < 1.0 => lt = %b, Expected = 1", lt);

        fp_a = 32'hbf800000; fp_b = 32'h00000000; #10;  // -1.0 < 0.0
        $display("Caso 2: -1.0 < 0.0 => lt = %b, Expected = 1", lt);

        fp_a = 32'hc0000000; fp_b = 32'h3f800000; #10;  // -2.0 < 1.0
        $display("Caso 3: -2.0 < 1.0 => lt = %b, Expected = 1", lt);

        fp_a = 32'h3eaaaaab; fp_b = 32'h3f000000; #10;  // 0.3333 < 0.5
        $display("Caso 4: 0.3333 < 0.5 => lt = %b, Expected = 1", lt);

        fp_a = 32'hc2480000; fp_b = 32'h42480000; #10;  // -50.0 < 50.0
        $display("Caso 5: -50.0 < 50.0 => lt = %b, Expected = 1", lt);

        fp_a = 32'h00000001; fp_b = 32'h00000002; #10;  // Subnormal min < Subnormal min+1
        $display("Caso 6: Subnormal min < Subnormal min+1 => lt = %b, Expected = 1", lt);

        fp_a = 32'hc1c00000; fp_b = 32'h41c00000; #10;  // -24.0 < 24.0
        $display("Caso 7: -24.0 < 24.0 => lt = %b, Expected = 1", lt);

        fp_a = 32'h00000000; fp_b = 32'h3f800000; #10;  // 0.0 < 1.0
        $display("Caso 8: 0.0 < 1.0 => lt = %b, Expected = 1", lt);

        fp_a = 32'hc2480000; fp_b = 32'hc1000000; #10;  // -50.0 < -8.0
        $display("Caso 9: -50.0 < -8.0 => lt = %b, Expected = 1", lt);

        fp_a = 32'hbf800000; fp_b = 32'h3f000000; #10;  // -1.0 < 0.5
        $display("Caso 10: -1.0 < 0.5 => lt = %b, Expected = 1", lt);

        // -------------------------  10 Casos donde A > B -------------------------
        fp_a = 32'h3f800000; fp_b = 32'h3f000000; #10;  // 1.0 > 0.5
        $display("Caso 11: 1.0 > 0.5 => lt = %b, Expected = 0", lt);

        fp_a = 32'h00000000; fp_b = 32'hbf800000; #10;  // 0.0 > -1.0
        $display("Caso 12: 0.0 > -1.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'h3f800000; fp_b = 32'hc0000000; #10;  // 1.0 > -2.0
        $display("Caso 13: 1.0 > -2.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'h3f000000; fp_b = 32'h3eaaaaab; #10;  // 0.5 > 0.3333
        $display("Caso 14: 0.5 > 0.3333 => lt = %b, Expected = 0", lt);

        fp_a = 32'h42480000; fp_b = 32'hc2480000; #10;  // 50.0 > -50.0
        $display("Caso 15: 50.0 > -50.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'h00000002; fp_b = 32'h00000001; #10;  // Subnormal min+1 > Subnormal min
        $display("Caso 16: Subnormal min+1 > Subnormal min => lt = %b, Expected = 0", lt);

        fp_a = 32'h41c00000; fp_b = 32'hc1c00000; #10;  // 24.0 > -24.0
        $display("Caso 17: 24.0 > -24.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'h3f800000; fp_b = 32'h00000000; #10;  // 1.0 > 0.0
        $display("Caso 18: 1.0 > 0.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'hc1000000; fp_b = 32'hc2480000; #10;  // -8.0 > -50.0
        $display("Caso 19: -8.0 > -50.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'h3f000000; fp_b = 32'hbf800000; #10;  // 0.5 > -1.0
        $display("Caso 20: 0.5 > -1.0 => lt = %b, Expected = 0", lt);

        // -------------------------  10 Casos donde A == B -------------------------
        fp_a = 32'h3f800000; fp_b = 32'h3f800000; #10;  // 1.0 == 1.0
        $display("Caso 21: 1.0 == 1.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'hbf800000; fp_b = 32'hbf800000; #10;  // -1.0 == -1.0
        $display("Caso 22: -1.0 == -1.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'h00000000; fp_b = 32'h00000000; #10;  // 0.0 == 0.0
        $display("Caso 23: 0.0 == 0.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'h80000000; fp_b = 32'h00000000; #10;  // -0.0 == +0.0
        $display("Caso 24: -0.0 == +0.0 => lt = %b, Expected = 0", lt);

        fp_a = 32'h7f800000; fp_b = 32'h7f800000; #10;  // +Inf == +Inf
        $display("Caso 25: +Inf == +Inf => lt = %b, Expected = 0", lt);

        fp_a = 32'hff800000; fp_b = 32'hff800000; #10;  // -Inf == -Inf
        $display("Caso 26: -Inf == -Inf => lt = %b, Expected = 0", lt);



        // -------------------------  Casos Específicos -------------------------

        // Caso 1: NaN vs número normal (NaN siempre es falso)
        fp_a = 32'h7fc00000; fp_b = 32'h3f800000; #10;  // NaN ? 1.0
        $display("Caso 1: NaN <= 1.0 => lt = %b, Expected = 0", lt);

        // Caso 2: Número normal vs NaN (NaN siempre es falso)
        fp_a = 32'h3f800000; fp_b = 32'h7fc00000; #10;  // 1.0 ? NaN
        $display("Caso 2: 1.0 <= NaN => lt = %b, Expected = 0", lt);

        // Caso 3: Subnormal más pequeño contra subnormal más grande
        fp_a = 32'h00000001; fp_b = 32'h00080000; #10;  // subnormal min ? subnormal grande
        $display("Caso 3: Subnormal mínimo <= Subnormal grande => lt = %b, Expected = 1", lt);

        // Caso 4: Número normal más pequeño contra 0
        fp_a = 32'h00800000; fp_b = 32'h00000000; #10;  // 1.17549e-38 ? 0.0
        $display("Caso 4: Min normal <= 0.0 => lt = %b, Expected = 0", lt);

        // Caso 5: Número normal más grande contra +Inf
        fp_a = 32'h7f7fffff; fp_b = 32'h7f800000; #10;  // 3.40282e+38 ? +Inf
        $display("Caso 5: Máx normal <= +Inf => lt = %b, Expected = 1", lt);

        // Caso 6: -Inf contra el número normal más grande
        fp_a = 32'hff800000; fp_b = 32'h7f7fffff; #10;  // -Inf ? 3.40282e+38
        $display("Caso 6: -Inf <= Máx normal => lt = %b, Expected = 1", lt);

        // Caso 7: +Inf contra el número normal más pequeño
        fp_a = 32'h7f800000; fp_b = 32'h00800000; #10;  // +Inf ? 1.17549e-38
        $display("Caso 7: +Inf <= Min normal => lt = %b, Expected = 0", lt);

        // Caso 8: -0.0 contra un número negativo muy pequeño
        fp_a = 32'h80000000; fp_b = 32'h80800000; #10;  // -0.0 ? -1.17549e-38
        $display("Caso 8: -0.0 <= -Min normal => lt = %b, Expected = 0", lt);

        // Caso 9: Subnormal vs número normal
        fp_a = 32'h00080000; fp_b = 32'h3f000000; #10;  // subnormal ? 0.5
        $display("Caso 9: Subnormal grande <= 0.5 => lt = %b, Expected = 1", lt);

        // Caso 10: Número normal vs subnormal
        fp_a = 32'h3f000000; fp_b = 32'h00080000; #10;  // 0.5 ? subnormal
        $display("Caso 10: 0.5 <= Subnormal grande => lt = %b, Expected = 0", lt);




        $finish;
    end

endmodule 