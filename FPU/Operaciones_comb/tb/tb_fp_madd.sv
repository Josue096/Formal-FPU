module tb_fp_madd;

    logic [31:0] fp_a, fp_b, fp_c;
    logic [31:0] fp_result;
    logic [2:0] r_mode;
    logic overflow, underflow;

    // Instancia del módulo FMA (a * b + c)
    fp_madd dut (
        .fp_a(fp_a),
        .fp_b(fp_b),
        .fp_c(fp_c),
        .r_mode(r_mode),
        .fp_result(fp_result),
        .overflow(overflow),
        .underflow(underflow)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fp_madd);

        r_mode = 3'b000; // Round to Nearest Even (RNE)

        // Caso 0: (1.0 * 2.0) + 3.0 = 5.0
        fp_a = 32'h3f800000; // 1.0
        fp_b = 32'h40000000; // 2.0
        fp_c = 32'h40400000; // 3.0
        #10;
        $display("Caso 0 => (1.0 * 2.0) + 3.0 = %h, Expected = 40a00000", fp_result);

        // Caso 1: (0.5 * 4.0) + 1.0 = 3.0
        fp_a = 32'h3f000000; // 0.5
        fp_b = 32'h40800000; // 4.0
        fp_c = 32'h3f800000; // 1.0
        #10;
        $display("Caso 1 => (0.5 * 4.0) + 1.0 = %h, Expected = 40400000", fp_result);

        // Caso 2: (2.0 * -2.0) + 4.0 = 0.0
        fp_a = 32'h40000000; // 2.0
        fp_b = 32'hc0000000; // -2.0
        fp_c = 32'h40800000; // 4.0
        #10;
        $display("Caso 2 => (2.0 * -2.0) + 4.0 = %h, Expected = 00000000", fp_result);

        // Caso 3: (-1.0 * 1.0) + 0.0 = -1.0
        fp_a = 32'hbf800000; // -1.0
        fp_b = 32'h3f800000; // 1.0
        fp_c = 32'h00000000; // 0.0
        #10;
        $display("Caso 3 => (-1.0 * 1.0) + 0.0 = %h, Expected = bf800000", fp_result);

        // Caso 4: (3.0 * 2.0) + (-5.0) = 1.0
        fp_a = 32'h40400000; // 3.0
        fp_b = 32'h40000000; // 2.0
        fp_c = 32'hc0a00000; // -5.0
        #10;
        $display("Caso 4 => (3.0 * 2.0) + (-5.0) = %h, Expected = 3f800000", fp_result);


        // Caso 5: (Inf * 1.0) + 3.0 = Inf
        // +Inf multiplicado por cualquier número finito sigue siendo +Inf, y sumado con otro finito da +Inf
        fp_a = 32'h7f800000; // +Inf
        fp_b = 32'h3f800000; // 1.0
        fp_c = 32'h40400000; // 3.0
        #10;
        $display("Caso 5 => (+Inf * 1.0) + 3.0 = %h, Expected = 7f800000", fp_result);

        // Caso 6: (-Inf * 2.0) + Inf = NaN
        // -Inf * 2.0 = -Inf, luego -Inf + +Inf es una operación inválida → NaN
        fp_a = 32'hff800000; // -Inf
        fp_b = 32'h40000000; // 2.0
        fp_c = 32'h7f800000; // +Inf
        #10;
        $display("Caso 6 => (-Inf * 2.0) + (+Inf) = %h, Expected = 7fc00000 (NaN)", fp_result);

        // Caso 7: (NaN * 4.0) + 2.0 = NaN
        // Cualquier operación con NaN produce NaN
        fp_a = 32'h7fc00000; // NaN
        fp_b = 32'h40800000; // 4.0
        fp_c = 32'h40000000; // 2.0
        #10;
        $display("Caso 7 => (NaN * 4.0) + 2.0 = %h, Expected = 7fc00000", fp_result);

        // Caso 8: (1.0 * 2.0) + NaN = NaN
        // La suma con NaN produce NaN, incluso si el producto es válido
        fp_a = 32'h3f800000; // 1.0
        fp_b = 32'h40000000; // 2.0
        fp_c = 32'h7fc00000; // NaN
        #10;
        $display("Caso 8 => (1.0 * 2.0) + NaN = %h, Expected = 7fc00000", fp_result);

        $finish;
    end
endmodule
