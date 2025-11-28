set_app_var fml_mode_on true
set_app_var fml_cov_tgl_input_port true
set_fml_var fml_enable_prop_density_cov_map true

# El top YA NO ES el DUT directamente
set design fp_comm_wrapper

read_file -top $design -format sverilog -cov all -sva -vcs {
    ../../FPU/Sumador_restador/fp_adder.sv
    ../../FPU/fp_unpack/fp_unpack.sv
    ../../FPU/Sumador_restador/align_exponents.sv
    ../../FPU/Sumador_restador/add_sub_mantissas.sv
    ../../FPU/Sumador_restador/normalize_result.sv
    ../../FPU/Sumador_restador/round.sv
    ../../FPU/Sumador_restador/fp_pack.sv
        # Nuevo wrapper que contiene 2 DUTs
    omm_wrapper.sv
}

sim_run -stable
sim_save_reset
check_fv -block
report_fv -list > aep_results_adder_wrape.txt
