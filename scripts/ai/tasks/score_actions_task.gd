extends BTAction


func _tick(_delta: float) -> Status:
	var unit: Unit = blackboard.get_var("unit")

	var result: AIActionResult = score_attack(unit)
	var results: Array[AIActionResult] = blackboard.get_var("results")
	results.append(result)
	blackboard.set_var("results", results)

	## TODO: compute other actions score

	return SUCCESS



func score_attack(unit: Unit) -> AIActionResult:
	var ai_controller: AIController = agent as AIController
	var result: AIActionResult = AIActionResult.new()
	result.unit = unit
	result.type = AIActionType.Values.ATTACK

	var targets: Array[Unit] = ai_controller.get_possible_targets(unit)
	if len(targets) == 0:
		result.score = 0
		return result

	var best_targets: Array[Unit]
	var secondary_targets: Array[Unit]

	for target: Unit in targets:
		var terrain_defense: float = ai_controller.get_terrain_defense(target)
		var combat_result: CombatResult = CombatManager.resolve_combat(unit, target, terrain_defense)
		if combat_result.defender_killed:
			best_targets.append(target)

		# TODO: when counter attack, check if attacking is worth it
		secondary_targets.append(target)

	if len(best_targets) != 0:
		result.target_unit = select_best_targets(best_targets)
		result.score = 100 + unit.type()
		return result

	result.target_unit = select_best_targets(secondary_targets)
	result.score = 50 + unit.type()
	return result



func select_best_targets(targets: Array[Unit]) -> Unit:
	var best_target: Unit
	var best_score: int = int(-INF)
	for target: Unit in targets:
		var score: int = target.type()

		# Prevent capture of buildings
		if target.capture_process != null and target.capture_process.can_finish_next_turn(target):
			score += 50

		if score > best_score:
			best_score = score
			best_target = target

	return best_target
