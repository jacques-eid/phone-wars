class_name CombatOrchestrator

var damage_popup: DamageEffect
var fx_service: FXService
var audio_service: AudioService

func _init(dp: DamageEffect, fxs: FXService, audio: AudioService) -> void:
	damage_popup = dp
	fx_service = fxs
	audio_service = audio


func execute(controller: HumanController) -> void:
	var result: CombatResult = controller.perform_combat()

	await play_attack_animation(result)
	await play_defender_reaction(result)
	apply_damage(result)
	show_damage_popup(result)

	if result.defender_killed:
		handle_unit_death(result)

	controller.combat_done()


func play_attack_animation(result: CombatResult) -> void:
	await result.attacker.attack(result.defender, fx_service, audio_service)

	
func play_defender_reaction(result: CombatResult) -> void:
	var weapon: Weapon = result.attacker.weapon()
	weapon._play_impact(result.attacker.facing, result.defender, fx_service.play_world_fx, audio_service)
	await result.defender.play_hit_reaction()


func show_damage_popup(result: CombatResult) -> void:
	damage_popup.update(result.damage)
	damage_popup.play(result.defender)


func apply_damage(result: CombatResult) -> void:
	result.defender.take_dmg(result.damage)


func handle_unit_death(result: CombatResult) -> void:
	result.defender.die(audio_service)
