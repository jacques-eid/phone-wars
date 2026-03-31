extends BTAction


var ai_controller: AIController


func _enter() -> void:
	ai_controller = agent as AIController


func _tick(_delta: float) -> Status:
	var unit: Unit = blackboard.get_var("unit")

	var attack_result: AIActionResult = score_attack(unit)
	var capture_result: AIActionResult = score_capture(unit)
	var merge_result: AIActionResult = score_merge(unit)
	var move_result: AIActionResult = score_move(unit)

	var results: Array[AIScoreResult] = blackboard.get_var("results")
	results.append(attack_result)
	results.append(capture_result)
	results.append(merge_result)
	results.append(move_result)
	blackboard.set_var("results", results)

	return SUCCESS

# Compute the score to attack an enemy unit:
# base score : 50
# enemy unit dies: +50
# enemy type: +type()
func score_attack(unit: Unit) -> AIActionResult:
	var result: AIActionResult = AIActionResult.new()
	result.unit = unit
	result.focus_point = unit.global_position
	result.type = AIActionType.Values.ATTACK

	var targets: Array[Unit] = ai_controller.get_possible_targets(unit)
	if len(targets) == 0:
		result.score = 0
		return result

	var best_targets: Array[Unit]
	var secondary_targets: Array[Unit]

	for target: Unit in targets:
		var defender_terrain_defense: float = ai_controller.get_terrain_defense(target.cell)
		var attacker_terrain_defense: float = ai_controller.get_terrain_defense(unit.cell)
		var combat_result: CombatResult = CombatManager.resolve_combat(
			unit,
			target,
			defender_terrain_defense,
			attacker_terrain_defense)

		if combat_result.defender_killed:
			best_targets.append(target)

		if combat_result.damage > combat_result.counter_damage:
			secondary_targets.append(target)

	if len(best_targets) != 0:
		result.target_unit = select_best_unit_to_attack(best_targets)
		result.score = 100 + unit.type()
		return result

	if len(secondary_targets) == 0:
		return result
		
	result.target_unit = select_best_unit_to_attack(secondary_targets)
	result.score = 50 + unit.type()
	return result


# Select the unit to attack: focus first the unit capturing buildings
# that can finish next turn.
# Then target valuable enemies
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


# Compute the score to capture a building:
# base score : 80
func score_capture(unit: Unit) -> AIActionResult:
	var result: AIActionResult = AIActionResult.new()
	result.unit = unit
	result.focus_point = unit.global_position
	result.type = AIActionType.Values.CAPTURE

	if not unit.can_capture():
		return result

	var buildings: Array[Building] = ai_controller.find_capturable_buildings(unit)
	if len(buildings) == 0:
		return result

	result.score = 80
	result.target_building = select_best_building_to_capture(unit, buildings)

	return result


# Compute the score to select which building to capture:
# base score : 0
# non neutral buildings: +20
# already capturing a building: +100
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


# Compute the score to merge a unit:
# base score : 30
# target is capturing a building: +5
# target is low health: +20
func score_merge(unit: Unit) -> AIActionResult:
	var result: AIActionResult = AIActionResult.new()
	result.unit = unit
	result.focus_point = unit.global_position
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
		if unit.is_low_health():
			score += 20

		if score > best_score:
			best_score = score
			best_target = unit

	return [best_target, best_score]


# Compute the score to select which building to capture:
# base score : 0 
func score_move(unit: Unit) -> AIActionResult:
	var result: AIActionResult = AIActionResult.new()
	result.unit = unit
	result.focus_point = unit.global_position
	result.type = AIActionType.Values.MOVE
	
	var building: Building = ai_controller.find_closest_capturable_building(unit)
	if building != null:
		result.score = score_move_towards_building(unit, building)
		result.target_cell = select_best_cell_to_capture(unit, building.cell)
	
	var score: int = 0
	var enemy: Unit = ai_controller.find_closest_enemy(unit.cell)
	if enemy != null:
		score = score_move_towards_enemy(unit, enemy)
		if score > result.score:
			result.score = score
			result.target_cell = select_best_cell_to_attack(unit, enemy.cell)

	score = score_retreat(unit)
	if score > result.score:
		result.score = score
		result.target_cell = select_best_cell_to_retreat(unit)


	return result


