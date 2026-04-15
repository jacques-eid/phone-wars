class_name Grid
extends Node2D

signal cell_short_tap(cell_position: Vector2i)
signal cell_long_press(cell_position: Vector2i)
signal cell_long_press_release(cell_position: Vector2i)

var units_manager: UnitsManager
var terrain_manager: TerrainManager

var building_cells := {}  # Vector2i → building


func setup(input_manager: InputManager, p_units_manager: UnitsManager, p_terrain_manager) -> void:
	terrain_manager = p_terrain_manager
	units_manager = p_units_manager

	# subscribe to input events
	input_manager.short_tap.connect(_on_short_tap)
	input_manager.long_press.connect(_on_long_press)
	input_manager.long_press_release.connect(_on_long_press_release)


func _on_short_tap(world_pos: Vector2) -> void:
	var cell_pos: Vector2i = terrain_manager.world_to_cell(world_pos)
	cell_short_tap.emit(cell_pos)


func _on_long_press(world_pos: Vector2) -> void:
	var cell_pos: Vector2i = terrain_manager.world_to_cell(world_pos)
	cell_long_press.emit(cell_pos)


func _on_long_press_release(world_pos: Vector2) -> void:
	var cell_pos: Vector2i = terrain_manager.world_to_cell(world_pos)
	cell_long_press_release.emit(cell_pos)


func get_world_position_from_cell(cell_position: Vector2i) -> Vector2:
	return terrain_manager.cell_to_world(cell_position)


# Return a dictionary of all the reachable cells
# Exclude the current unit cell
func get_reachable_cells(unit: Unit) -> Array[Vector2i]:
	var start: Vector2i = unit.cell
	var frontier := [{ "cell": start, "cost": 0.0 }]
	var visited := { start: {"cost": 0.0, "walkthrough": false} }

	while frontier.size() > 0:
		frontier.sort_custom(func(a, b): return a.cost < b.cost)
		var current = frontier.pop_front()
		var cell: Vector2i = current.cell
		var cost: float = current.cost

		for neighbor in get_neighbors(cell):
			var walkthrough: bool = false
			# cannot walk on this terrain
			var terrain: TerrainType.Values = terrain_manager.get_terrain_type(neighbor)
			var step_cost = GameConfig.get_movement_cost(unit.type(), terrain)
			if step_cost == INF:
				continue

			# not enough movement points left
			var new_cost = cost + step_cost
			if new_cost > unit.movement_points:
				continue

			var target_unit: Unit = units_manager.get_unit_at(neighbor)
			if target_unit != null:
				# cannot walk through enemy units
				if not target_unit.team.is_same_team(unit.team):
					continue
				# same unit / discards it
				if target_unit == unit:
					continue
				# can only walk onto friendly unit if merging is possible
				if not unit.can_merge_with_unit(target_unit):
					walkthrough = true

			if not visited.has(neighbor) or new_cost < visited[neighbor]["cost"]:
				visited[neighbor] = {"cost": new_cost, "walkthrough": walkthrough}
				frontier.append({ "cell": neighbor, "cost": new_cost })

	var results: Array[Vector2i]
	for key in visited.keys():
		if not visited[key]["walkthrough"]:
			results.append(key)

	# erase the current unit
	results.erase(unit.cell)

	return results


# Helpers method to get all the neighbors of a cell even if disabled in AStar
func get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	const DIRS : Array[Vector2i] = [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	var neighbors: Array[Vector2i] = []

	for d in DIRS:
		neighbors.append(cell + d)

	return neighbors


func get_cells_in_manhattan_range(
	center: Vector2i,
	min_range: int,
	max_range: int
) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for dx in range(-max_range, max_range + 1):
		var dy_limit = max_range - abs(dx)
		for dy in range(-dy_limit, dy_limit + 1):
			var dist = abs(dx) + abs(dy)
			if dist < min_range:
				continue

			cells.append(center + Vector2i(dx, dy))

	return cells
