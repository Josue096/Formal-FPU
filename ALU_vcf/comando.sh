
# --- Configuración del entorno Synopsys ---
source ./synopsys_tools.sh

# --- Limpiar archivos de ejecución anteriores ---
rm -rfv `ls | grep -v ".*\.sv\|.*\.sh\|.*\.tcl"`

# --- Ejecutar Synopsys Formal con tu TCL ---
# Ajusta la ruta de vfc si no está en el PATH
#vfc -tcl run_adder.tcl -full64 -cov all -log vfc_log.txt;
vcf_shell -file run_adder.tcl | tee vfc_log.txt
