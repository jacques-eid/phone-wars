class_name CombatManager


static func resolve_combat(attacker: Unit, defender: Unit, defense_terrain: float) -> CombatResult:
	var result: CombatResult = CombatResult.new()
	result.attacker = attacker
	result.defender = defender
	result.damage = compute_damage(attacker, defender, defense_terrain)
	result.defender_killed = defender.actual_health - result.damage <= 0

	return result


static func compute_damage(attacker: Unit, defender: Unit, defense_terrain: float) -> float:
	var base_dmg: float = attacker.get_attack_dmg(defender.type())
	base_dmg *= attacker.actual_health / 10.0

	var defense: float = defender.get_defense_vs(attacker.type())
	base_dmg *= (1.0 - defense / 10.0)

	base_dmg *= (1.0 - defense_terrain / 10.0)
	return max(1.0, int(base_dmg))
