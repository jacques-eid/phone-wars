class_name HumanController
extends TeamController


var move_unit_commands: Array[MoveUnitCommand]

### GENERAL
func _setup() -> void:
	pass
	

func _play_turn() -> void:
	await super._play_turn()


func _end_turn() -> void:
	super._end_turn()
	

### SELECTION
func selection_attempt(cell: Vector2i) -> SelectionResult.Values:
	if selected_unit != null or selected_building != null:
		return SelectionResult.Values.NONE

	var unit: Unit = units_manager.get_unit_at(cell)
	if unit != null:
		if not unit.exhausted and unit.team == team:
			selected_unit = unit
			selected_unit.select()
			return SelectionResult.Values.UNIT
		return SelectionResult.Values.NONE


	var building: Building = buildings_manager.get_building_at(cell)
	if building != null and building.can_be_selected():
		selected_building = building
		return SelectionResult.Values.BUILDING
		

	return SelectionResult.Values.NONE


func selected_cell_pos() -> Vector2i:
	if selected_unit != null:
		return selected_unit.cell

	if selected_building != null:
		return selected_building.cell

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


func handle_cell_tap(cell: Vector2i) -> CellTapResult.Values:
	if can_move_to_cell(cell):
		move_unit_commands.append(await move_unit_to_cell(cell))
		return CellTapResult.Values.UNIT_MOVED

	if merge_available() or not can_attack_cell(cell):
		return CellTapResult.Values.NONE

	if not can_attack_without_moving(cell):
		var best_cell: Vector2i = choose_best_attack_position(cell)
		move_unit_commands.append(await move_unit_to_cell(best_cell))

	set_target_unit(cell)
	return CellTapResult.Values.ENTER_ATTACK_MODE


func handle_long_press(cell: Vector2i) -> LongPressResult:
	var unit: Unit = units_manager.get_unit_at(cell)
	var building: Building = buildings_manager.get_building_at(cell)

	var lpr: LongPressResult = LongPressResult.new()
	lpr.unit = unit
	lpr.building = building
	if unit != null:
		lpr.cells_in_attack_range = units_manager.get_cells_in_attack_range(unit)
	return lpr


func handle_cancel_on_movement() -> CancelResult.Values:
	if selected_unit == null:
		return CancelResult.Values.DESELECT

	if len(move_unit_commands) == 0:
		deselect_unit()
		return CancelResult.Values.DESELECT

	cancel_unit_movement()
	return CancelResult.Values.NONE


### MOVEMENT
func update_movement_indicator() -> void:
	selected_unit.reachable_cells = units_manager.compute_reachable_cells(selected_unit)
			 

func get_reachable_cells() -> Array[Vector2i]:
	if selected_unit == null:
		return []
	return selected_unit.reachable_cells


func can_move_to_cell(cell: Vector2i) -> bool:
	return selected_unit.reachable_cells.has(cell)


func cancel_unit_movement() -> void:
	var move_unit_command: MoveUnitCommand = move_unit_commands.pop_back()
	move_unit_command.undo()
	move_unit_command = null


### CAPTURING
func capture_available() -> bool:
	if selected_unit == null:
		return false

	var unit_pos: Vector2i = selected_unit.cell
	var building: Building = buildings_manager.get_building_at(unit_pos)
	if building == null:
		return false

	return selected_unit.can_capture_building(building)


### MERGING
func merge_available() -> bool:
	if selected_unit == null:
		return false
	
	var unit_pos: Vector2i = selected_unit.cell
	var unit: Unit = units_manager.get_unit_at(unit_pos)
	if unit == null or unit == selected_unit:
		return false

	return selected_unit.can_merge_with_unit(unit)


### ATTACK
func can_attack_cell(cell: Vector2i) -> bool:
	var unit: Unit = selected_unit
	var cells: Array[Vector2i] = units_manager.get_cells_in_attack_range(unit)
	var enemy_unit: Unit = units_manager.get_unit_at(cell)
	return cells.has(cell) and enemy_unit != null and not enemy_unit.team.is_same_team(unit.team) 


func set_target_unit(cell: Vector2i) -> void:
	target_unit = units_manager.get_unit_at(cell)


func estimate_damage() -> EstimatedDamageResult:
	var edr: EstimatedDamageResult = EstimatedDamageResult.new()
	edr.attacker = selected_unit
	edr.defender = target_unit

	var defender_terrain_defense: float = get_terrain_defense(target_unit.cell)
	var attacker_terrain_defense: float = get_terrain_defense(selected_unit.cell)
	var result: CombatResult = CombatManager.resolve_combat(
		selected_unit, 
		target_unit, 
		defender_terrain_defense, 
		attacker_terrain_defense)

	edr.estimated_damage = result.damage
	edr.counter_damage = result.counter_damage

	var building: Building = buildings_manager.get_building_at(target_unit.cell)
	if building != null:
		edr.building = building
		return edr

	var terrain_data: TerrainData = terrain_manager.get_terrain_data(target_unit.cell)
	edr.terrain_data = terrain_data

	return edr


func get_units_in_attack_range_with_movement() -> Array[Vector2i]:
	if selected_unit == null:
		return []
	var units: Array[Unit] = units_manager.get_units_in_attack_range_with_movement(selected_unit)
	return units_manager.get_units_positions(units)
	


### EXHAUST
func _confirm_movement() -> void:
	if len(move_unit_commands) == 0:
		return

	var first_move_unit_command: MoveUnitCommand = move_unit_commands.pop_front()
	units_manager.move_unit(selected_unit, first_move_unit_command.start_cell, selected_unit.cell)

	move_unit_commands.clear()
