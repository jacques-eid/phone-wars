class_name MergeUnitsOrchestrator
extends Node

var coin_audio: AudioStream = preload("res://assets/sounds/ui/sfx_coin_double8.wav")

var team_display: TeamDisplay
var audio_service: AudioService


func _init(td: TeamDisplay, audio: AudioService) -> void:
	team_display = td
	audio_service = audio


func execute(human_controller: HumanController) -> void:
	var team: Team = human_controller.team
	human_controller.merge_units()

	var id: int = audio_service.play_loop(coin_audio, team_display.global_position)
	await team_display.update_funds(team.funds)
	audio_service.stop(id)