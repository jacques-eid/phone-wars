class_name AIController
extends TeamController

var behavior_tree: BehaviorTree = load("res://resources/ai/ai_bt.tres") 

var bt_player: BTPlayer
var bt_blackboard: Blackboard

var done: bool
var move_command: MoveUnitCommand

func _setup() -> void:
	bt_player = BTPlayer.new()
	bt_player.active = false
	add_child(bt_player)
	bt_player.owner = self

	bt_blackboard = Blackboard.new()

	var instance: BTInstance = behavior_tree.instantiate(self, bt_blackboard, bt_player)
	bt_player.set_bt_instance(instance)


func _play_turn() -> void:
	await super._play_turn()

	bt_player.active = true

	while not done:
		await bt_player.behavior_tree_finished

	_end_turn()


func _end_turn() -> void:
	super._end_turn()

	bt_player.active = false
	bt_blackboard.clear()
	done = false


func _confirm_movement() -> void:
	if move_command == null:
		return

	units_manager.move_unit(selected_unit, move_command.start_cell, move_command.target_cell)
	move_command = null

	
func get_possible_targets(unit: Unit) -> Array[Unit]:
	return units_manager.get_units_in_attack_range_with_movement(unit)


func get_units_to_play() -> Array[Unit]:
	var units: Array[Unit] = units_manager.get_friendly_units(team)

	return units.filter(func(unit: Unit): return not unit.exhausted)


func get_unit_type_count(unit_type: UnitType.Values) -> int:
	var units: Array[Unit] = units_manager.get_friendly_units(team)

	return units.filter(func(unit: Unit): return unit.type() == unit_type).size()


# Returns an array of owned buildings that can buy units
func get_buildings_to_buy() -> Array[Building]:
	var buildings: Array[Building] = buildings_manager.get_friendly_buildings(team)
	var results: Array[Building]

	for building: Building in buildings:
		if units_manager.get_unit_at(building.cell) == null and \
			building.can_buy():
			results.append(building)

	return results


# Returns an array of all the buildings left to capture on the map
func get_buildings_to_capture() -> Array[Building]:
	return buildings_manager.get_enemy_buildings(team)


func get_buildings_to_capture_in_range(cell: Vector2i) -> Array[Building]:
	var buildings: Array[Building]

	for building: Building in get_buildings_to_capture():
		if building.cell.distance_to(cell) <= 5:
			buildings.append(building)

	return buildings


func cell_in_enemy_attack_range(cell: Vector2i) -> bool:
	var enemy_units: Array[Unit] = units_manager.get_enemy_units(team)

	for unit: Unit in enemy_units:
		var cells_in_attack_range: Array[Vector2i] = units_manager.get_cells_in_attack_range(unit)
		if cell in cells_in_attack_range:
			return true

	return false


# Returns true if an enemy unit is at less than 5 cells of the cell
func enemy_nearby(cell: Vector2i) -> bool:
	var enemy_units: Array[Unit] = units_manager.get_enemy_units(team)

	for unit: Unit in enemy_units:
		if unit.cell.distance_to(cell) <= 5:
			return true
		
	return false


func can_attack_from(unit: Unit, cell: Vector2i) -> bool:
	var cell_pos: Vector2i = unit.cell

	unit.cell = cell
	var units: Array[Unit] = units_manager.get_units_in_attack_range_with_movement(unit)
	unit.cell = cell_pos

	return len(units) >= 0


func get_support_bonus(unit: Unit, cell: Vector2i, target_cell: Vector2i) -> float:
	var bonus: float = 0
	for ally: Unit in units_manager.get_friendly_units(team):
		if ally == unit:
			continue

		if target_cell in units_manager.get_cells_in_attack_range(ally):
			bonus += 30

		if ally.cell.distance_to(cell) <= 2.0:
			bonus += 20

	return bonus


# estimate the damage the unit can take if it moves on this cell
func estimate_damage(unit: Unit, cell: Vector2i) -> float:
	var total_damage: float = 0

	for enemy: Unit in units_manager.get_enemy_units(unit.team):
		if cell in units_manager.get_cells_in_attack_range(enemy):
			var terrain_defense: float = get_terrain_defense(cell)
			total_damage += CombatManager.compute_damage(enemy, enemy.actual_health, unit, terrain_defense)

	return total_damage


# Returns an array of building that the unit can potentially capture during
# this turn
func find_capturable_buildings(unit: Unit) -> Array[Building]:
	var reachable_cells: Array[Vector2i] = units_manager.compute_reachable_cells(unit)
	reachable_cells.append(unit.cell)
	var buildings: Array[Building]

	for cell: Vector2i in reachable_cells:
		var building: Building = buildings_manager.get_building_at(cell)
		if building != null and not building.team.is_same_team(unit.team):
			buildings.append(building)

	return buildings


# Returns an array of unit that the unit can potentially merge with during
# this turn
func find_mergeable_units(unit: Unit) -> Array[Unit]:
	var reachable_cells: Array[Vector2i] = units_manager.compute_reachable_cells(unit)
	var units: Array[Unit]

	for cell: Vector2i in reachable_cells:
		var target: Unit = units_manager.get_unit_at(cell)
		if target != null and unit.can_merge_with_unit(target):
			units.append(target)

	return units


# Returns all the enemies
func find_enemies() -> Array[Unit]:
	return units_manager.get_enemy_units(team)


# Returns the closest enemy unit not in range during this turn
func find_closest_enemy(cell: Vector2i) -> Unit:
	var best_enemy: Unit
	var best_dist: float = INF

	for enemy: Unit in units_manager.get_enemy_units(team):
		var dist: float = cell.distance_to(enemy.cell)

		if dist < best_dist:
			best_dist = dist
			best_enemy = enemy

	return best_enemy


# Returns the closest capturable building not in range during this turn
func find_closest_capturable_building(unit: Unit) -> Building:
	var best_building: Building
	var best_dist: float = INF

	if not unit.can_capture():
		return null

	for building: Building in buildings_manager.get_buildings():
		if not unit.can_capture_building(building):
			continue

		var dist: float = unit.cell.distance_to(building.cell)

		if dist < best_dist:
			best_dist = dist
			best_building = building

	return best_building


# Returns the closest friendly building
func find_closest_friendly_building(unit: Unit) -> Building:
	var best_building: Building
	var best_dist: float = INF

	for building: Building in buildings_manager.get_friendly_buildings(team):
		print('building: ', building)
		var dist: float = unit.cell.distance_to(building.cell)

		if dist < best_dist:
			best_dist = dist
			best_building = building

	return best_building