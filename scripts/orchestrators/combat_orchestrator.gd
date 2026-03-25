class_name CombatOrchestrator

var damage_popup: DamageEffect
var fx_service: FXService

func _init(dp: DamageEffect, fxs: FXService) -> void:
	damage_popup = dp
	fx_service = fxs


func execute(result: CombatResult) -> void:
	units_face_each_other(result.attacker, result.defender)
	await play_attack_animation(result.attacker)
	await play_defender_reaction(result.attacker, result.defender)
	
	if result.defender_killed:
		show_damage_popup(result.defender, result.damage)	
		await result.defender.play_death()
		units_face_team_direction(result.attacker, result.defender)
		return

	await show_damage_popup(result.defender, result.damage)
	
	if result.counter_damage <= 0.0:
		units_face_team_direction(result.attacker, result.defender)
		return

	await play_attack_animation(result.defender)
	await play_defender_reaction(result.defender, result.attacker)
	
	await show_damage_popup(result.attacker, result.counter_damage)

	units_face_team_direction(result.attacker, result.defender)


func play_attack_animation(attacker: Unit) -> void:
	await attacker.play_attack(fx_service)

	
func play_defender_reaction(attacker: Unit, defender: Unit) -> void:
	var weapon: Weapon = attacker.weapon()
	weapon._play_impact(attacker.facing, defender, fx_service.play_world_fx)
	await defender.play_hit_reaction()


func show_damage_popup(defender: Unit, damage: float) -> void:
	damage_popup.update(damage)
	await damage_popup.play(defender)


func units_face_each_other(attacker: Unit, defender: Unit) -> void:
	attacker.face_towards(defender.cell)
	defender.face_towards(attacker.cell)



func units_face_team_direction(attacker: Unit, defender: Unit) -> void:
	attacker.face_team_direction()
	defender.face_team_direction()