class_name UnitsManager
extends Node

var grid: Grid
var units: Dictionary = {} # Vector2i -> Unit

func setup(p_grid: Grid) -> void:
	grid = p_grid
	init_units()


func init_units() -> void:
	for unit in get_children():
		if unit is Unit:
			var cell_pos: Vector2i = Vector2i(floor(unit.position / Vector2(Const.CELL_SIZE)))
			init_unit(unit, cell_pos)


func init_unit(unit: Unit, cell_pos: Vector2i) -> void:
	units[cell_pos] = unit
	unit.cell = cell_pos
	unit.position = Vector2(cell_pos) * Vector2(Const.CELL_SIZE) + Const.CELL_SIZE*0.5
	unit.unit_killed.connect(_on_unit_killed)
	unit.setup()


func _on_unit_killed(unit: Unit) -> void:
	remove_unit(unit)
	

func remove_unit(unit: Unit) -> void:
	print("removing unit %s at %s" % [unit.debug_name, unit.cell])
	units.erase(unit.cell)
	unit.queue_free()


func add_unit(entry: ProductionEntry, cell_pos: Vector2i, team: Team) -> void:
	var unit: Unit = entry.unit_scene.instantiate() as Unit
	add_child(unit)
	unit.set_team(team)
	init_unit(unit, cell_pos)
	unit.exhaust()


func get_units_with_filter(callable: Callable) -> Array[Unit]:
	var res: Array[Unit]
	var arr = units.values().filter(func(unit: Unit): return callable.call(unit))
	res.assign(arr)
	return res


func get_friendly_units(team: Team) -> Array[Unit]:
	return get_units_with_filter(func(unit: Unit): return unit.team.is_same_team(team))


func get_enemy_units(team: Team) -> Array[Unit]:
	return get_units_with_filter(func(unit: Unit): return not unit.team.is_same_team(team))


func get_grid_path(unit: Unit, start_cell: Vector2i, end_cell: Vector2i) -> Pathfinding.Path:
	return Pathfinding.find_path(grid, unit, start_cell, end_cell)


func get_world_path(unit: Unit, start_cell: Vector2i, end_cell: Vector2i) -> Pathfinding.Path:
	var path: Pathfinding.Path = get_grid_path(unit, start_cell, end_cell)
	var world_path: Array[Vector2] = []
	for cell in path.points:
		world_path.append(grid.get_world_position_from_cell(cell))
	
	path.world_points = world_path
	return path


func compute_reachable_cells(unit: Unit) -> Array[Vector2i]:
	return grid.get_reachable_cells(unit)


func get_unit_at(cell_position: Vector2i) -> Unit:
	return units.get(cell_position, null) as Unit


func get_units_positions(p_units: Array[Unit]) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for unit in p_units:
		cells.append(unit.cell)

	return cells


func has_unit(unit: Unit) -> bool:
	return units.get(unit.cell, null) != null


func compute_unit_path(unit: Unit, target_cell: Vector2i) -> Pathfinding.Path:
	var previous_cell: Vector2i = Vector2i(unit.global_position / Vector2(Const.CELL_SIZE))
	return get_world_path(unit, previous_cell, target_cell)


func move_unit(unit: Unit, start_cell: Vector2i, target_cell: Vector2i) -> void:
	units.erase(start_cell)
	units[target_cell] = unit


func reset_units(team: Team) -> void:
	for unit: Unit in get_friendly_units(team):
		unit.ready_to_move()


func merge_units(main_unit: Unit, merged_unit: Unit) -> int:
	var total_hp: int = int(merged_unit.actual_health + main_unit.actual_health)
	var max_hp: int = main_unit.max_health()

	var excess: int = max(0, total_hp - max_hp)
	main_unit.gain_health(merged_unit.actual_health)

	var money_gain: int = int((float(excess) / max_hp) * main_unit.cost())
	if merged_unit.capture_process != null:
		main_unit.capture_process = CaptureProcess.load_from_capture_process(merged_unit.capture_process, main_unit)
	
	remove_unit(merged_unit)

	return money_gain


func heal_unit(unit: Unit, team: Team, healing_value: int) -> HealResult:
	var heal_result: HealResult = HealResult.new()
	heal_result.unit = unit
	heal_result.team = team

	var missing_hp: int = int(unit.max_health() - unit.actual_health)
	var healed_hp: int = min(healing_value, missing_hp)
	var cost_per_hp: float = unit.cost() * 0.1

	var affordable_hp: int = int(team.funds / cost_per_hp)
	heal_result.healed_hp = min(healed_hp, affordable_hp)

	if heal_result.healed_hp <= 0:
		return heal_result

	heal_result.cost = int(heal_result.healed_hp * cost_per_hp)

	return heal_result


