extends BTAction


func _tick(_delta: float) -> Status:
	var unit: Unit = blackboard.get_var("unit")

	var attack_result: AIActionResult = score_attack(unit)
	var capture_result: AIActionResult = score_capture(unit)
	var merge_result: AIActionResult = score_merge(unit)
	var move_result: AIActionResult = score_move(unit)

	var results: Array[AIActionResult] = blackboard.get_var("results")
	results.append(attack_result)
	results.append(capture_result)
	results.append(merge_result)
	results.append(move_result)
	blackboard.set_var("results", results)

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
		result.target_unit = select_best_unit_to_attack(best_targets)
		result.score = 100 + unit.type()
		return result

	result.target_unit = select_best_unit_to_attack(secondary_targets)
	result.score = 50 + unit.type()
	return result


func select_best_unit_to_attack(targets: Array[Unit]) -> Unit:
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


func score_capture(unit: Unit) -> AIActionResult:
	var ai_controller: AIController = agent as AIController
	var result: AIActionResult = AIActionResult.new()
	result.unit = unit
	result.type = AIActionType.Values.CAPTURE

	if not unit.can_capture():
		return result

	var buildings: Array[Building] = ai_controller.find_capturable_buildings(unit)
	if len(buildings) == 0:
		return result

	result.score = 80
	result.target_building = select_best_building_to_capture(unit, buildings)

	return result


func select_best_building_to_capture(unit: Unit, buildings: Array[Building]) -> Building:
	var best_building: Building
	var best_score: int = int(-INF)

	for building: Building in buildings:
		var score: int = building.type()

		# Prioritize enemy buildings
		if not building.team.neutral_team():
			score += 20

		# Keep capturing the same building
		if unit.capture_process != null and \
			unit.capture_process.building == building:
				score += 100

		if score > best_score:
			best_score = score
			best_building = building

	return best_building


func score_merge(unit: Unit) -> AIActionResult:
	var ai_controller: AIController = agent as AIController
	var result: AIActionResult = AIActionResult.new()
	result.unit = unit
	result.type = AIActionType.Values.MERGE
	
	var units: Array[Unit] = ai_controller.find_mergeable_units(unit)
	var array: Array = select_best_unit_to_merge(units)
	result.target_unit = array[0]
	result.score = array[1]

	return result


func select_best_unit_to_merge(units: Array[Unit]) -> Array:
	var best_target: Unit
	var best_score: int = int(-INF)
	for unit: Unit in units:
		var score: int = 30

		# Prefer units that are capturing a building
		if unit.capture_process != null:
			score += 5

		# Save low units first
		if unit.actual_health <= unit.max_health() / 5.0:
			score += 20

		if score > best_score:
			best_score = score
			best_target = unit

	return [best_target, best_score]


func score_move(unit: Unit) -> AIActionResult:
	var ai_controller: AIController = agent as AIController
	var result: AIActionResult = AIActionResult.new()
	result.unit = unit
	result.type = AIActionType.Values.MOVE
	result.score = 10
	# Target a random reachable cell for now
	var cells: Array[Vector2i] = ai_controller.units_manager.compute_reachable_cells(unit)
	result.target_cell = cells[randi() % len(cells)]

	return result
