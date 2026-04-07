extends BTAction


func _tick(_delta: float) -> Status:
	var ai_controller: AIController = agent as AIController
	var top_result: AIBuyResult = blackboard.get_var("top_result")

	# Don't try to save
	if ai_controller.team.funds > 700:
		return SUCCESS

	if top_result.score > score_save():
		return SUCCESS

	return FAILURE


func score_save() -> float:
	var score: float = 0.0

	var ai_controller: AIController = agent as AIController
	var enemies: Array[Unit] = ai_controller.find_enemies()


	for enemy: Unit in enemies:
		if enemy.type() == UnitType.Values.ARTILLERY:
			score += 30

		if enemy.type() == UnitType.Values.LIGHT_TANK:
			score += 40

	return score