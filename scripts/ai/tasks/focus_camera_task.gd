extends AsyncTask



func _run_async() -> void:
	var ai_controller: AIController = agent as AIController

	var focus_point: Vector2 = ai_controller.selected_unit.global_position
	_run(ai_controller.focus, focus_point)
