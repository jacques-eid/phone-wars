class_name TeamController
extends Node


signal gameplay_event(event: GameplayEvent.Values, cargo: Variant)
signal animation_finished()

signal turn_end()

signal focus_on(controller: TeamController, focus_point: Vector2)
signal focused_on()


var team: Team
var units_manager: UnitsManager
var buildings_manager: BuildingsManager
var terrain_manager: TerrainManager

var selected_unit: Unit = null
var selected_building: Building = null
# TODO: Check to refacto this target_unit
var target_unit: Unit = null

func _init(t: Team, um: UnitsManager, bm: BuildingsManager, tm: TerrainManager) -> void:
	team = t
	units_manager = um
	buildings_manager = bm
	terrain_manager = tm


func _setup() -> void:
	push_error("_setup() must be implemented")


func _play_turn() -> void:
	push_error("_play_turn() must be implemented")


func _end_turn() -> void:
	units_manager.reset_units(team)
	turn_end.emit()


func _confirm_movement() -> void:
	push_error("_confirm_movement() must be implemented")
	

func focus(focus_point: Vector2) -> void:
	focus_on.emit(self, focus_point)
	await focused_on


func get_default_focus_point() -> Vector2:
	for building: Building in buildings_manager.buildings.values():
		if building.type() == BuildingType.Values.HQ:
			return building.position

	return Vector2.ZERO


func move_unit_to_cell(cell: Vector2i) -> MoveUnitCommand:
	var path: Pathfinding.Path = units_manager.compute_unit_path(selected_unit, cell)

	var move_unit_command: MoveUnitCommand = MoveUnitCommand.new(selected_unit, cell, path)
	move_unit_command.execute()

	await selected_unit.unit_moved

	return move_unit_command


func can_attack_without_moving(cell: Vector2i) -> bool:
	var unit_context: UnitContext = UnitContext.create_unit_context(selected_unit)
	return units_manager.can_attack_cell_without_moving(unit_context, cell)


# Later on, add a movement service to compute such movements
func choose_best_attack_position(cell: Vector2i) -> Vector2i:
	return units_manager.choose_best_attack_position(selected_unit, cell, buildings_manager)


func capture_building() -> void:
	var unit_pos: Vector2i = selected_unit.cell
	var building: Building = buildings_manager.get_building_at(unit_pos)
	if building == null:
		return

	selected_unit.start_capture(building)

	var result: CaptureResult = selected_unit.capture()

	gameplay_event.emit(GameplayEvent.Values.CAPTURE, result)
	await animation_finished

	if result.capture_done:
		selected_unit.capture_process.capture_done(selected_unit)
		selected_unit.stop_capture()

	exhaust_unit()


func merge_units() -> void:
	var unit_pos: Vector2i = selected_unit.cell
	var merged_unit: Unit = units_manager.get_unit_at(unit_pos)

	if merged_unit == null:
		return

	var money_gain: int = units_manager.merge_units(selected_unit, merged_unit)
	team.funds += money_gain

	exhaust_unit()

	if money_gain <= 0:
		return

	gameplay_event.emit(GameplayEvent.Values.FUNDS_EARNED, team)
	await animation_finished


func perform_combat() -> void:
	var attacker: Unit = selected_unit
	var defender: Unit = target_unit
	var defender_terrain_defense: float = get_terrain_defense(defender.cell)
	var attacker_terrain_defense: float = get_terrain_defense(attacker.cell)
	var result = CombatManager.resolve_combat(
		attacker, 
		defender, 
		defender_terrain_defense, 
		attacker_terrain_defense)
	
	gameplay_event.emit(GameplayEvent.Values.COMBAT, result)
	await animation_finished
	result.defender.take_dmg(result.damage)
	result.attacker.take_dmg(result.counter_damage)

	if result.defender_killed:
		result.defender.die()
		
	exhaust_unit()


func get_terrain_defense(cell: Vector2i) -> float:
	var terrain_data: TerrainData = terrain_manager.get_terrain_data(cell)
	var building: Building = buildings_manager.get_building_at(cell)
	var terrain_defense: float = terrain_data.defense_bonus

	if building != null:
		terrain_defense = building.defense()

	return terrain_defense


func buy_unit(entry: ProductionEntry) -> void:
	if team.funds < entry.cost():
		return
		
	var cell: Vector2i = selected_building.cell
	team.funds -= entry.cost()
	units_manager.add_unit(entry, cell, team)

	gameplay_event.emit(GameplayEvent.Values.FUNDS_SPENT, team)
	await animation_finished

	selected_building = null


func exhaust_unit() -> void:
	_confirm_movement()

	selected_unit.exhaust()
	selected_unit = null
