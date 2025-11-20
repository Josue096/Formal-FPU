set_app_var fml_mode_on true
set_fml_appmode AEP

# Ask VC Formal to read in the filelist
set design arbiter
read_file -top $design -format sverilog -aep all -sva -vcs {    
    ../../FPU/multiplicador/fp_mul.sv

    mul_assertions.sv
    mul_bind.sv
}

# Since the formal testbench is embedded within the DUT,
# we ask the tool to drive the clock and resets
create_clock clk -period 100
create_reset rst_clk -high

# Ask VC Formal to bring the design out of reset
sim_run -stable
sim_save_reset

# Let AEP do its thing
check_fv -block
report_fv -list > aep_results.txt