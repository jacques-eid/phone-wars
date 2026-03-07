class_name BuyUnitOrchestrator

var coin_audio: AudioStream = preload("res://assets/sounds/ui/sfx_coin_double1.wav")

var team_display: TeamDisplay
var audio_service: AudioService


func _init(td: TeamDisplay, audio: AudioService) -> void:
	team_display = td
	audio_service = audio


func execute(controller: HumanController, entry: ProductionEntry, cell_pos: Vector2i) -> void:
	var funds_left: int = controller.buy_unit(entry, cell_pos)
	var id: int = audio_service.play_loop(coin_audio, team_display.global_position)
	await team_display.update_funds(funds_left)
	audio_service.stop(id)