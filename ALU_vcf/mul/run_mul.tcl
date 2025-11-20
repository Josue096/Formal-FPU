set design fp_mul

set_app_var fml_mode_on true
set_app_var fml_cov_tgl_input_port true
set_fml_var fml_enable_prop_density_cov_map true

set_fml_var fml_enable_cov true
set_fml_var fml_cov_full_signal true
set_fml_var fml_cover_point_backend_verdi true

read_file -top $design -format sverilog -cov all -sva -vcs {
    ../../FPU/multiplicador/fp_mul.sv
    mul_assertions.sv
    mul_bind.sv
}

sim_run -stable
sim_save_reset

check_fv -block

report_fv -list > aep_results_mul.txt

report_fml_cov -summary > cov_summary.txt
report_fml_cov -detail > cov_detail.txt
report_fml_cov -verdi_dir fml_cov_verdi
