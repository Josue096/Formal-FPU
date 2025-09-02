gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
verdiDockWidgetHide -dock widgetDock_<HvpDetail>
verdiDockWidgetHide -dock widgetDock_<Hvp>
verdiDockWidgetHide -dock widgetDock_<DataBaseDiff>
verdiDockWidgetHide -dock widgetDock_<PlanDiff>
verdiDockWidgetHide -dock widgetDock_<Test>
verdiDockWidgetSetCurTab -dock widgetDock_<ExclMgr>
verdiDockWidgetSetCurTab -dock widgetDock_Message
gui_exclusion -set_force true
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_exclusion_file -load -file {/mnt/vol_NFS_Zener/WD_ESPEC/JRojasM/mesi/bus_vcf/vcst_rtdb/cov_debug/COV_UA_Auto_011021_14:14.el}
gui_open_source -id CovSrc.1  -active  tec_riscv_bus  -activate  -matrix  Line
gui_vcst_action -reload_force
verdiDockWidgetHide -dock widgetDock_<HvpDetail>
verdiDockWidgetHide -dock widgetDock_<Hvp>
verdiDockWidgetHide -dock widgetDock_<DataBaseDiff>
verdiDockWidgetHide -dock widgetDock_<PlanDiff>
verdiDockWidgetHide -dock widgetDock_<Test>
verdiDockWidgetSetCurTab -dock widgetDock_<ExclMgr>
verdiDockWidgetSetCurTab -dock widgetDock_Message
gui_exclusion -set_force true
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_exclusion_file -load -file {/mnt/vol_NFS_Zener/WD_ESPEC/JRojasM/mesi/bus_vcf/vcst_rtdb/cov_debug/COV_UA_Auto_011021_14:18.el}
gui_open_source -id CovSrc.1  -active  tec_riscv_bus  -activate  -matrix  Line
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tec_riscv_bus
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tec_riscv_bus  tec_riscv_bus.sva_bus_inst   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tec_riscv_bus.sva_bus_inst  tec_riscv_bus.fifo_in_mbc   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tec_riscv_bus.fifo_in_mbc
gui_list_expand -id CoverageTable.1   tec_riscv_bus.fifo_in_mbc
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} tec_riscv_bus.fifo_in_mbc  -column {} 
gui_covdetail_select -id  CovDetail.1   -name   Toggle
gui_list_select -id CovDetail.1 -list tgl { {Din[64:0]}   }
gui_list_action -id  CovDetail.1 -list {tgl} {Din[64:0]}
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_src_highlight_item -id CovSrc.1 -lfrom 239 -idxfrom 19 -fileIdFrom 0 -lto 239 -idxto 22 -fileIdTo 0 -selection {Din} -selectionId 0 -replace 0
gui_src_highlight_item -id CovSrc.1 -lfrom 239 -idxfrom 19 -fileIdFrom 0 -lto 239 -idxto 22 -fileIdTo 0 -selection {Din} -selectionId 0 -replace 0
gui_cov_src_double_click -id CovSrc.1 -line 239 -col 20 -insert 0 -file /mnt/vol_NFS_Zener/WD_ESPEC/JRojasM/TEC_RISCV/BUS_Micro/../FIFO_Latches/fifo.sv
gui_src_highlight_item -id CovSrc.1 -lfrom 239 -idxfrom 19 -fileIdFrom 0 -lto 239 -idxto 22 -fileIdTo 0 -selection {Din} -selectionId 0 -replace 0
gui_src_highlight_item -id CovSrc.1 -lfrom 241 -idxfrom 8 -fileIdFrom 0 -lto 241 -idxto 12 -fileIdTo 0 -selection {push} -selectionId 0 -replace 0
gui_src_highlight_item -id CovSrc.1 -lfrom 241 -idxfrom 8 -fileIdFrom 0 -lto 241 -idxto 12 -fileIdTo 0 -selection {push} -selectionId 0 -replace 0
gui_cov_src_double_click -id CovSrc.1 -line 241 -col 9 -insert 0 -file /mnt/vol_NFS_Zener/WD_ESPEC/JRojasM/TEC_RISCV/BUS_Micro/../FIFO_Latches/fifo.sv
gui_src_highlight_item -id CovSrc.1 -lfrom 241 -idxfrom 8 -fileIdFrom 0 -lto 241 -idxto 12 -fileIdTo 0 -selection {push} -selectionId 0 -replace 0
gui_covdetail_select -id  CovDetail.1   -name   FSM
gui_covdetail_select -id  CovDetail.1   -name   Condition
gui_covdetail_select -id  CovDetail.1   -name   Branch
gui_covdetail_select -id  CovDetail.1   -name   Line
gui_covdetail_select -id  CovDetail.1   -name   Toggle
gui_covtable_show -show  { Module List } -id  CoverageTable.1  -test  MergedTest
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
gui_covtable_show -show  { Asserts } -id  CoverageTable.1  -test  MergedTest
gui_covtable_show -show  { Function Groups } -id  CoverageTable.1  -test  MergedTest
gui_covtable_show -show  { Statistics } -id  CoverageTable.1  -test  MergedTest
gui_covtable_show -show  { Design Hierarchy } -id  CoverageTable.1  -test  MergedTest
verdiDockWidgetSetCurTab -dock widgetDock_<ExclMgr>
gui_list_select -id ExclMgr.1 -list exclMgrList { {tec_riscv_bus.Instance.../tec_riscv_bus..46.D_pop_mbc[0].0to1}   }
gui_list_action -id  ExclMgr.1 -list {exclMgrList} {tec_riscv_bus.Instance.../tec_riscv_bus..46.D_pop_mbc[0].0to1}
gui_list_action -id  ExclMgr.1 -list {exclMgrList} {tec_riscv_bus.Instance.../tec_riscv_bus..46.D_pop_mbc[0].0to1}
gui_list_select -id ExclMgr.1 -list exclMgrList { {tec_riscv_bus.Instance.../tec_riscv_bus..46.D_pop_mbc[0].0to1}  {tec_riscv_bus.Instance.../tec_riscv_bus..46.D_pop_mbc[2].0to1}   }
gui_list_select -id ExclMgr.1 -list exclMgrList { {tec_riscv_bus.Instance.../tec_riscv_bus..46.D_pop_mbc[2].0to1}   }
gui_list_select -id ExclMgr.1 -list exclMgrList { {tec_riscv_bus.Instance.../tec_riscv_bus..46.D_pop_mbc[0].0to1}   }
verdiDockWidgetSetCurTab -dock widgetDock_Message
gui_list_action -id  CovDetail.1 -list {tgl} {D_pop_mbc[64:0]}
gui_list_select -id CovDetail.1 -list tglDetail { {D_pop_mbc[64:0]}   }
gui_covdetail_select -id  CovDetail.1   -name   Condition
gui_covdetail_select -id  CovDetail.1   -name   FSM
gui_covdetail_select -id  CovDetail.1   -name   Toggle
gui_list_select -id CovDetail.1 -list tgl { {D_pop_mbc[64:0]}  {D_push_mbc[64:0]}   }
gui_list_action -id  CovDetail.1 -list {tgl} {D_push_mbc[64:0]}
vdCovExit -noprompt
