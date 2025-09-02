verdiWindowResize -win $_Verdi_1 "198" "305" "768" "518"
debImport \
          "/mnt/vol_NFS_rh003/estudiantes/jmorales/TEC_RISCV/BUS_Micro/Bus_Micro.sv" \
          "-sv" -path {/mnt/vol_NFS_rh003/estudiantes/jmorales/bus_vcf}
srcHBSelect "tec_riscv_bus" -win $_nTrace1
debExit
