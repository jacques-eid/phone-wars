class_name UIIdleState
extends LimboState


var ui_controller: UIController


func _setup() -> void:
	ui_controller = agent

	add_event_handler(ui_controller.CELL_TAP, _on_cell_tap)
	add_event_handler(ui_controller.LONG_PRESS, _on_long_press)


func _enter() -> void:
	ui_controller.production_panel.hide()
	ui_controller.game_hud.show_idle_state(ui_controller.interactable_controller)
	ui_controller.clear_attackable.emit()

	if ui_controller.lock_controller:
		ui_controller.camera_pan_enabled.emit(false)


func _exit() -> void:
	ui_controller.game_hud.hide_idle_state()


func _on_cell_tap(cargo: Variant) -> bool:
	if not cargo is Vector2i:
		return true

	var cell: Vector2i = cargo as Vector2i

	var selection_result: SelectionResult.Values = ui_controller.active_controller.selection_attempt(cell)
	match selection_result:
		SelectionResult.Values.UNIT:
			ui_controller.state_machine.dispatch(ui_controller.UNIT_SELECTED_SIGNAL)
		SelectionResult.Values.BUILDING:
			ui_controller.state_machine.dispatch(ui_controller.BUILDING_SELECTED_SIGNAL)

	return true


func _on_long_press(cargo: Variant) -> bool:
	if not cargo is Vector2i:
		return true

	var cell: Vector2i = cargo as Vector2i
	ui_controller.handle_long_press(cell)
	return true
