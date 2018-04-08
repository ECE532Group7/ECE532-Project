# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "COL_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ROW_BITS" -parent ${Page_0}


}

proc update_PARAM_VALUE.COL_BITS { PARAM_VALUE.COL_BITS } {
	# Procedure called to update COL_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COL_BITS { PARAM_VALUE.COL_BITS } {
	# Procedure called to validate COL_BITS
	return true
}

proc update_PARAM_VALUE.ROW_BITS { PARAM_VALUE.ROW_BITS } {
	# Procedure called to update ROW_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ROW_BITS { PARAM_VALUE.ROW_BITS } {
	# Procedure called to validate ROW_BITS
	return true
}


proc update_MODELPARAM_VALUE.ROW_BITS { MODELPARAM_VALUE.ROW_BITS PARAM_VALUE.ROW_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ROW_BITS}] ${MODELPARAM_VALUE.ROW_BITS}
}

proc update_MODELPARAM_VALUE.COL_BITS { MODELPARAM_VALUE.COL_BITS PARAM_VALUE.COL_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COL_BITS}] ${MODELPARAM_VALUE.COL_BITS}
}

