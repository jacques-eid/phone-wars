extends BTAction


func _tick(_delta: float) -> Status:
	var ai_controller: AIController = agent as AIController
	var units: Array[Unit] = ai_controller.get_units_to_play()
	if len(units) == 0:
		ai_controller.done = true
		return FAILURE

	blackboard.clear()
	blackboard.set_var("units", units)
	var results: Array[AIActionResult] = []
	blackboard.set_var("results", results)

	return SUCCESS