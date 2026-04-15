class_name Pathfinding


class Path:
	var points: Array[Vector2i]
	var cost: float
	var world_points: Array[Vector2]



static func find_path(grid: Grid, unit: Unit, start: Vector2i, target: Vector2i) -> Path:
	var open: Array[Vector2i] = [start]
	var came_from: Dictionary = {}
	var cost_so_far: Dictionary = {start: 0.0}

	while open.size() > 0:
		open.sort_custom(func(a, b):
			return cost_so_far[a] < cost_so_far[b]
		)

		var current = open.pop_front()
		if current == target:
			break

		for next in grid.get_neighbors(current):
			# cannot walk on this terrain
			var terrain: TerrainType.Values = grid.terrain_manager.get_terrain_type(next)
			var step_cost = GameConfig.get_movement_cost(unit.type(), terrain)
			if step_cost == INF:
				continue
				
			# cannot walk through enemy units
			var enemy_unit: Unit = grid.units_manager.get_unit_at(next)
			if enemy_unit != null and not enemy_unit.team.is_same_team(unit.team):
				continue

			var new_cost = cost_so_far[current] + step_cost
			if not cost_so_far.has(next) or new_cost < cost_so_far[next]:
				cost_so_far[next] = new_cost
				came_from[next] = current
				open.append(next)

	return reconstruct_path(came_from, cost_so_far, start, target)


static func reconstruct_path(came_from: Dictionary, cost_so_far: Dictionary, start: Vector2i, goal: Vector2i) -> Path:
	var current: Vector2i = goal
	var points: Array[Vector2i] = []
	var path: Path = Path.new()

	while current != start:
		points.append(current)
		if not came_from.has(current):
			return path
		current = came_from[current]
	points.append(start)
	points.reverse()

	path.points = points
	path.cost = cost_so_far[goal]
	return path
