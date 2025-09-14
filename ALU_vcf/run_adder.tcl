# --- Configuración ---
set_app_var fml_mode_on true
set_app_var fml_cov_tgl_input_port true
set_fml_var fml_enable_prop_density_cov_map true

# --- TOP ---
set design fp_adder

# --- Leer archivos ---
read_file -top $design -format sverilog -cov all -sva -vcs {
    ../ALU_FP/fp_adder.sv
    adder_assertions.sv
    adder_bind.sv
}

# --- Correr ---
sim_run -stable
sim_save_reset
report_properties -all > properties_report.txt
report_coverage -all > coverage_report.txt
