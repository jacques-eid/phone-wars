extends BTAction


func _tick(_delta: float) -> Status:
	var result: AIScoreResult = get_top_result()
	blackboard.set_var("top_result", result)
	blackboard.set_var("focus_point", result.focus_point)

	return SUCCESS


func get_top_result() -> AIScoreResult:
	var results: Array[AIScoreResult] = blackboard.get_var("results")
	results.sort_custom(func(a: AIScoreResult, b: AIScoreResult): return a.score > b.score)
	return results[0]
