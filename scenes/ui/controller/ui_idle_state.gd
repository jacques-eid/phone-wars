class_name UIIdleState
extends LimboState


var ui_controller: UIController


func _setup() -> void:
	ui_controller = agent

	add_event_handler(ui_controller.CELL_TAP, _on_cell_tap)
	add_event_handler(ui_controller.LONG_PRESS, _on_long_press)
	add_event_handler(ui_controller.LONG_PRESS_RELEASE, _on_long_press_release)


func _enter() -> void:
	ui_controller.visible = ui_controller.is_playable
	ui_controller.production_panel.hide()
	ui_controller.game_hud.show_idle_state()


func _exit() -> void:
	ui_controller.game_hud.hide_idle_state()


func _on_cell_tap(cargo: Variant) -> bool:
	if not cargo is Vector2i:
		return true

	var cell: Vector2i = cargo as Vector2i

	var selection_result: SelectionResult = ui_controller.active_controller.selection_attempt(cell)
	if selection_result.value == SelectionResult.Values.UNIT:
		ui_controller.state_machine.dispatch(ui_controller.UNIT_SELECTED_SIGNAL)
	elif selection_result.value == SelectionResult.Values.BUILDING:
		ui_controller.state_machine.change_state(ui_controller.BUILDING_SELECTED_SIGNAL)

	return true


func _on_long_press(cargo: Variant) -> bool:
	if not cargo is Vector2i:
		return true

	var cell: Vector2i = cargo as Vector2i
	ui_controller.handle_long_press(cell)
	return true


func _on_long_press_release() -> bool:
	ui_controller.game_hud.show()
	ui_controller.handle_long_press_release()
	return true
