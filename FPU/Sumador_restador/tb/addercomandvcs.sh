#!/bin/bash

# Actualizar el repositorio antes de compilar (opcional)
git pull

# Cargar herramientas de Synopsys (si es necesario)
# source synopsys_tools.sh;

# Limpiar archivos generados previamente, excepto los archivos .sv y .sh
echo "Limpiando archivos anteriores..."
rm -rfv `ls | grep -v ".*\.sv\|.*\.sh"`

# Compilación y generación del binario con VCS
echo "Compilando con VCS..."
vcs -Mupdate ../*.sv ../../fp_unpack/fp_unpack.sv tb_fp_adder.sv -o salida -full64 -debug_all -sverilog -l log_test \
    -ntb_opts uvm-1.2 +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_HIGH

# Verifica si la compilación fue exitosa
if [ $? -eq 0 ]; then
    echo "Compilación exitosa, ejecutando simulación..."
    # Ejecutar la simulación y mostrar $display en la terminal
    ./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_adder +ntb_random_seed=1 | tee deleteme_log_1
else
    echo "Error en la compilación. Revisa el archivo log_test para más detalles."
fi
