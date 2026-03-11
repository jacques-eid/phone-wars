class_name UIAttackPreviewState
extends LimboState


var ui_controller: UIController


func _setup() -> void:
	ui_controller = agent
	
	add_event_handler(ui_controller.CANCEL_CLICKED, _on_cancel_clicked)
	add_event_handler(ui_controller.ATTACK_CLICKED, _on_attack_clicked)


func _enter() -> void:
	ui_controller.team_display.animate_out()
	ui_controller.camera_pan_enabled.emit(false)
	ui_controller.game_hud.show_attack_preview_state()
	ui_controller.show_combat_dialog()


func _on_cancel_clicked() -> bool:
	ui_controller.combat_popup.animate_out()
	ui_controller.team_display.animate_in()
	ui_controller.camera_pan_enabled.emit(true)
	ui_controller.state_machine.dispatch(ui_controller.ATTACK_CANCELLED_SIGNAL)

	return true


func _on_attack_clicked() -> bool:
	ui_controller.action_running_state.clear_selections = true
	ui_controller.combat_popup.animate_out()
	ui_controller.state_machine.dispatch(ui_controller.ACTION_RUNNING_SIGNAL)
	ui_controller.handle_attack_async()

	return true
