

module tb_fp_feq;

    // Entradas y salida del comparador
    reg [31:0] fp_a;
    reg [31:0] fp_b;
    wire       eq;

    // Instancia del comparador de igualdad
    fp_feq dut (
        .fp_a(fp_a),
        .fp_b(fp_b),
        .eq(eq)
    );

    // Bloque de prueba
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fp_feq);

        // -------------------------  Números Normales -------------------------
        fp_a = 32'h3f800000; fp_b = 32'h3f800000; #10;
        $display("Caso 0 => (1.0) == (1.0): Eq = %b, Expected = 1", eq);

        fp_a = 32'h3f800000; fp_b = 32'h40000000; #10;
        $display("Caso 1 => (1.0) == (2.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'hc2480000; fp_b = 32'hc2480000; #10;
        $display("Caso 2 => (-50.0) == (-50.0): Eq = %b, Expected = 1", eq);

        // -------------------------  Ceros con signo -------------------------
        fp_a = 32'h00000000; fp_b = 32'h80000000; #10;
        $display("Caso 3 => (+0.0) == (-0.0): Eq = %b, Expected = 1", eq);

        // -------------------------  Números Subnormales -------------------------
        fp_a = 32'h00000001; fp_b = 32'h00000001; #10;
        $display("Caso 4 => (subnormal min) == (subnormal min): Eq = %b, Expected = 1", eq);

        fp_a = 32'h00000010; fp_b = 32'h00000020; #10;
        $display("Caso 5 => (subnormal pequeño) == (subnormal pequeño): Eq = %b, Expected = 0", eq);

        // -------------------------  Infinitos -------------------------
        fp_a = 32'h7f800000; fp_b = 32'h7f800000; #10;
        $display("Caso 6 => (+Inf) == (+Inf): Eq = %b, Expected = 1", eq);

        fp_a = 32'hff800000; fp_b = 32'hff800000; #10;
        $display("Caso 7 => (-Inf) == (-Inf): Eq = %b, Expected = 1", eq);

        fp_a = 32'h7f800000; fp_b = 32'hff800000; #10;
        $display("Caso 8 => (+Inf) == (-Inf): Eq = %b, Expected = 0", eq);

        // -------------------------  NaN (Siempre deben ser distintos) -------------------------
        fp_a = 32'h7fc00000; fp_b = 32'h7fc00000; #10;
        $display("Caso 9 => (NaN) == (NaN): Eq = %b, Expected = 0", eq);

        fp_a = 32'h7fc00000; fp_b = 32'h3f800000; #10;
        $display("Caso 10 => (NaN) == (1.0): Eq = %b, Expected = 0", eq);

        // -------------------------  Casos de comparación general -------------------------
        fp_a = 32'h3eaaaaab; fp_b = 32'h3eaaaaab; #10;
        $display("Caso 11 => (0.33333) == (0.33333): Eq = %b, Expected = 1", eq);

        fp_a = 32'h3fc00000; fp_b = 32'h3f800000; #10;
        $display("Caso 12 => (1.5) == (1.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'h41200000; fp_b = 32'hc1200000; #10;
        $display("Caso 13 => (10.0) == (-10.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'h47c35000; fp_b = 32'h47c35000; #10;
        $display("Caso 14 => (100000.0) == (100000.0): Eq = %b, Expected = 1", eq);

        fp_a = 32'h00000002; fp_b = 32'h00000004; #10;
        $display("Caso 15 => (subnormal min) == (subnormal min+1): Eq = %b, Expected = 0", eq);



        // -------------------------  Casos donde NO son iguales -------------------------
        fp_a = 32'h3f800000; fp_b = 32'h40000000; #10;  // 1.0 != 2.0
        $display("Caso 0 => (1.0) == (2.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'hc2480000; fp_b = 32'h42480000; #10;  // -50.0 != 50.0
        $display("Caso 1 => (-50.0) == (50.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'h7f800000; fp_b = 32'hff800000; #10;  // +Inf != -Inf
        $display("Caso 2 => (+Inf) == (-Inf): Eq = %b, Expected = 0", eq);

        fp_a = 32'h3f800001; fp_b = 32'h3f800000; #10;  // Número muy cercano a 1.0
        $display("Caso 3 => (1.0000001) == (1.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'h3fc00000; fp_b = 32'h3f800000; #10;  // 1.5 != 1.0
        $display("Caso 4 => (1.5) == (1.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'h00000001; fp_b = 32'h00000002; #10;  // Subnormales distintos
        $display("Caso 5 => (subnormal min) == (subnormal min+1): Eq = %b, Expected = 0", eq);

        fp_a = 32'h3f400000; fp_b = 32'h3f200000; #10;  // 0.75 != 0.625
        $display("Caso 6 => (0.75) == (0.625): Eq = %b, Expected = 0", eq);

        fp_a = 32'hc1c00000; fp_b = 32'h41c00000; #10;  // -24.0 != 24.0
        $display("Caso 7 => (-24.0) == (24.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'h7fc00000; fp_b = 32'h40000000; #10;  // NaN != 2.0
        $display("Caso 8 => (NaN) == (2.0): Eq = %b, Expected = 0", eq);

        fp_a = 32'h3f800000; fp_b = 32'hbf800000; #10;  // 1.0 != -1.0
        $display("Caso 9 => (1.0) == (-1.0): Eq = %b, Expected = 0", eq);


        // -------------------------  Casos donde SÍ son iguales -------------------------
        fp_a = 32'h00000000; fp_b = 32'h80000000; #10;  // +0.0 == -0.0
        $display("Caso 10 => (+0.0) == (-0.0): Eq = %b, Expected = 1", eq);

        fp_a = 32'h3f800000; fp_b = 32'h3f800000; #10;  // 1.0 == 1.0
        $display("Caso 11 => (1.0) == (1.0): Eq = %b, Expected = 1", eq);

        fp_a = 32'hc1200000; fp_b = 32'hc1200000; #10;  // -10.0 == -10.0
        $display("Caso 12 => (-10.0) == (-10.0): Eq = %b, Expected = 1", eq);

        fp_a = 32'h7f800000; fp_b = 32'h7f800000; #10;  // +Inf == +Inf
        $display("Caso 13 => (+Inf) == (+Inf): Eq = %b, Expected = 1", eq);

        fp_a = 32'hff800000; fp_b = 32'hff800000; #10;  // -Inf == -Inf
        $display("Caso 14 => (-Inf) == (-Inf): Eq = %b, Expected = 1", eq);

        fp_a = 32'h3eaaaaab; fp_b = 32'h3eaaaaab; #10;  // 0.33333 == 0.33333
        $display("Caso 15 => (0.33333) == (0.33333): Eq = %b, Expected = 1", eq);

        fp_a = 32'h3f000000; fp_b = 32'h3f000000; #10;  // 0.5 == 0.5
        $display("Caso 16 => (0.5) == (0.5): Eq = %b, Expected = 1", eq);

        fp_a = 32'h42c80000; fp_b = 32'h42c80000; #10;  // 100.0 == 100.0
        $display("Caso 17 => (100.0) == (100.0): Eq = %b, Expected = 1", eq);

        fp_a = 32'h00000001; fp_b = 32'h00000001; #10;  // Subnormal min == Subnormal min
        $display("Caso 18 => (subnormal min) == (subnormal min): Eq = %b, Expected = 1", eq);

        fp_a = 32'hc2480000; fp_b = 32'hc2480000; #10;  // -50.0 == -50.0
        $display("Caso 19 => (-50.0) == (-50.0): Eq = %b, Expected = 1", eq);


        $finish;
    end
endmodule
