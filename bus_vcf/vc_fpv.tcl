set_app_var fml_mode_on true
set_fml_appmode FPV

set design tec_riscv_bus
read_file -top $design -format sverilog -aep all -sva -vcs {-f filelist}

create_clock clk -period 100
create_reset reset -low

sim_run -stable
sim_save_reset
check_fv_setup
report_fv -list
