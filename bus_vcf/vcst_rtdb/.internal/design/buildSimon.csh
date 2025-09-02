#!/bin/csh -f
setenv VCS_HOME /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/vc_static/O-2018.09-SP2/vcs-mx
setenv VC_STATIC_HOME /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/vc_static/O-2018.09-SP2
setenv SYNOPSYS_SIM_SETUP /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb/.internal/design/synopsys_sim.setup

$VCS_HOME/bin/vcs /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb/.internal/design/undef_vcs.v -file /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb/.internal/design/vcsCmd -kdb -lca -error=noKDB-ELAB-E  -Xverdi_elab_opts=-saveLevel  -verdi_opts "-logdir /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb/verdi/elabcomLog " -Xvd_opts=,-ssy,-ssv,-ssz,-silent,+disable_message+C00373, -full64
