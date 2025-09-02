## VerdiPlay
source ./verdi_vcst.tcl
verdiVcstResizeTopWin
verdiWindowRestoreUserLayout -lastRunLayout
verdiDockWidgetSetCurTab -dock windowDock_vcstConsole_2
source /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/vc_static/O-2018.09-SP2/auxx/monet/tcl/menu.tcl

verdiSetRCValue -section appSetting -key fv -value {};verdiSetRCValue -section appSetting -key cov -value {};verdiSetRCValue -section appSetting -key seq -value {};verdiSetRCValue -section appSetting -key cc -value {};verdiSetRCValue -section appSetting -key con -value {};verdiSetRCValue -section appSetting -key fta -value {};verdiSetRCValue -section appSetting -key frv -value {};verdiSetRCValue -section appSetting -key fsv -value {};verdiSetRCValue -section appSetting -key fxp -value {};verdiSetRCValue -section appSetting -key dpv -value {};verdiSetRCValue -section appSetting -key showDisabled -value {true};verdiSetRCValue -section appSetting -key showWaived -value {false};verdiSetRCValue -section appSetting -key enableLiveSearch -value {false};verdiSetRCValue -section appSetting -key enableCaseSensitiveSearch -value {false};verdiSetRCValue -section appSetting -key showStatusText -value {false};verdiSetRCValue -section appSetting -key showConstantAnnot -value {true};verdiSetRCValue -section appSetting -key font -value {Bitstream Vera Sans(11)};verdiSetRCValue -section icmSetting -key startICMOverWrite -value {false};verdiSetRCValue -section icmSetting -key startICMNoAssumeProven -value {false};verdiSetRCValue -section icmSetting -key stepDepth -value {2};verdiSetRCValue -section icmSetting -key bmcDepth -value {50};verdiSetRCValue -section icmSetting -key checkICMBlock -value {false};verdiSetRCValue -section icmSetting -key endICMDeleteICMTask -value {false};verdiSetRCValue -section icmSetting -key endICMCopyOnlySelectedProps -value {false};verdiSetRCValue -section appSetting -key showNewVacuityIcon -value {false};verdiSetRCValue -section appSetting -key enableXTriggeringSchematic -value {false};verdiSetRCValue -section vdCovSetting -key scopeComplexity -value {false};verdiSetRCValue -section vdCovSetting -key scopeCOV -value {false};verdiSetRCValue -section vdCovSetting -key coiOABA -value {false};verdiSetRCValue -section vdCovSetting -key coiOAPBA -value {true};verdiSetRCValue -section vdCovSetting -key coiFCAll -value {false};verdiSetRCValue -section vdCovSetting -key coiFCSelected -value {true};verdiSetRCValue -section appSetting -key syncScope -value {false};verdiSetRCValue -section appSetting -key icon -value {20};sysRcFileSaveFlush;
verdiVcstOnPropSelectionChanged -strNum 0 -propList {}
verdiDockWidgetSetCurTab -dock widgetDock_VCF:GoalList
verdiDockWidgetSetCurTab -dock widgetDock_VCF:TaskList
verdiVcstSetAppmode -mode FPV -fromVcst
set ::vcst::_fml_max_proof_depth {-1};set ::vcst::_fml_max_time {12H}
verdiGetVcstCmdResult -xmlstr {<Command name="sim_run" status="1" />}
verdiSetStatusMsg -win Verdi_1 -color red { Design import... cross probing not ready }
set ::vcst::_top "tec_riscv_bus"
set ::vcst::_elab ""
set ::vcst::_elabOpts {}
set ::vcst::_rtdbDir {/mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb}
set ::vcst::_hiddenDir {.internal}
set ::vcst::_masterMode true
set ::vcst::_workLib "work"
set ::vcst::_upfOpts " -upf "
set ::vcst::_enableKdb "true"
set ::vcst::_simBinPath "simv"
set ::vcst::_goldenUpfConfig {}
set ::vcst::_nldmNschema {false}
set ::vcst::_kdbAlias {true}
set ::vcst::_covDut {}
set ::vcst::_splitbus {false}
set ::vcst::_enableVerdiLog {1}
set ::vcst::_fml_max_proof_depth {-1}
set ::vcst::_libArgs ""
set ::vcst::_seqXmlFile ""
schSetPreference -turboLibs "" -turboLibPaths ""
verdiSetPrefEnv -bSpecifyWindowTitleForDockContainer off
schSetPreference -detailRTL on
paSetPreference -brightenPowerColor on
schSetPreference -showPassThroughNet on
paSetPreference -AnnotateSignal off
paSetPreference -highlightPowerObject off
srcAssertSetOpt -addSigToWave 0 -addSigWithExpGrp 1 -maskWave 0 -ShowCycleInfo 1
verdiRunVcst -on
schSetVCSTDelimiter -hierDelim .
srcSetXpropOption "tmerge"
set ::vcst::_powerDbDir ""
set ::vcst::_bRestore ""
verdiDockWidgetFix -dock widgetDock_VCF:GoalList
::vcst::loadMainWin "0"
verdiDockWidgetUnfix -dock widgetDock_VCF:GoalList

