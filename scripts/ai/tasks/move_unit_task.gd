extends AsyncTask


func _run_async() -> void:
	var ai_controller: AIController = agent as AIController
	var target_cell: Vector2i = get_random_target_cell(ai_controller)
	print('selected_unit.pos: ', ai_controller.selected_unit.cell_pos)
	_run(ai_controller.move_unit_to_cell, target_cell)


func get_random_target_cell(ai_controller: AIController) -> Vector2i:
	var unit_context: UnitContext = UnitContext.create_unit_context(ai_controller.selected_unit)
	var cells: Array[Vector2i] = ai_controller.units_manager.get_cells_in_direct_attack_range(unit_context)

	return cells[randi() % cells.size()]