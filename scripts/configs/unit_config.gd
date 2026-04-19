class_name UnitConfig


var unit_stats: Dictionary[UnitType.Values, UnitStats] = {}


func load_from_file(filename: String) -> void:
	unit_stats.clear()

	var file: FileAccess = FileAccess.open("res://%s"%filename, FileAccess.READ)
	# Unused in this parsing
	var _headers: PackedStringArray = file.get_csv_line()


	while not file.eof_reached():
		var stats: UnitStats = UnitStats.new()
		var parts: PackedStringArray = file.get_csv_line()
		# empty line
		if parts[0] == '':
			continue
		
		var unit_type: UnitType.Values = UnitType.get_type_from_name(parts[0])
		stats.movement_points = int(parts[1])
		stats.capture_capacity = int(parts[2])
		stats.health = int(parts[3])
		stats.cost = int(parts[4])
		stats.min_range = int(parts[5])
		stats.max_range = int(parts[6])

		unit_stats[unit_type] = stats
		print('unit stats for unit type[%s]: %s' % [UnitType.get_name_from_type(unit_type), stats])


func get_unit_stats(unit_type: UnitType.Values) -> UnitStats:
	if not unit_stats.has(unit_type):
		push_error("unit [%s] does not exist in unit stats" %UnitType.get_name_from_type(unit_type))

	return unit_stats[unit_type]
