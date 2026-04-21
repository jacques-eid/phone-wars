class_name CaptureOrchestrator

var capture_dialog: CapturePopup
var fx_service: FXService


func _init(cd: CapturePopup, fxs: FXService) -> void:
	capture_dialog = cd
	fx_service = fxs


func execute(result: CaptureResult) -> void:
	await load_capture_animation(result)
	await play_attack_animation()
	play_building_reaction()
	await play_capture_animation(result)
	capture_dialog.animate_out()
	clear_dialog()


func load_capture_animation(result: CaptureResult) -> void:
	capture_dialog.load(result)
	await capture_dialog.position_dialog(result.building)
	await capture_dialog.animate_in()


func play_attack_animation() -> void:
	await capture_dialog.play_unit_attack(fx_service)


func play_building_reaction() -> void:
	capture_dialog.play_building_impacts(fx_service)
	

func play_capture_animation(result: CaptureResult) -> void:
	await capture_dialog.update(result)


func clear_dialog() -> void:
	capture_dialog.unit_proxy.clear()