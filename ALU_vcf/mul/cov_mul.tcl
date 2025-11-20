set design fp_mul

set_app_var fml_mode_on true

read_file -top $design -format sverilog -cov all -sva -vcs {
    ../../FPU/multiplicador/fp_mul.sv
    mul_assertions.sv
    mul_bind.sv
}

sim_run -stable
sim_save_reset

check_fv -block

report_fv -list > aep_results_mul.txt

# ----- COBERTURA DISPONIBLE EN TU VCF -----

# Dead code coverage (muy útil)
compute_dead_code

# Per-property bounded coverage
compute_per_prop_bounded_cov

# Exportar resultados al Coverage Database
save_covdb -o cov_results

# Exportar resultados de bounded coverage
save_per_prop_bounded_cov_results -o bounded_results

# Exportar formal core coverage
save_formal_core_results -o core_results
