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

	var cell: Vector2i = cargo as Vector2i
	if ui_controller.can_move_to_cell(cell):
		ui_controller.handle_unit_movement(cell)
		return true

	if ui_controller.active_controller.merge_available():
		return true

	if ui_controller.can_attack_cell(cell):
		ui_controller.handle_unit_attack(cell)
		
	return true


func _on_cancel_clicked() -> bool:
	ui_controller.active_controller.deselect_unit()
	ui_controller.state_machine.dispatch(ui_controller.UNIT_DESELECTED_SIGNAL)
	return true


func _on_long_press(cargo: Variant) -> bool:
	if not cargo is Vector2i:
		return true

	var cell: Vector2i = cargo as Vector2i
	ui_controller.handle_long_press(cell)
	return true


func _on_long_press_release() -> bool:
	ui_controller.handle_long_press_release()
	ui_controller.show_attack_indicator()
	return true


func show_capture_button() -> bool:
	return ui_controller.active_controller.capture_available()


func show_merge_button() -> bool:
	return ui_controller.active_controller.merge_available()