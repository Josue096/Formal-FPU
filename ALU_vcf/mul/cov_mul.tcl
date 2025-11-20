set_app_var fml_mode_on true
set_fml_appmode COV

set design fp_mul

read_file -top $design -format sverilog -cov all -sva -vcs {
    ../../FPU/multiplicador/fp_mul.sv

    mul_assertions.sv
    mul_bind.sv
}

# Ask VC Formal to bring the design out of reset
sim_run -stable
sim_save_reset