# Compute the score to decide if the unit should move towards the building:
# base score : 40
# distance to target: -value
# target cell in enemy range: -20
func score_move_towards_building(unit: Unit, building: Building) -> int:
	var score: int = 40
	score -= int(unit.cell.distance_to(building.cell))

	if ai_controller.cell_in_enemy_attack_range(building.cell):
		score -= 20
	
	return score


# Compute the score to decide if the unit should move towards the enemy:
# base score : 25
# distance to target: -value
func score_move_towards_enemy(unit: Unit, target: Unit) -> int:
	var score: int = 25
	score -= int(unit.cell.distance_to(target.cell))

	return score
	

# Compute the score to decide if the unit should retreat:
# base score : 0
# low health: +40
# range and in enemy attack range: +30
func score_retreat(unit: Unit) -> int:
	var score: int = 0

	score += int(unit.max_health() - unit.actual_health) * 5

	var building: Building = ai_controller.find_closest_friendly_building(unit)
	var reachable_cells: Array[Vector2i] = ai_controller.units_manager.compute_reachable_cells(unit)
	if building.cell in reachable_cells:
		score += 10

	if unit.is_range() and ai_controller.cell_in_enemy_attack_range(unit.cell):
		score += 20 

	return score


func select_best_cell_to_capture(unit: Unit, target_cell: Vector2i) -> Vector2i:
	var best_cell: Vector2i
	var best_score: float = -INF

	var reachable_cells: Array[Vector2i] = ai_controller.units_manager.compute_reachable_cells(unit)

	for cell: Vector2i in reachable_cells:
		var score: float = 0

		score -= cell.distance_to(target_cell) * 10
		
		score += ai_controller.get_terrain_defense(cell)

		if ai_controller.cell_in_enemy_attack_range(cell):
			score -= 40

		if score > best_score:
			best_score = score
			best_cell = cell

	return best_cell


func select_best_cell_to_attack(unit: Unit, target_cell: Vector2i) -> Vector2i:
	var best_cell: Vector2i
	var best_score: float = -INF

	var reachable_cells: Array[Vector2i] = ai_controller.units_manager.compute_reachable_cells(unit)

	for cell: Vector2i in reachable_cells:
		var score: float = 0

		score -= cell.distance_to(target_cell) * 10
		
		score += ai_controller.get_terrain_defense(cell)

		if ai_controller.can_attack_from(unit, cell):
			score += 30

		if ai_controller.cell_in_enemy_attack_range(cell):
			score -= 40

		score += ai_controller.get_support_bonus(unit, cell, target_cell)

		if score > best_score:
			best_score = score
			best_cell = cell

	return best_cell


func select_best_cell_to_retreat(unit: Unit) -> Vector2i:
	var best_cell: Vector2i
	var best_score: float = -INF

	var closest_friendly_building: Building = ai_controller.find_closest_friendly_building(unit)
	var reachable_cells: Array[Vector2i] = ai_controller.units_manager.compute_reachable_cells(unit)

	for cell: Vector2i in reachable_cells:
		var score: float = 0

		var total_damage: float = ai_controller.estimate_damage(unit, cell)
		score -= total_damage * 10
	
		# TODO: add avoidance to most dangerouse enemies

		if total_damage < unit.actual_health:
			score += 30

		score += 50 / (closest_friendly_building.cell.distance_to(cell) + 1)

		score += ai_controller.get_terrain_defense(cell) * 10

		if score > best_score:
			best_score = score
			best_cell = cell

	return best_cell
