class_name UIUnitSelectedState
extends LimboState


var ui_controller: UIController


func _setup() -> void:
	ui_controller = agent

	add_event_handler(ui_controller.CELL_TAP, _on_cell_tap)
	add_event_handler(ui_controller.LONG_PRESS, _on_long_press)
	add_event_handler(ui_controller.LONG_PRESS_RELEASE, _on_long_press_release)
	add_event_handler(ui_controller.CANCEL_CLICKED, _on_cancel_clicked)


func _enter() -> void:
	ui_controller.visible = true
	ui_controller.game_hud.show_moved_state(
		show_capture_button(),
		show_merge_button())
	
	ui_controller.show_attack_indicator()
	ui_controller.show_movement_indicator()
	ui_controller.show_selection_indicator()


func _exit() -> void:
	ui_controller.clear_attackable.emit()
	ui_controller.clear_movement_range.emit()
	ui_controller.clear_selected.emit()


func _on_cell_tap(cargo: Variant) -> bool:
	if not cargo is Vector2i:
		return true
		
	ui_controller.action_running_state.clear_selections = true
	ui_controller.state_machine.dispatch(ui_controller.ACTION_RUNNING_SIGNAL)

	var cell: Vector2i = cargo as Vector2i
	ui_controller.handle_cell_tap_async(cell)
	return true


func _on_cancel_clicked() -> bool:
	var result: CancelResult.Values = ui_controller.active_controller.handle_cancel_on_movement()
	match result:
		CancelResult.Values.NONE:
			ui_controller.show_attack_indicator()
			ui_controller.show_movement_indicator()
			ui_controller.show_selection_indicator()
		CancelResult.Values.DESELECT:
			ui_controller.state_machine.dispatch(ui_controller.RESET_SIGNAL)
	
	return true


func _on_long_press(cargo: Variant) -> bool:
	if not cargo is Vector2i:
		return true

	var cell: Vector2i = cargo as Vector2i
	ui_controller.handle_long_press(cell)
	return true


func _on_long_press_release() -> bool:
	ui_controller.show_attack_indicator()
	return true


func show_capture_button() -> bool:
	return ui_controller.active_controller.capture_available()


func show_merge_button() -> bool:
	return ui_controller.active_controller.merge_available()
