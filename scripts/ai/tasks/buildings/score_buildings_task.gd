extends BTAction


var ai_controller: AIController


func _enter() -> void:
	ai_controller = agent as AIController


func _tick(_delta: float) -> Status:
	var building: Building = blackboard.get_var("building")
	var results: Array[AIScoreResult] = blackboard.get_var("results")

	var production_list: ProductionList = building.production_list
	for pe: ProductionEntry in production_list.entries:
		if not ai_controller.can_buy(pe):
			continue
		results.append(score_building_with_unit_profile(building, pe))

	if results.size() == 0:
		return FAILURE

	blackboard.set_var("results", results)
	return SUCCESS


func score_building_with_unit_profile(building: Building, production_entry: ProductionEntry) -> AIBuyResult:
	var result: AIBuyResult = AIBuyResult.new()
	result.building = building
	result.production_entry = production_entry
	result.focus_point = building.global_position
	result.score += unit_values(production_entry.unit_profile.type)
	result.score += context_bonus(building, production_entry.unit_profile.type)
	result.score += position_value(building)
	result.score -= danger_penalty(building)
	result.score -= cost_penalty(production_entry.unit_profile)
	result.score -= repetition_penalty(production_entry.unit_profile.type)

	return result


# Prioritize higher values units
func unit_values(unit_type: UnitType.Values) -> float:
	match unit_type:
		UnitType.Values.INFANTRY:
			return 50
		UnitType.Values.RECON:
			return 60
		UnitType.Values.ARTILLERY:
			return 70
		UnitType.Values.LIGHT_TANK:
			return 80

	return 0


func context_bonus(building: Building, unit_type: UnitType.Values) -> float:
	var score: float = 0.0

	if unit_type == UnitType.Values.INFANTRY:
		score = score_buildings_to_capture(building)


	if ai_controller.enemy_nearby(building.cell):
		if unit_type == UnitType.Values.LIGHT_TANK:
			score += 30
		if unit_type == UnitType.Values.ARTILLERY:
			score += 20

	if ai_controller.team.funds > 1000 and unit_type == UnitType.Values.LIGHT_TANK:
		score += 20

	return score


func score_buildings_to_capture(building: Building) -> float:
	var score: float = 0.0
	var infantry_count: int = ai_controller.get_unit_type_count(UnitType.Values.INFANTRY)
	var buildings_to_capture: Array[Building] = ai_controller.get_buildings_to_capture_in_range(building.cell)

	score += max(0, (buildings_to_capture.size() - infantry_count) * 20)

	return score


func position_value(building: Building) -> float:
	var score: float = 0.0

	var closest_enemy: Unit = ai_controller.find_closest_enemy(building.cell)
	var dist_enemy: float = closest_enemy.cell.distance_to(building.cell)

	# closer to enemy = more aggressive
	score += (10 - dist_enemy) * 5

	return score


# TODO: Add this when the whole combat system is rework to use a matrix
# instead of the units
func danger_penalty(_building: Building) -> float:
	return 0


# Add a small penaly for expensive units
func cost_penalty(unit_profile: UnitProfile) -> float:
	return unit_profile.cost / 100.0


func repetition_penalty(unit_type: UnitType.Values) -> float:
	var count: int = ai_controller.get_unit_type_count(unit_type)
	var factor: int

	match unit_type:
		UnitType.Values.INFANTRY, UnitType.Values.ARTILLERY, UnitType.Values.LIGHT_TANK:
			factor = 10
		UnitType.Values.RECON:
			factor = 25

	return count * factor