source synopsys_tools.sh
rm -rfv `ls | grep -v ".*\.sv\|.*\.sh\|.*\.tcl"`
vcf -file ./adder/run_adder.tcl | tee salida.log
#vcf -file ./mul/run_mul.tcl | tee salida.log
