class_name CombatConfig


class CombatStats:
	var flat_damages: Dictionary[UnitType.Values, float]

	func _to_string() -> String:
		var s: String = ""
		for fd in flat_damages.keys():
			s += "\ndefender [%s] - dmg [%d]"%[UnitType.get_name_from_type(fd), flat_damages[fd]]

		return s


var combat_matrix: Dictionary[UnitType.Values, CombatStats]


func load_from_file(filename: String) -> void:
	combat_matrix.clear()

	var file: FileAccess = FileAccess.open("res://%s"%filename, FileAccess.READ)
	var headers: PackedStringArray = file.get_csv_line()

	while not file.eof_reached():
		var combat_stats: CombatStats = CombatStats.new()
		var parts: PackedStringArray = file.get_csv_line()
		# empty line
		if parts[0] == '':
			continue
		var attacker: UnitType.Values = UnitType.get_type_from_name(parts[0])

		for i in range(1, parts.size()):
			var defender: UnitType.Values = UnitType.get_type_from_name(headers[i])
			var dmg: float = float(parts[i])
			combat_stats.flat_damages[defender] = dmg

		combat_matrix[attacker] = combat_stats
		print('combat stats for attacker [%s]: %s' % [UnitType.get_name_from_type(attacker), combat_stats])



func get_flat_attack_damage(attacker: UnitType.Values, defender: UnitType.Values) -> float:
	if not combat_matrix.has(attacker):
		push_error("attacker [%s] does not exist in combat matrix" % UnitType.get_name_from_type(attacker))

	var combat_stats: CombatStats = combat_matrix[attacker]
	if not combat_stats.flat_damages.has(defender):
		push_error("defender [%s] does not exist in combat stats for attacker [%s]" % [UnitType.get_name_from_type(defender), UnitType.get_name_from_type(attacker)])
	
	return combat_stats.flat_damages[defender]