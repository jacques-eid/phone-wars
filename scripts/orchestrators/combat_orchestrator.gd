class_name CombatOrchestrator

var damage_popup: DamageEffect
var fx_service: FXService

func _init(dp: DamageEffect, fxs: FXService) -> void:
	damage_popup = dp
	fx_service = fxs


func execute(result: CombatResult) -> void:
	await play_attack_animation(result)
	await play_defender_reaction(result)
	
	if not result.defender_killed:
		await show_damage_popup(result)
		return

	show_damage_popup(result)	
	await result.defender.play_death()
		

func play_attack_animation(result: CombatResult) -> void:
	await result.attacker.attack(result.defender, fx_service)

	
func play_defender_reaction(result: CombatResult) -> void:
	var weapon: Weapon = result.attacker.weapon()
	weapon._play_impact(result.attacker.facing, result.defender, fx_service.play_world_fx)
	await result.defender.play_hit_reaction()


func show_damage_popup(result: CombatResult) -> void:
	damage_popup.update(result.damage)
	await damage_popup.play(result.defender)