# Returns all the cells that are directly attackable by the unit
# without moving
func get_cells_in_direct_attack_range(unit_context: UnitContext) -> Array[Vector2i]:
	return grid.get_cells_in_manhattan_range(
		unit_context.grid_pos,
		unit_context.min_range,
		unit_context.max_range)


# Returns the units that are in direct attack range: without moving
func get_units_in_direct_attack_range(unit_context: UnitContext) -> Array[Unit]:
	var attack_positions: Array[Vector2i] = get_cells_in_direct_attack_range(unit_context)
	return filter_attackable_units(unit_context, attack_positions)


func filter_attackable_units(unit_context: UnitContext, cells: Array[Vector2i]) -> Array[Unit]:
	var filtered_units: Array[Unit] = []
	
	for unit: Unit in units.values():
		if (unit.cell in cells and 
			unit.cell != unit_context.grid_pos and
			not unit_context.team.is_same_team(unit.team)):
				filtered_units.append(unit)

	return filtered_units


# Returns true if the unit can attack the cell without moving
func can_attack_cell_without_moving(unit_context: UnitContext, cell: Vector2i) -> bool:
	var targets: Array[Unit] = get_units_in_direct_attack_range(unit_context)

	for unit in targets:
		if unit.cell == cell:
			return true

	return false


# Get all the cells that a unit can attack withing it's attack range
# with movement taken into account
func get_cells_in_attack_range(unit: Unit) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var reachable_cells: Array[Vector2i] = grid.get_reachable_cells(unit)
	var unit_context: UnitContext = UnitContext.create_unit_context(unit)
	cells.assign(merge_unique(cells, get_cells_in_direct_attack_range(unit_context)))

	if not unit.can_attack_after_movement():
		if unit.movement_points != unit.max_movement_points():
			return []
		return get_cells_in_direct_attack_range(unit_context)

	for cell in reachable_cells:
		# filter out the cells where a unit is already on: it means the unit
		# can move there for merging reasons
		if get_unit_at(cell) != null:
			continue
		unit_context.grid_pos = cell
		cells.assign(merge_unique(cells, get_cells_in_direct_attack_range(unit_context)))
		

	return cells


# Retursn all the units in attack range: movement included
func get_units_in_attack_range_with_movement(unit: Unit) -> Array[Unit]:
	var target_cells: Array[Vector2i] = get_cells_in_attack_range(unit)
	return filter_attackable_units(UnitContext.create_unit_context(unit), target_cells)
	

func merge_unique(a: Array, b: Array) -> Array:
	var dict := {}
	for v in a:
		dict[v] = true
	for v in b:
		dict[v] = true
	return dict.keys()


func choose_best_attack_position(unit: Unit, target_cell: Vector2i, buildings_manager: BuildingsManager) -> Vector2i:
	var candidates: Array[Vector2i] = get_attack_positions_after_movement(unit, target_cell)

	var best_cell: Vector2i
	var best_score: int = int(-INF)

	for cell: Vector2i in candidates:
		var score: int = score_cell_for_attack(unit, cell, buildings_manager)

		if score > best_score:
			best_score = score
			best_cell = cell

	return best_cell


func get_attack_positions_after_movement(unit: Unit, target_cell: Vector2i) -> Array[Vector2i]:
	if not unit.can_attack_after_movement() and unit.movement_points != unit.max_movement_points():
		return []
		
	var unit_context: UnitContext = UnitContext.create_unit_context(unit)
	var reachable_cells: Array[Vector2i] = grid.get_reachable_cells(unit)
	var valid_positions: Array[Vector2i] = []

	for cell: Vector2i in reachable_cells:
		# Filter out cells that could be reachable due to merging conditions
		if cell in units.keys() and cell != unit.cell:
			continue

		unit_context.grid_pos = cell
		if can_attack_cell_without_moving(unit_context, target_cell):
			valid_positions.append(cell)

	return valid_positions


# For now, prevent unit to move on enemy/neutral buildings so that
# other units can capture them
# TODO: check if a unit is in range of capture before taking this decision
func score_cell_for_attack(unit: Unit, cell: Vector2i, buildings_manager: BuildingsManager) -> int:
	var building: Building = buildings_manager.get_building_at(cell)
	if building != null:
		if building.team.is_same_team(unit.team):
			return building.defense()
		return 0

	var terrain_data: TerrainData = grid.terrain_manager.get_terrain_data(cell)
	return terrain_data.defense_bonus
