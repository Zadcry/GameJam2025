extends Node

var cordura := 100
var scoped := false

var ui_cancel_events = []
func disable_ui_cancel():
	ui_cancel_events = InputMap.action_get_events("ui_cancel").duplicate()
	InputMap.action_erase_events("ui_cancel")
func enable_ui_cancel():
	InputMap.action_erase_events("ui_cancel")
	for event in ui_cancel_events:
		InputMap.action_add_event("ui_cancel", event)
