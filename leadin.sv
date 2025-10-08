module test_leading_zero_count;

  logic [23:0] mantissa_sum;
  int zeros;

  initial begin
    mantissa_sum = 24'b0000_0000_0001_0000_0000_0000;
    zeros = leading_zero_count(mantissa_sum);
    $display("mantissa_sum = %b", mantissa_sum);
    $display("leading_zero_count = %0d", zeros);

    mantissa_sum = 24'b0001_0000_0000_0000_0000_0000;
    zeros = leading_zero_count(mantissa_sum);
    $display("mantissa_sum = %b", mantissa_sum);
    $display("leading_zero_count = %0d", zeros);

    mantissa_sum = 24'b1111_1111_1111_1111_1111_1111;
    zeros = leading_zero_count(mantissa_sum);
    $display("mantissa_sum = %b", mantissa_sum);
    $display("leading_zero_count = %0d", zeros);

    $finish;
  end

endmodule
