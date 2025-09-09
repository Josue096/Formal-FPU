`include "fp_sub.sv"


module tb_fp_sub;

    logic [31:0] fp_a;
    logic [31:0] fp_b;
    logic [31:0] fp_result;
    logic [2:0]  r_mode = 3'b001; // RTZ
    logic        overflow;
    logic        underflow;
    // Instancia del módulo fp_sub
    fp_sub dut (
        .fp_a       (fp_a),
        .fp_b       (fp_b),
        .r_mode     (r_mode),
        .fp_result  (fp_result),
        .overflow   (overflow),
        .underflow  (underflow)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fp_sub);

        // -------------------------  Números Normales -------------------------

        // Caso 0: 3.0 - 1.0 = 2.0
        fp_a = 32'h40400000; fp_b = 32'h3f800000; #10;
        $display("Caso 0 => (3.0) - (1.0): Result = %h, Expected = 40000000", fp_result);

        // Caso 1: 10.5 - 4.5 = 6.0
        fp_a = 32'h41280000; fp_b = 32'h40900000; #10;
        $display("Caso 1 => (10.5) - (4.5): Result = %h, Expected = 40c00000", fp_result);

        // Caso 2: 0.75 - 0.5 = 0.25
        fp_a = 32'h3f400000; fp_b = 32'h3f000000; #10;
        $display("Caso 2 => (0.75) - (0.5): Result = %h, Expected = 3e800000", fp_result);

        // Caso 3: 100.0 - 50.0 = 50.0
        fp_a = 32'h42c80000; fp_b = 32'h42480000; #10;
        $display("Caso 3 => (100.0) - (50.0): Result = %h, Expected = 42480000", fp_result);

        // Caso 4: -20.0 - (-10.0) = -10.0
        fp_a = 32'hc1a00000; fp_b = 32'hc1200000; #10;
        $display("Caso 4 => (-20.0) - (-10.0): Result = %h, Expected = c1200000", fp_result);

        // Caso 5: 1.5 - 1.5 = 0.0
        fp_a = 32'h3fc00000; fp_b = 32'h3fc00000; #10;
        $display("Caso 5 => (1.5) - (1.5): Result = %h, Expected = 00000000", fp_result);

        // Caso 6: 10.0 - 15.0 = -5.0
        fp_a = 32'h41200000; fp_b = 32'h41700000; #10;
        $display("Caso 6 => (10.0) - (15.0): Result = %h, Expected = c0a00000", fp_result);

        // Caso 7: 0.1 - 0.125 = -0.025
        fp_a = 32'h3dcccccd; fp_b = 32'h3e000000; #10;
        $display("Caso 7 => (0.1) - (0.125): Result = %h, Expected = bccccccd", fp_result);

        // Caso 8: 100000.0 - 50000.0 = 50000.0
        fp_a = 32'h47c35000; fp_b = 32'h47c35000; #10;
        $display("Caso 8 => (100000.0) - (100000.0): Result = %h, Expected = 00000000", fp_result);

        // Caso 9: -3.5 - 2.5 = -6.0
        fp_a = 32'hc0600000; fp_b = 32'h40200000; #10;
        $display("Caso 9 => (-3.5) - (2.5): Result = %h, Expected = c0c00000", fp_result);

        // Caso 10: 0 - 3.14 = -3.14
        fp_a = 32'h00000000; fp_b = 32'h4048f5c3; #10;
        $display("Caso 10 => (0) - (3.14): Result = %h, Expected = c048f5c3", fp_result);

        // Caso 11: +Inf - +Inf = NaN
        fp_a = 32'h7f800000; fp_b = 32'h7f800000; #10;
        $display("Caso 11 => (+Inf) - (+Inf): Result = %h, Expected = 7fc00000", fp_result);




        // Caso 12: 7.25 - 3 = 4.25
        fp_a = 32'h40e80000; fp_b = 32'h40400000; #10;
        $display("Caso 12 => (7.25) - (3): Result = %h, Expected = 40880000", fp_result);

        // Caso 13: -2.75 - (-1.25) = -1.5
        fp_a = 32'hc0300000; fp_b = 32'hbfa00000; #10;
        $display("Caso 13 => (-2.75) - (-1.25): Result = %h, Expected = bfc00000", fp_result);

        // Caso 14: 50.0 - 25.0 = 25.0
        fp_a = 32'h42480000; fp_b = 32'h41c80000; #10;
        $display("Caso 14 => (50.0) - (25.0): Result = %h, Expected = 41c80000", fp_result);

        // Caso 15: -0.5 - 1.5 = -2.0
        fp_a = 32'hbf000000; fp_b = 32'h3fc00000; #10;
        $display("Caso 15 => (-0.5) - (1.5): Result = %h, Expected = c0000000", fp_result);

        // Caso 16: 1024.0 - 512.0 = 512.0
        fp_a = 32'h44800000; fp_b = 32'h44000000; #10;
        $display("Caso 16 => (1024.0) - (512.0): Result = %h, Expected = 44000000", fp_result);

        // Caso 17: -12.75 - (-3.25) = -9.5
        fp_a = 32'hc14c0000; fp_b = 32'hc0500000; #10;
        $display("Caso 17 => (-12.75) - (-3.25): Result = %h, Expected = c1180000", fp_result);

        // Caso 18: 2048.5 - 1024.25 = 1024.25
        fp_a = 32'h45000800; fp_b = 32'h44800800; #10;
        $display("Caso 18 => (2048.5) - (1024.25): Result = %h, Expected = 44800800", fp_result);

        // Caso 19: 0.375 - (-0.625) = 1.0
        fp_a = 32'h3ec00000; fp_b = 32'hbf200000; #10;
        $display("Caso 19 => (0.375) - (-0.625): Result = %h, Expected = 3f800000", fp_result);

        // Caso 20: 0.0001 - 0.00005 = 0.00005
        fp_a = 32'h38d1b717; fp_b = 32'h3851b717; #10;
        $display("Caso 20 => (0.0001) - (0.00005): Result = %h, Expected = 3851b717", fp_result);

        // Caso 21: -256.75 - 128.5 = -385.25
        fp_a = 32'hc3806000; fp_b = 32'h43008000; #10;
        $display("Caso 21 => (-256.75) - (128.5): Result = %h, Expected = c3c0a000", fp_result);


            //SUBNORMALES
        
        // Caso 22: 1.4e-45 - 0 
        fp_a = 32'h00000001; fp_b = 32'h00000000; #10;
        $display("Caso 22 => (1.4e-45) - (7.0e-46): Result = %h, Expected = 00000001", fp_result);

        // Caso 23: 5.6e-45 - 2.8e-45 = 2.8e-45
        fp_a = 32'h00000004; fp_b = 32'h00000002; #10;
        $display("Caso 23 => (5.6e-45) - (2.8e-45): Result = %h, Expected = 00000002", fp_result);

        // Caso 24: 1.12e-44 - 8.4e-45 = 2.8e-45
        fp_a = 32'h00000008; fp_b = 32'h00000006; #10;
        $display("Caso 24 => (1.12e-44) - (8.4e-45): Result = %h, Expected = 00000002", fp_result);

        // Caso 25: -5.6e-45 - 2.8e-45 = -8.4e-45
        fp_a = 32'h80000004; fp_b = 32'h00000002; #10;
        $display("Caso 25 => (-5.6e-45) - (2.8e-45): Result = %h, Expected = 80000006", fp_result);

        // Caso 26: 1.12e-44 - (-5.6e-45) = 1.68e-44
        fp_a = 32'h00000008; fp_b = 32'h80000004; #10;
        $display("Caso 26 => (1.12e-44) - (-5.6e-45): Result = %h, Expected = 0000000c", fp_result);

        // Caso 27: -1.4e-45 - (-1.4e-45) = 0.0
        fp_a = 32'h80000001; fp_b = 32'h80000001; #10;
        $display("Caso 27 => (-1.4e-45) - (-1.4e-45): Result = %h, Expected = 00000000", fp_result);

        // Caso 28: 2.8e-45 - 20e-44 = 0.0
        fp_a = 32'h00000002; fp_b = 32'h0000008f; #10;
        $display("Caso 28 => (2.8e-45) - (20e-44): Result = %h, Expected = 8000008d", fp_result);

        // Caso 29: -1.12e-44 - 5.6e-45 = -1.68e-44
        fp_a = 32'h80000008; fp_b = 32'h00000004; #10;
        $display("Caso 29 => (-1.12e-44) - (5.6e-45): Result = %h, Expected = 8000000c", fp_result);

        // Caso 30: 7.0e-46 - 1.4e-45 = -7.0e-46
        fp_a = 32'h00000000; fp_b = 32'h00000001; #10;
        $display("Caso 30 => (7.0e-46) - (1.4e-45): Result = %h, Expected = 80000001", fp_result);

        // Caso 31: -2.8e-45 - (-1.4e-45) = -1.4e-45
        fp_a = 32'h80000002; fp_b = 32'h80000001; #10;
        $display("Caso 31 => (-2.8e-45) - (-1.4e-45): Result = %h, Expected = 80000001", fp_result);

        //INFINITOS

        // Caso 32: +Inf - 1000.0 = +Inf
        fp_a = 32'h7f800000; fp_b = 32'h447a0000; #10;
        $display("Caso 32 => (+Inf) - (1000.0): Result = %h, Expected = 7f800000", fp_result);

        // Caso 33: -Inf - (-500.5) = -Inf
        fp_a = 32'hff800000; fp_b = 32'h43fa4000; #10;
        $display("Caso 33 => (-Inf) - (-500.5): Result = %h, Expected = ff800000", fp_result);

        // Caso 34: +Inf - (-Inf) = +Inf
        fp_a = 32'h7f800000; fp_b = 32'hff800000; #10;
        $display("Caso 34 => (+Inf) - (-Inf): Result = %h, Expected = 7f800000", fp_result);

        // Caso 35: -Inf - (+Inf) = -Inf
        fp_a = 32'hff800000; fp_b = 32'h7f800000; #10;
        $display("Caso 35 => (-Inf) - (+Inf): Result = %h, Expected = ff800000", fp_result);

        // Caso 36: +Inf - (+Inf) = NaN
        fp_a = 32'h7f800000; fp_b = 32'h7f800000; #10;
        $display("Caso 36 => (+Inf) - (+Inf): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 37: -Inf - (-Inf) = NaN
        fp_a = 32'hff800000; fp_b = 32'hff800000; #10;
        $display("Caso 37 => (-Inf) - (-Inf): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 38: +Inf - 0.0 = +Inf
        fp_a = 32'h7f800000; fp_b = 32'h00000000; #10;
        $display("Caso 38 => (+Inf) - (0.0): Result = %h, Expected = 7f800000", fp_result);

        // Caso 39: -Inf - 0.0 = -Inf
        fp_a = 32'hff800000; fp_b = 32'h00000000; #10;
        $display("Caso 39 => (-Inf) - (0.0): Result = %h, Expected = ff800000", fp_result);

        // Caso 40: 0.0 - (+Inf) = -Inf
        fp_a = 32'h00000000; fp_b = 32'h7f800000; #10;
        $display("Caso 40 => (0.0) - (+Inf): Result = %h, Expected = ff800000", fp_result);

        // Caso 41: 0.0 - (-Inf) = +Inf
        fp_a = 32'h00000000; fp_b = 32'hff800000; #10;
        $display("Caso 41 => (0.0) - (-Inf): Result = %h, Expected = 7f800000", fp_result);

        //Not A Number


      // Caso 42: NaN - 3.0 = NaN
        fp_a = 32'h7fc00000; fp_b = 32'h40400000; #10;
        $display("Caso 42 => (NaN) - (3.0): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 43: 5.0 - NaN = NaN
        fp_a = 32'h40a00000; fp_b = 32'h7fc00000; #10;
        $display("Caso 43 => (5.0) - (NaN): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 44: NaN - NaN = NaN
        fp_a = 32'h7fc00000; fp_b = 32'h7fc00000; #10;
        $display("Caso 44 => (NaN) - (NaN): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 45: NaN - (-Inf) = NaN
        fp_a = 32'h7fc00000; fp_b = 32'hff800000; #10;
        $display("Caso 45 => (NaN) - (-Inf): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 46: +Inf - NaN = NaN
        fp_a = 32'h7f800000; fp_b = 32'h7fc00000; #10;
        $display("Caso 46 => (+Inf) - (NaN): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 47: NaN - 0.0 = NaN
        fp_a = 32'h7fc00000; fp_b = 32'h00000000; #10;
        $display("Caso 47 => (NaN) - (0.0): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 48: -0.0 - NaN = NaN
        fp_a = 32'h80000000; fp_b = 32'h7fc00000; #10;
        $display("Caso 48 => (-0.0) - (NaN): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 49: NaN - (subnormal) = NaN
        fp_a = 32'h7fc00000; fp_b = 32'h00000001; #10;
        $display("Caso 49 => (NaN) - (subnormal): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 50: (subnormal) - NaN = NaN
        fp_a = 32'h00000001; fp_b = 32'h7fc00000; #10;
        $display("Caso 50 => (subnormal) - (NaN): Result = %h, Expected = 7fc00000", fp_result);

        // Caso 51: NaN - (-NaN) = NaN
        fp_a = 32'h7fc00000; fp_b = 32'hffc00000; #10;
        $display("Caso 51 => (NaN) - (-NaN): Result = %h, Expected = 7fc00000", fp_result);



        $finish;
    end

endmodule
