#!/bin/bash

# Actualizar el repositorio antes de compilar (opcional)
git pull

# Cargar herramientas de Synopsys (si es necesario)
# source synopsys_tools.sh;

# Limpiar archivos generados previamente, excepto los archivos .sv y .sh
echo "Limpiando archivos anteriores..."
rm -rfv $(ls | grep -vE ".*\.sv$|.*\.sh$")

# Compilación y generación del binario con VCS
echo "Compilando con VCS..."
vcs -Mupdate ../../fp_unpack/*.sv ../../Comparadores/*.sv ../../Sumador_restador/*.sv ../../multiplicador/fp_mul.sv ../../Operaciones_comb/*.sv ../fp_alu.sv tb_fp_alu.sv \
    -o salida -full64 -debug_all -sverilog -l log_test \
    -ntb_opts uvm-1.2 +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_HIGH

# Verifica si la compilación fue exitosa
if [ $? -eq 0 ]; then
    echo "Compilación exitosa, ejecutando simulación..."
    # Ejecutar simulación y guardar toda la salida en reporte.txt
    script -q -c "./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_adder +ntb_random_seed=1" reporte.txt
else
    echo "Error en la compilación. Revisa el archivo log_test para más detalles."
fi

