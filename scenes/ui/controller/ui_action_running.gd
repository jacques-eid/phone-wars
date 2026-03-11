class_name UIActionRunningState
extends LimboState


var ui_controller: UIController

var clear_selections: bool

func _setup() -> void:
	ui_controller = agent

	add_event_handler(ui_controller.LONG_PRESS_RELEASE, _on_long_press_release)


func _enter() -> void:
	ui_controller.game_hud.hide()
	ui_controller.team_display.animate_out()
	ui_controller.camera_pan_enabled.emit(false)
	
	if clear_selections:
		ui_controller.clear_movement_range.emit()
		ui_controller.clear_attackable.emit()
		ui_controller.clear_selected.emit()


func _exit() -> void:
	ui_controller.game_hud.show()
	ui_controller.team_display.animate_in()
	ui_controller.camera_pan_enabled.emit(true)
	ui_controller.clear_movement_range.emit()
	ui_controller.clear_attackable.emit()
	ui_controller.clear_selected.emit()
	ui_controller.info_popup.animate_out()
	ui_controller.combat_popup.animate_out()



func _on_long_press_release() -> bool:
	ui_controller.switch_to_previous_state()
	return false