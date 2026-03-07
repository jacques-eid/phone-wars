class_name CaptureOrchestrator

var capture_dialog: CapturePopup
var fx_service: FXService
var audio_service: AudioService


func _init(cd: CapturePopup, fxs: FXService, audio: AudioService) -> void:
	capture_dialog = cd
	fx_service = fxs
	audio_service = audio


func execute(controller: HumanController) -> void:
	var unit: Unit = controller.selected_unit
	var result: CaptureProcess.CaptureResult = unit.capture()
	
	await load_capture_animation(result)
	await play_attack_animation()
	play_building_reaction()
	await play_capture_animation(result)
	await capture_dialog.animate_out()
	clear_dialog()

	controller.exhaust_unit()
	if not result.capture_done:
		return

	unit.capture_process.capture_done()
	unit.stop_capture()


func load_capture_animation(result: CaptureProcess.CaptureResult) -> void:
	capture_dialog.load(result)
	await capture_dialog.position_dialog(result.building)
	await capture_dialog.animate_in()


func play_attack_animation() -> void:
	await capture_dialog.play_unit_attack(fx_service, audio_service)


func play_building_reaction() -> void:
	capture_dialog.play_building_impacts(fx_service, audio_service)
	

func play_capture_animation(result: CaptureProcess.CaptureResult) -> void:
	await capture_dialog.update(result)


func clear_dialog() -> void:
	capture_dialog.unit_proxy.clear()