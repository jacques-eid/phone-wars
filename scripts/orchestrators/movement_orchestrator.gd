class_name MovementOrchestrator


var audio_service: AudioService

func _init(audio: AudioService) -> void:
	audio_service = audio


func execute(controller: HumanController, target_cell: Vector2i) -> void:
	var selected_unit: Unit = controller.selected_unit
	var id: int = audio_service.play_loop(selected_unit.move_sound(), selected_unit.global_position)
	await controller.move_unit_to_cell(target_cell)
	audio_service.stop(id)

