set_app_var fml_mode_on true
set_app_var fml_cov_tgl_input_port true
set_fml_var fml_enable_prop_density_cov_map true

# El top YA NO ES el DUT directamente
set design fp_comm_wrapper

read_file -top $design -format sverilog -cov all -sva -vcs {
    ../../FPU/multiplicador/fp_mul.sv
    omm_wrapper.sv
}

sim_run -stable
sim_save_reset
check_fv -block
report_fv -list > aep_results_mul_wrape.txt

