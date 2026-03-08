class_name HumanController
extends TeamController


var team: Team
var units_manager: UnitsManager
var buildings_manager: BuildingsManager
var terrain_manager: TerrainManager

var selected_unit: Unit = null
var target_unit: Unit = null

var selected_building: Building = null

var move_unit_commands: Array[MoveUnitCommand]


func _init(t: Team, um: UnitsManager, bm: BuildingsManager, tm: TerrainManager) -> void:
	team = t
	units_manager = um
	buildings_manager = bm
	terrain_manager = tm


### GENERAL
func get_focus_point() -> Vector2:
	for building: Building in buildings_manager.buildings.values():
		if building.type() == BuildingType.Values.HQ:
			return building.position

	return Vector2.ZERO


### SELECTION
func selection_attempt(cell: Vector2i) -> SelectionResult:
	if selected_unit != null or selected_building != null:
		return SelectionResult.new(SelectionResult.Values.NONE)

	var unit: Unit = units_manager.get_unit_at(cell)
	if unit != null:
		if not unit.exhausted and unit.team == team:
			selected_unit = unit
			selected_unit.reachable_cells = units_manager.compute_reachable_cells(selected_unit)
			selected_unit.select()
			return SelectionResult.new(SelectionResult.Values.UNIT)
		return SelectionResult.new(SelectionResult.Values.NONE)


	var building: Building = buildings_manager.get_building_at(cell)
	if building != null and building.can_be_selected():
		selected_building = building
		return SelectionResult.new(SelectionResult.Values.BUILDING)
		

	return SelectionResult.new(SelectionResult.Values.NONE)


func selected_cell_pos() -> Vector2i:
	if selected_unit != null:
		return selected_unit.cell_pos

	if selected_building != null:
		return selected_building.cell_pos

	return Vector2i.ZERO


func deselect_unit() -> void:
	if selected_unit == null:
		return
	selected_unit.deselect()
	selected_unit = null


func deselect_building() -> void:
	if selected_building == null:
		return
	selected_building = null


func handle_long_press(cell: Vector2i) -> LongPressResult:
	var unit: Unit = units_manager.get_unit_at(cell)
	var building: Building = buildings_manager.get_building_at(cell)

	var lpr: LongPressResult = LongPressResult.new()
	lpr.unit = unit
	lpr.building = building
	lpr.cells_in_attack_range = units_manager.get_cells_in_attack_range(unit)
	return lpr

### MOVEMENT
func update_movement_indicator() -> void:
	selected_unit.reachable_cells = units_manager.compute_reachable_cells(selected_unit)
			 

func get_reachable_cells() -> Array[Vector2i]:
	if selected_unit == null:
		return []
	return selected_unit.reachable_cells


func can_move_to_cell(cell: Vector2i) -> bool:
	return selected_unit.reachable_cells.has(cell)


func move_unit_to_cell(cell: Vector2i) -> void:
	var path: Pathfinding.Path = units_manager.compute_unit_path(selected_unit, cell)

	var move_unit_command: MoveUnitCommand = MoveUnitCommand.new(selected_unit, cell, path)
	move_unit_command.execute()
	move_unit_commands.append(move_unit_command)

	await selected_unit.unit_moved


func cancel_unit_movement() -> void:
	var move_unit_command: MoveUnitCommand = move_unit_commands.pop_back()
	move_unit_command.undo()
	move_unit_command = null


### CAPTURING
func capture_available() -> bool:
	if selected_unit == null:
		return false

	var unit_pos: Vector2i = selected_unit.cell_pos
	var building: Building = buildings_manager.get_building_at(unit_pos)
	if building == null:
		return false

	return selected_unit.can_capture_building(building)


func capture_building() -> void:
	if selected_unit == null:
		return
	var unit_pos: Vector2i = selected_unit.cell_pos
	var building: Building = buildings_manager.get_building_at(unit_pos)
	if building == null:
		return

	selected_unit.start_capture(building)



