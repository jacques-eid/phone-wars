extends BTAction


func _tick(_delta: float) -> Status:
	var results: Array[AIScoreResult] = blackboard.get_var("results")
	var result: AIScoreResult = get_top_result(results)
	blackboard.set_var("top_result", result)
	blackboard.set_var("focus_point", result.focus_point)

	var ai_log: AIDebugLog = AIDebugLog.new()
	ai_log.top_result = result
	ai_log.results = results

	DebugManager.record_ai_decision(ai_log)

	return SUCCESS


func get_top_result(results: Array[AIScoreResult]) -> AIScoreResult:
	results.sort_custom(func(a: AIScoreResult, b: AIScoreResult): return a.score > b.score)
	return results[0]
