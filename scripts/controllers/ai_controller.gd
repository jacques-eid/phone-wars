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
	var units: Array[Unit] = units_manager.get_units_for_team(team)

	return units.filter(func(unit: Unit): return not unit.exhausted)


func find_capturable_buildings(unit: Unit) -> Array[Building]:
	var reachable_cells: Array[Vector2i] = units_manager.compute_reachable_cells(unit)
	reachable_cells.append(unit.cell_pos)
	var buildings: Array[Building]

	for cell: Vector2i in reachable_cells:
		var building: Building = buildings_manager.get_building_at(cell)
		if building != null and not building.team.is_same_team(unit.team):
			buildings.append(building)

	return buildings


func find_mergeable_units(unit: Unit) -> Array[Unit]:
	var reachable_cells: Array[Vector2i] = units_manager.compute_reachable_cells(unit)
	var units: Array[Unit]

	for cell: Vector2i in reachable_cells:
		var target: Unit = units_manager.get_unit_at(cell)
		if target != null and unit.can_merge_with_unit(target):
			units.append(target)

	return units