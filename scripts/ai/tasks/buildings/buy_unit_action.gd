extends AsyncTask

func _run_async() -> void:
	var ai_controller: AIController = agent as AIController
	var top_result: AIBuyResult = blackboard.get_var("top_result")

	ai_controller.selected_building = top_result.building

	_run(ai_controller.buy_unit, top_result.production_entry)