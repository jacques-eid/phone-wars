extends AsyncTask


var ai_controller: AIController


func _enter() -> void:
	ai_controller = agent as AIController


func _run_async() -> void:
	var top_result: AIActionResult = blackboard.get_var("top_result")

	ai_controller.select_unit(top_result.unit)
	

	print('executing: ', top_result.type)

	match top_result.type:
		AIActionType.Values.ATTACK:
			_run(handle_attack, top_result)
		AIActionType.Values.CAPTURE:
			_run(handle_capture, top_result)
		AIActionType.Values.MERGE:
			_run(handle_merge, top_result)
		AIActionType.Values.MOVE:
			_run(handle_move, top_result)


func handle_attack(top_result: AIActionResult) -> void:
	ai_controller.target_unit = top_result.target_unit

	if ai_controller.can_attack_without_moving(top_result.target_unit.cell):
		await ai_controller.perform_combat()
		return

	var target_cell: Vector2i = ai_controller.choose_best_attack_position(top_result.target_unit.cell)
	ai_controller.move_command = await ai_controller.move_unit_to_cell(target_cell)
	await ai_controller.perform_combat()


func handle_capture(top_result: AIActionResult) -> void:
	var target_cell: Vector2i = top_result.target_building.cell

	if top_result.unit.cell == target_cell:
		await ai_controller.capture_building()
		return

	ai_controller.move_command = await ai_controller.move_unit_to_cell(target_cell)
	await ai_controller.capture_building()


func handle_merge(top_result: AIActionResult) -> void:
	var target_cell: Vector2i = top_result.target_unit.cell

	if top_result.unit.cell == target_cell:
		await ai_controller.merge_units()
		return

	ai_controller.move_command = await ai_controller.move_unit_to_cell(target_cell)
	await ai_controller.merge_units()


func handle_move(top_result: AIActionResult) -> void:
	ai_controller.move_command = await ai_controller.move_unit_to_cell(top_result.target_cell)
	await ai_controller.get_tree().process_frame
	ai_controller.exhaust_unit()