setStyleFvProgress -css {font-family:Bitstream Vera Sans monospace;font-size:11px}
setStyleFvGoalProgress -css {font-family:Bitstream Vera Sans monospace;font-size:11px}
verdiSetFont -font "Bitstream Vera Sans" -size "11"
verdiSetPrefEnv -monoFontSize "11"
verdiVcstEnableAppMode -enable FRV

verdiRunVcstCmd "action aaVerdiWaitAnnotation -trigger
" -no_wait
verdiRunVcstCmd "action aaMonetSetReuseWave -data \{[verdiGetRCValue -section appSetting -key reuseWave]\}
" -no_wait
verdiSetPrefEnv -bDockNewWindowInContainerWhenFindSameType "off"
verdiSetStatusMsg -win Verdi_1 -color black { Design import ready }
verdiGetVcstCmdResult -xmlstr {<Command name="action" received="1"></Command>}

verdiGetVcstCmdResult -xmlstr {<Command name="action" status="1"></Command>}

verdiGetVcstCmdResult -xmlstr {<Command name="action" received="1"></Command>}

verdiGetVcstCmdResult -xmlstr {<Command name="action" status="1"></Command>}

set ::vcst::_bRestore ""
verdiLayoutFreeze -off
verdiGetVcstCmdResult -xmlstr {<Command name="sim_save_reset" status="1" />}
verdiSetRCValue -section appSetting -key conSize -value {PROPERTY_CLASS,100:PROPERTY_CLOCK,100:PROPERTY_ENABLED,100:PROPERTY_EXPRESSION,100:PROPERTY_ID,100:PROPERTY_INSTANCE,100:PROPERTY_LANGUAGE,100:PROPERTY_LOCATION,100:PROPERTY_NAME,100:PROPERTY_SCOPE,100:PROPERTY_SIGNALS,100:PROPERTY_SVA_TYPE,100:PROPERTY_TYPE,100:PROPERTY_USAGE,100:PROPERTY_VACUITY,100:PROPERTY_WITNESS,100:};
verdiLayoutFreeze -off
::vcst::showDebugViews -1 false false setupSource
verdiWindowMoveDockTab -win Verdi_1 widgetDock_VCF:Shell widgetDock_VCF:GoalList widgetDock_<Message>
verdiDockWidgetSetCurTab -dock widgetDock_VCF:GoalList

