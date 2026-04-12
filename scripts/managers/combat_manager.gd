class_name CombatManager


static func resolve_combat(
	attacker: Unit,
	defender: Unit,
	defender_terrain_defense: float,
	attacker_terrain_defense: float) -> CombatResult:
	var result: CombatResult = CombatResult.new()
	result.attacker = attacker
	result.defender = defender
	result.damage = compute_damage(attacker, attacker.actual_health, defender, defender_terrain_defense)
	result.defender_killed = defender.actual_health - result.damage <= 0

	var cca: bool = can_counter_attack(attacker, defender)
	if result.defender_killed or not cca:
		return result

	var defender_hp: float = defender.actual_health - result.damage
	result.counter_damage = compute_damage(defender, defender_hp, attacker, attacker_terrain_defense)

	return result


static func compute_damage(attacker: Unit, attacker_health: float, defender: Unit, terrain_defense: float) -> float:
	var base_dmg: float = CombatConfig.get_flat_attack_damage(attacker.type(), defender.type()) / 10.0
	base_dmg *= attacker_health / 10.0

	base_dmg *= (1.0 - terrain_defense / 10.0)
	return max(1.0, int(base_dmg))


static func can_counter_attack(attacker: Unit, defender: Unit) -> bool:
	return not attacker.is_range() and not defender.is_range()