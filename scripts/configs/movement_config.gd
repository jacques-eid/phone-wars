
class_name MovementConfig


class MovementStats:
	var unit_type: UnitType.Values
	var costs: Array[MovementCost]

	func _to_string() -> String:
		var s: String = "unit [%s]\n"%UnitType.get_name_from_type(unit_type)
		for mc in costs:
			s += "terrain [%s] - costs [%s]\n"%[TerrainType.get_name_from_type(mc.terrain_type), mc.cost]

		return s

class MovementCost:
	var terrain_type: TerrainType.Values
	var cost: float


var movement_matrix: Array[MovementStats]


func load_from_file(filename: String) -> void:
	movement_matrix.clear()

	var file: FileAccess = FileAccess.open("res://%s"%filename, FileAccess.READ)
	var headers: PackedStringArray = file.get_csv_line()

	while not file.eof_reached():
		var movement_stats: MovementStats = MovementStats.new()
		var parts: PackedStringArray = file.get_csv_line()
		# empty line
		if parts[0] == '':
			continue
		movement_stats.unit_type = UnitType.get_type_from_name(parts[0])

		for i in range(1, parts.size()):
			var movement_cost: MovementCost = MovementCost.new()
			movement_cost.terrain_type = TerrainType.get_type_from_name(headers[i])
			movement_cost.cost = float(parts[i])
			if movement_cost.cost == -1:
				movement_cost.cost = INF
			movement_stats.costs.append(movement_cost)

		movement_matrix.append(movement_stats)
		print('movement stats: %s' % movement_stats)


func get_movement_cost(unit_type: UnitType.Values, terrain_type: TerrainType.Values) -> float:
	var unit_idx: int = movement_matrix.find_custom(func(ms: MovementStats): return ms.unit_type == unit_type)
	if unit_idx == -1:
		push_error("unit [%s] does not exist in movement matrix" % UnitType.get_name_from_type(unit_type))

	var movement_stats: MovementStats = movement_matrix[unit_idx]
	var terrain_idx: int = movement_stats.costs.find_custom(func(mc: MovementCost): return mc.terrain_type == terrain_type)
	if terrain_idx == -1:
		push_error("terrain [%s] does not exist in movement stats for unit [%s]" % [TerrainType.get_name_from_type(terrain_type), UnitType.get_name_from_type(unit_type)])

	return movement_stats.costs[terrain_idx].cost 
