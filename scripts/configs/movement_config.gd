
class_name MovementConfig


class MovementStats:
	var costs: Dictionary[TerrainType.Values, float]

	func _to_string() -> String:
		var s: String = ""
		for mc in costs.keys():
			s += "\nterrain [%s] - costs [%s]"%[TerrainType.get_name_from_type(mc), costs[mc]]

		return s


var movement_matrix: Dictionary[UnitType.Values, MovementStats]


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
		
		var unit_type: UnitType.Values = UnitType.get_type_from_name(parts[0])

		for i in range(1, parts.size()):
			var terrain_type: TerrainType.Values = TerrainType.get_type_from_name(headers[i])
			var cost: float = float(parts[i])
			if cost == -1:
				cost = INF
			movement_stats.costs[terrain_type] = cost

		movement_matrix[unit_type] = movement_stats
		print('movement stats for unit [%s]: %s' % [UnitType.get_name_from_type(unit_type), movement_stats])


func get_movement_cost(unit_type: UnitType.Values, terrain_type: TerrainType.Values) -> float:
	if not movement_matrix.has(unit_type):
		push_error("unit [%s] does not exist in movement matrix" % UnitType.get_name_from_type(unit_type))

	var movement_stats: MovementStats = movement_matrix[unit_type]
	if not movement_stats.costs.has(terrain_type):
		push_error("terrain [%s] does not exist in movement stats for unit [%s]" % [TerrainType.get_name_from_type(terrain_type), UnitType.get_name_from_type(unit_type)])

	return movement_stats.costs[terrain_type] 
