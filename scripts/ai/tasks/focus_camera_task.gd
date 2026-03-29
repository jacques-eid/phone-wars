extends AsyncTask



func _run_async() -> void:
	var ai_controller: AIController = agent as AIController

	var focus_point: Vector2 = blackboard.get_var("focus_point")
	_run(ai_controller.focus, focus_point)
