class_name CombatConfig


class CombatStats:
	var attacker: UnitType.Values
	var flat_damages: Array[FlatDamage]

	func _to_string() -> String:
		var s: String = "attacker [%s]\n"%UnitType.get_name_from_type(attacker)
		for fd in flat_damages:
			s += "defender [%s] - dmg [%d]\n"%[UnitType.get_name_from_type(fd.defender), fd.dmg]

		return s


class FlatDamage:
	var defender: UnitType.Values
	var dmg: float


var combat_matrix: Array[CombatStats]


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
		combat_stats.attacker = UnitType.get_type_from_name(parts[0])

		for i in range(1, parts.size()):
			var flat_damage: FlatDamage = FlatDamage.new()
			flat_damage.defender = UnitType.get_type_from_name(headers[i])
			flat_damage.dmg = float(parts[i])
			combat_stats.flat_damages.append(flat_damage)

		combat_matrix.append(combat_stats)
		print('combat stats: %s' % combat_stats)



func get_flat_attack_damage(attacker: UnitType.Values, defender: UnitType.Values) -> float:
	var attacker_idx: int = combat_matrix.find_custom(func(cs: CombatStats): return cs.attacker == attacker)
	if attacker_idx == -1:
		push_error("attacker [%s] does not exist in combat matrix" % UnitType.get_name_from_type(attacker))

	var combat_stats: CombatStats = combat_matrix[attacker_idx]
	var defender_idx: int = combat_stats.flat_damages.find_custom(func(fd: FlatDamage): return fd.defender == defender)
	if defender_idx == -1:
		push_error("defender [%s] does not exist in combat stats for attacker [%s]" % [UnitType.get_name_from_type(defender), UnitType.get_name_from_type(attacker)])

	return combat_stats.flat_damages[defender_idx].dmg