source synopsys_tools.sh
rm -rfv `ls | grep -v ".*\.sv\|.*\.sh\|.*\.tcl"`
vcf -file ./run_mul.tcl | tee salida.log
