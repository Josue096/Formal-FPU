set_app_var fml_mode_on true
set_fml_appmode COV

# Enable SVA property coverage
set_app_var fml_enable_prop_density_cov_map true
set_fml_var fml_enable_property_coverage true

set design fp_mul

read_file -top $design -format sverilog -cov all -sva -vcs {
    ../../FPU/multiplicador/fp_mul.sv
    mul_assertions.sv
    mul_bind.sv
}

# Let VC Formal find a stable reset
sim_run -stable
sim_save_reset
