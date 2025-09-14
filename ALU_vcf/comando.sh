
# --- Configuración del entorno Synopsys ---
source /mnt/vol_NFS_rh003/estudiantes/archivos_config/synopsys_tools.sh

# --- Limpiar archivos de ejecución anteriores (excepto .sv y .sh) ---
rm -rfv `ls | grep -v ".*\.sv\|.*\.sh\|.*\.tcl"`

# --- Ejecutar Synopsys Formal con tu TCL ---
# Ajusta la ruta de vfc si no está en el PATH
vfc -tcl run_adder.tcl -full64 -cov all -log vfc_log.txt

# --- Notificación ---
echo "Synopsys Formal finalizó. Revisa vfc_log.txt, properties_report.txt y coverage_report.txt"
