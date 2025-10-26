#!/usr/bin/env bash
#####################################################
# Title:        synopsys_tools.sh
# Description:  Punteros a ejecutables Synopsys 2023
# Author:       DCILab       
# Institution:  Instituto Tecnologico de Costa Rica                                    
# Date:         03 de Junio de 2025
# Version:      U-2023.03-SP2
# Updated by:   Juan Jose Montero
#               Tiler Urena
#####################################################

######################################
# --- CONFIGURACION DEL PROYECTO --- #
######################################

export DESIGN_HOME=$PWD
export EDITOR=gedit;

########################################
# --- CONFIGURACION DE LA LICENCIA --- # 
########################################

export SYNOPSYS_HOME=/mnt/vol_NFS_rh003/TOOLS/Synopsys
export SNPSLMD_LICENSE_FILE=27020@172.21.99.41;
export SNPSLMD_QUEUE=TRUE;

#################################################
# --- CONFIGURACION DE RUTAS A HERRAMIENTAS --- #
#################################################

## ASIP Designer
export PATH=$PATH:${SYNOPSYS_HOME}/asip_designer/U-2023.06-SP1/linux64/bin

## Custom Compiler
export PATH=$PATH:${SYNOPSYS_HOME}/customcompiler/U-2023.03-SP2/bin

## Design Compiler
export PATH=$PATH:$SYNOPSYS_HOME/syn/U-2022.12-SP6/bin

## FineSim
export FINESIM_HOME=${SYNOPSYS_HOME}/finesim/U-2023.03-SP2
export PATH=$PATH:${FINESIM_HOME}/bin

## Fusion Compiler
export PATH=$PATH:${SYNOPSYS_HOME}/fusioncompiler/U-2022.12-SP6/bin

## HSPICE
export PATH=$PATH:${SYNOPSYS_HOME}/hspice/U-2023.03-SP2/hspice/bin

## IC Compiler
export PATH=$PATH:${SYNOPSYS_HOME}/icc/U-2022.12-SP6/bin

## IC Compiler 2
export PATH=$PATH:${SYNOPSYS_HOME}/icc2/U-2022.12-SP6/bin

## IC Validator
export ICV_HOME_DIR=${SYNOPSYS_HOME}/icvalidator/U-2022.12-SP4
export PATH=$PATH:${ICV_HOME_DIR}/bin

## Library Compiler
export PATH=$PATH:$SYNOPSYS_HOME/lc/U-2022.12-SP6/bin

## Milkyway
export PATH=$PATH:${SYNOPSYS_HOME}/mw/U-2022.12-SP6/bin

## PrimeSim
export PATH=$PATH:$SYNOPSYS_HOME/primesim/U-2023.03-SP2/bin

## PrimeTime
export PATH=$PATH:${SYNOPSYS_HOME}/prime/U-2022.12-SP5/bin

## PrimeWave
export PATH=$PATH:${SYNOPSYS_HOME}/primewave/U-2023.03-SP2/bin

## Silicon Smart
export SILICONSMART_HOME=${SYNOPSYS_HOME}/siliconsmart
export PATH=$PATH:${SILICONSMART_HOME}/U-2022.12-SP5/bin

## StarRC
export PATH=$PATH:${SYNOPSYS_HOME}/starrc/U-2022.12-SP5/bin

## SCL
export PATH=$PATH:${SYNOPSYS_HOME}/scl/2023.03-SP1/linux64/bin

## UVM path
export UVM_HOME=${SYNOPSYS_HOME}/vcs/U-2023.03-SP2/etc/uvm-1.2

## VC Static
export VC_STATIC_HOME=${SYNOPSYS_HOME}/vc_static/U-2023.03-SP2
export PATH=$PATH:${VC_STATIC_HOME}/bin

## VCPS
export VCPS_HOME=${SYNOPSYS_HOME}/vcps/U-2023.03-SP2-2
export PATH=$PATH:${VCPS_HOME}/bin

## VCS
export VCS_HOME=${SYNOPSYS_HOME}/vcs/U-2023.03-SP2
export PATH=$PATH:${VCS_HOME}/bin

## Verdi
export VERDI_HOME=${SYNOPSYS_HOME}/verdi/U-2023.03-SP2
export PATH=$PATH:${VERDI_HOME}/bin

## WaveView
export PATH=$PATH:${SYNOPSYS_HOME}/wv/U-2023.03-SP2/bin

## XA
export PATH=$PATH:${SYNOPSYS_HOME}/xa/U-2023.03-SP2/bin

## Euclide
export PATH=$PATH:${SYNOPSYS_HOME}/euclide/Euclide-2023.12-SP1-2/linux.gtk.x86_64/eclipse/bin

#######################################
# --- DESIGN KIT XFAB XH018 XT018 --- #
#######################################

# Este es el viejo (2023) 

export FTK_KIT_DIR=/mnt/vol_synopsys2023/pdks/xfab/design/xkit
export PATH=$PATH:${FTK_KIT_DIR}/x_all/synopsys/xenv

