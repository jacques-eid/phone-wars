class_name StartTurnOrchestrator
extends Node

var coin_audio: AudioStream = preload("res://assets/sounds/ui/sfx_coin_double8.wav")

var start_turn_animation: StartTurnAnimation
var team_display: TeamDisplay

func _init(sta: StartTurnAnimation, td: TeamDisplay) -> void:
	start_turn_animation = sta
	team_display = td


func execute(team: Team, new_funds: int) -> void:
	team_display.animate_out()
	
	await start_turn_animation.play(team)

	team_display.set_new_team(team)
	await team_display.animate_in()

	var id: int = AudioService.play_loop(coin_audio, team_display.global_position)
	await team_display.update_funds(new_funds) 
	AudioService.stop(id)
