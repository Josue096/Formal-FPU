module tb_fp_multiplier;

    logic [31:0] fp_X;
    logic [31:0] fp_Y;
    logic [31:0] fp_Z;
    logic [2:0] r_mode;
    logic ovrf, udrf;

    // Instancia del multiplicador
    fp_mul dut (
        .r_mode(r_mode),
        .fp_X(fp_X),
        .fp_Y(fp_Y),
        .fp_Z(fp_Z),
        .ovrf(ovrf),
        .udrf(udrf)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fp_multiplier);

        r_mode = 3'b000; // Round to Nearest Even (RNE)

        // -------------------------  Números Normales -------------------------

        fp_X = 32'h3f800000; fp_Y = 32'h40000000; #10;
        $display("Caso 0 => (1.0) * (2.0): Result = %h, Expected = 40000000", fp_Z);

        fp_X = 32'h40400000; fp_Y = 32'h40800000; #10;
        $display("Caso 1 => (3.0) * (4.0): Result = %h, Expected = 41400000", fp_Z);

        fp_X = 32'h3f000000; fp_Y = 32'h3f800000; #10;
        $display("Caso 2 => (0.5) * (1.0): Result = %h, Expected = 3f000000", fp_Z);

        fp_X = 32'h42c80000; fp_Y = 32'h3f800000; #10;
        $display("Caso 3 => (100.0) * (1.0): Result = %h, Expected = 42c80000", fp_Z);

        fp_X = 32'hc2480000; fp_Y = 32'h42c80000; #10;
        $display("Caso 4 => (-50.0) * (100.0): Result = %h, Expected = c59c4000", fp_Z);

        fp_X = 32'h3eaaaa3b; fp_Y = 32'h3eaaaa3b; #10;
        $display("Caso 5 => (0.33333) * (0.33333): Result = %h, Expected = 3de38d0f", fp_Z);

        fp_X = 32'h3fc00000; fp_Y = 32'h3fc00000; #10;
        $display("Caso 6 => (1.5) * (1.5): Result = %h, Expected = 40100000", fp_Z);

        fp_X = 32'h41200000; fp_Y = 32'hc1200000; #10;
        $display("Caso 7 => (10.0) * (-10.0): Result = %h, Expected = c2c80000", fp_Z);

        fp_X = 32'h3e000000; fp_Y = 32'h3dcccccd; #10;
        $display("Caso 8 => (0.125) * (0.1): Result = %h, Expected = 3c4ccccd", fp_Z);

        fp_X = 32'h47c35000; fp_Y = 32'h3f800000; #10;
        $display("Caso 9 => (100000.0) * (1.0): Result = %h, Expected = 47c35000", fp_Z);




// -------------------------  Infinitos -------------------------
        fp_X = 32'h7f800000; fp_Y = 32'h3f800000; #10;
        $display("Caso 5 => (+Inf) * (1.0): Result = %h, Expected = 7f800000", fp_Z);

        fp_X = 32'hff800000; fp_Y = 32'h3f800000; #10;
        $display("Caso 6 => (-Inf) * (1.0): Result = %h, Expected = ff800000", fp_Z);

        fp_X = 32'h7f800000; fp_Y = 32'hff800000; #10;
        $display("Caso 7 => (+Inf) * (-Inf): Result = %h, Expected = ff800000", fp_Z);

        fp_X = 32'h7f800000; fp_Y = 32'h00000000; #10;
        $display("Caso 8 => (+Inf) * (0.0): Result = %h, Expected = 7fc00000 (NaN)", fp_Z);

        fp_X = 32'hff800000; fp_Y = 32'h00000000; #10;
        $display("Caso 9 => (-Inf) * (0.0): Result = %h, Expected = 7fc00000 (NaN)", fp_Z);

        // -------------------------  NaN -------------------------
        fp_X = 32'h7fc00000; fp_Y = 32'h3f800000; #10;
        $display("Caso 10 => (NaN) * (1.0): Result = %h, Expected = 7fc00000", fp_Z);

        fp_X = 32'h7fc00000; fp_Y = 32'h7f800000; #10;
        $display("Caso 11 => (NaN) * (+Inf): Result = %h, Expected = 7fc00000", fp_Z);

        fp_X = 32'h7fc00000; fp_Y = 32'hff800000; #10;
        $display("Caso 12 => (NaN) * (-Inf): Result = %h, Expected = 7fc00000", fp_Z);

        fp_X = 32'h7fc00000; fp_Y = 32'h7fc00000; #10;
        $display("Caso 13 => (NaN) * (NaN): Result = %h, Expected = 7fc00000", fp_Z);

        fp_X = 32'h7f800000; fp_Y = 32'h7f800000; #10;
        $display("Caso 14 => (+Inf) * (+Inf): Result = %h, Expected = 7f800000", fp_Z);

        fp_X = 32'hff800000; fp_Y = 32'hff800000; #10;
        $display("Caso 15 => (-Inf) * (-Inf): Result = %h, Expected = 7f800000", fp_Z);

        fp_X = 32'hff800000; fp_Y = 32'h7f800000; #10;
        $display("Caso 16 => (-Inf) * (+Inf): Result = %h, Expected = ff800000", fp_Z);

        fp_X = 32'h00000000; fp_Y = 32'h00000000; #10;
        $display("Caso 17 => (0.0) * (0.0): Result = %h, Expected = 00000000", fp_Z);

        fp_X = 32'h80000000; fp_Y = 32'h00000000; #10;
        $display("Caso 18 => (-0.0) * (0.0): Result = %h, Expected = 80000000", fp_Z);

        fp_X = 32'h80000000; fp_Y = 32'h80000000; #10;
        $display("Caso 19 => (-0.0) * (-0.0): Result = %h, Expected = 00000000", fp_Z);




        $finish;
    end
endmodule
