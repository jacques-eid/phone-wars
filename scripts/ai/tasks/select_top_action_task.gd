extends BTAction


func _tick(_delta: float) -> Status:
	var ai_controller: AIController = agent as AIController
	var result: AIActionResult = get_top_result()
	blackboard.set_var("top_result", result)

	ai_controller.selected_unit = result.unit
	ai_controller.selected_unit.select()
	
	return SUCCESS


func get_top_result() -> AIActionResult:
	var results: Array[AIActionResult] = blackboard.get_var("results")
	results.sort_custom(func(a: AIActionResult, b: AIActionResult): return a.score > b.score)
	return results[0]