### MERGING
func merge_available() -> bool:
	if selected_unit == null:
		return false
	
	var unit_pos: Vector2i = selected_unit.cell_pos
	var unit: Unit = units_manager.get_unit_at(unit_pos)
	if unit == null or unit == selected_unit:
		return false

	return selected_unit.can_merge_with_unit(unit)


func merge_units() -> void:
	if selected_unit == null:
		return

	var unit_pos: Vector2i = selected_unit.cell_pos
	var unit: Unit = units_manager.get_unit_at(unit_pos)
	
	if unit == null:
		return

	var money_gain: int = units_manager.merge_units(selected_unit, unit)
	team.funds += money_gain

	exhaust_unit()


### ATTACK
func can_attack_cell(cell: Vector2i) -> bool:
	var unit: Unit = selected_unit
	var cells: Array[Vector2i] = units_manager.get_cells_in_attack_range(unit)
	var enemy_unit: Unit = units_manager.get_unit_at(cell)
	return cells.has(cell) and enemy_unit != null and not enemy_unit.team.is_same_team(unit.team) 


func can_attack_without_moving(cell: Vector2i) -> bool:
	var unit_context: UnitContext = UnitContext.create_unit_context(selected_unit)
	return units_manager.can_attack_cell_without_moving(unit_context, cell)


# Later on, add a movement service to compute such movements
func choose_best_attack_position(cell: Vector2i) -> Vector2i:
	return units_manager.choose_best_attack_position(selected_unit, cell, buildings_manager)

func score_cell_for_attack(cell: Vector2i) -> int:
	var building: Building = buildings_manager.get_building_at(cell)
	if building != null:
		return building.defense()

	var terrain_data: TerrainData = terrain_manager.get_terrain_data(cell)
	return terrain_data.defense_bonus


func set_target_unit(cell: Vector2i) -> void:
	target_unit = units_manager.get_unit_at(cell)


func estimate_damage() -> EstimatedDamageResult:
	var edr: EstimatedDamageResult = EstimatedDamageResult.new()
	edr.attacker = selected_unit
	edr.defender = target_unit

	var building: Building = buildings_manager.get_building_at(target_unit.cell_pos)

	if building == null:
		var terrain_data: TerrainData = terrain_manager.get_terrain_data(target_unit.cell_pos)
		edr.terrain_data = terrain_data
		edr.estimated_damage = CombatManager.compute_damage(edr.attacker, edr.defender, terrain_data.defense_bonus)
		return edr

	edr.building = building
	edr.estimated_damage = CombatManager.compute_damage(edr.attacker, edr.defender, building.defense())

	return edr


func perform_combat() -> CombatResult:
	var attacker: Unit = selected_unit
	var defender: Unit = target_unit
	var terrain_data: TerrainData = terrain_manager.get_terrain_data(defender.cell_pos)
	var building: Building = buildings_manager.get_building_at(defender.cell_pos)
	var terrain_defense: float = terrain_data.defense_bonus

	if building != null:
		terrain_defense = building.defense() 
	var result = CombatManager.resolve_combat(attacker, defender, terrain_defense)

	return result


func combat_done() -> void:
	selected_unit.exhaust()
	selected_unit = null


func get_units_in_attack_range_with_movement() -> Array[Vector2i]:
	if selected_unit == null:
		return []
	var units: Array[Unit] = units_manager.get_units_in_attack_range_with_movement(selected_unit)
	return units_manager.get_units_positions(units)
	


### EXHAUST
func exhaust_unit() -> void:
	if selected_unit == null:
		return

	selected_unit.exhaust()
	if len(move_unit_commands) == 0:
		selected_unit = null
		return

	var first_move_unit_command: MoveUnitCommand = move_unit_commands.pop_front()
	units_manager.move_unit(selected_unit, first_move_unit_command.start_cell, selected_unit.cell_pos)

	move_unit_commands.clear()
	selected_unit = null   


func play_turn() -> void:
	pass


func end_turn() -> void:
	units_manager.reset_units()


### BUYING
func buy_unit(entry: ProductionEntry, cell: Vector2i) -> int:
	team.funds -= entry.cost()
	units_manager.add_unit(entry, cell, team)

	return team.funds
