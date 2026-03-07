class_name UIMovedState
extends UIState

func _enter(_params: Dictionary = {}) -> void:
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


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _on_cell_tap(cell: Vector2i) -> void:
	if ui_controller.can_move_to_cell(cell):
		ui_controller.handle_unit_movement(cell)
		return

	if ui_controller.active_controller.merge_available():
		return
		
	if ui_controller.can_attack_cell(cell):
		ui_controller.handle_unit_attack(cell)

	
func _on_cancel_clicked() -> void:
	ui_controller.active_controller.cancel_unit_movement()
	ui_controller.fsm.switch_to_previous_state()


func _on_long_press(cell: Vector2i) -> void:
	ui_controller.handle_long_press(cell)


func _on_long_press_release(_cell: Vector2i) -> void:
	ui_controller.handle_long_press_release()
	ui_controller.show_attack_indicator()


func show_capture_button() -> bool:
	return ui_controller.active_controller.capture_available()


func show_merge_button() -> bool:
	return ui_controller.active_controller.merge_available()