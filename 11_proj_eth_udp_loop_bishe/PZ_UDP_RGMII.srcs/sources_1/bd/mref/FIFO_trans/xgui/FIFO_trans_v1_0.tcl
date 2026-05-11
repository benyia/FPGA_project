# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "SEND_TIMES" -parent ${Page_0}


}

proc update_PARAM_VALUE.SEND_TIMES { PARAM_VALUE.SEND_TIMES } {
	# Procedure called to update SEND_TIMES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SEND_TIMES { PARAM_VALUE.SEND_TIMES } {
	# Procedure called to validate SEND_TIMES
	return true
}


proc update_MODELPARAM_VALUE.SEND_TIMES { MODELPARAM_VALUE.SEND_TIMES PARAM_VALUE.SEND_TIMES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SEND_TIMES}] ${MODELPARAM_VALUE.SEND_TIMES}
}