srcSetBlackbox   -delim {.}
srcSetSnipSignal -reset
report_fv_complexity -silent
vcstPropertyDensityShow -silent abstraction
srcSetSnipSignal -file {/mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb/.internal/verdi/snip_signals.list}
report_fv_complexity -silent
vcstPropertyDensityShow -silent abstraction
verdiVcstConstantReport -xmlFile /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb/.internal/verdi/constant.xml 
verdiVcstCheckFv -taskName FPV
vcstRunCovCmd -async gui_vcst_set_parameters -is_running true
verdiGetVcstCmdResult -xmlstr {<Command name="check_fv" status="1" />}
receiveFvProgress /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb/.internal/verdi/gridUsage.xml0
verdiVcstCheckFv -taskName FPV
vcstRunCovCmd -async gui_vcst_set_parameters -is_running false
verdiVcstOnPropSelectionChanged -strNum 1 -propList {tec_riscv_bus.sva_bus_inst.a1}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {tec_riscv_bus.sva_bus_inst.a1}
verdiSetStatusMsg -win $_Verdi_1 -2nd "Preparing FSDB..."
verdiGetVcstCmdResult -xmlstr {<Command name="view_trace" status="1" />}
verdiSetStatusMsg -win $_Verdi_1 -2nd "FSDB is ready, Waveform loading..."
sysWarnEnable -disable; set ::vcst::sysWarnEnable 0
verdiLayoutFreeze -off
set ::vcst::_curWaveVw [wvCreateWindow]
srcSetPreference -annotate on
verdiToolBar -win $_Verdi_1 -toolbar toolBarFormalVerification -moveToBf HB_BA_COMMAND_PANEL
set ::vcst::_fsdb $::vcst::_rtdbDir/.internal/formal/fpId1/trace_1.xml.replay.fsdb;
expPropVcstDataUpdated -initFSDB $::vcst::_fsdb;
::vcst::wvOpenFsdb $::vcst::_curWaveVw $::vcst::_fsdb
verdiVcstFsdbAppMode -fsdb $::vcst::_fsdb -AppMode FPV
set ::vcst::_propClass {source}
set ::vcst::_propLoc {assertionsBUS.sva:42}
set ::vcst::_propType {assert}
set ::vcst::_propExpr {pndng_after_push_prop}
set ::vcst::_traceType {property}
set ::vcst::_sva {tec_riscv_bus.sva_bus_inst.a1}
::vcst::setupSvaDebug 0 0 700

wvAddGroup -win $::vcst::_curWaveVw {Support-Signals};wvAddSignal -delim "." -win $::vcst::_curWaveVw -group { Support-Signals {tec_riscv_bus.sva_bus_inst.clk}  {tec_riscv_bus.sva_bus_inst.reset} {tec_riscv_bus.sva_bus_inst.D_push_spi} {tec_riscv_bus.sva_bus_inst.push_spi} {tec_riscv_bus.sva_bus_inst.pndng_spi} {tec_riscv_bus.clk} };
wvAddGroup -win $::vcst::_curWaveVw {Constant-Inputs};wvAddSignal -delim "." -win $::vcst::_curWaveVw -group { Constant-Inputs {tec_riscv_bus.push_mbc}  {tec_riscv_bus.pop_spi} {tec_riscv_bus.push_uart} {tec_riscv_bus.D_push_mbc} {tec_riscv_bus.D_push_uart} {tec_riscv_bus.D_} };wvCollapseGroup -win $::vcst::_curWaveVw {Constant-Inputs};
::vcst::addResetMarker 700
::vcst::showDebugViews -100 true true
wvGoToGroup -win $::vcst::_curWaveVw SOURCE-Property
wvSetPosition -win $::vcst::_curWaveVw {("Support-Signals" last)}
wvZoomAll -win $::vcst::_curWaveVw
verdiSetStatusMsg -win $_Verdi_1 -2nd "Trace is loaded"
sysWarnEnable -enable; set ::vcst::sysWarnEnable 1
verdiVcstOnPropSelectionChanged -strNum 1 -propList {tec_riscv_bus.sva_bus_inst.a1}
verdiVcstOnPropSelectionChanged -strNum 1 -propList {tec_riscv_bus.sva_bus_inst.a1}
reportFvGoalProgress -p {tec_riscv_bus.sva_bus_inst.a1}
receiveFvGoalProgress -tabId 1 -f /mnt/vol_NFS_Zener/WD_ESPEC/rmolina/evaristo_project/bus_vcf_2/bus_vcf/vcst_rtdb/.internal/verdi/depthVsTime.xml00 -t 0 -trigger 
