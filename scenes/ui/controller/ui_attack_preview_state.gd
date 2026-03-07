class_name UIAttackPreviewState
extends UIState


func _enter(_params: Dictionary = {}) -> void:
	ui_controller.game_hud.show_attack_preview_state()
	ui_controller.show_combat_dialog()


func _exit() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _on_cancel_clicked() -> void:
	ui_controller.combat_popup.animate_out()
	ui_controller.team_display.animate_in()
	ui_controller.camera_pan_enabled.emit(true)
	ui_controller.fsm.switch_to_previous_state()


func _on_attack_clicked() -> void:
	ui_controller.combat_popup.animate_out()
	ui_controller.game_hud.hide()
	await ui_controller.combat_orchestrator.execute(ui_controller.active_controller)
	ui_controller.game_hud.show()
	ui_controller.team_display.animate_in()
	ui_controller.camera_pan_enabled.emit(true)
	ui_controller.fsm.change_state(ui_controller.idle_state)
