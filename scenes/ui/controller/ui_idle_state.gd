class_name UIIdleState
extends UIState


func _enter(_params: Dictionary = {}) -> void:
	ui_controller.visible = ui_controller.is_playable
	ui_controller.production_panel.hide()
	ui_controller.game_hud.show_idle_state()


func _exit() -> void:
	ui_controller.game_hud.hide_idle_state()


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _on_cell_tap(cell: Vector2i) -> void:
	var selection_result: SelectionResult = ui_controller.active_controller.selection_attempt(cell)
	if selection_result.value == SelectionResult.Values.UNIT:
		ui_controller.fsm.change_state(ui_controller.unit_selected_state)
	elif selection_result.value == SelectionResult.Values.BUILDING:
		ui_controller.fsm.change_state(ui_controller.building_selected_state)


func _on_long_press(cell: Vector2i) -> void:
	ui_controller.handle_long_press(cell)


func _on_long_press_release(_cell: Vector2i) -> void:
	ui_controller.game_hud.show()
	ui_controller.handle_long_press_release()

	
func _on_cancel_clicked() -> void:
	pass
