source synopsys_tools.sh
rm -rfv `ls | grep -v ".*\.sv\|.*\.sh\|.*\.tcl"`
vcf -tcl run_adder.tcl -full64 -cov all -log vfc_log.txt;
#vc_static -file run_adder.tcl | tee vfc_log.txt
