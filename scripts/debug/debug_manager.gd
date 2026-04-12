extends CanvasLayer


signal selected_unit_changed(unit: Unit)
signal refresh_ai_logs()
signal show_coordinates(show: bool)


@export var debug_enabled: bool = false
@export var ai_scores_enabled: bool = false
@export var unit_info_enabled: bool = false
@export var coordinates_enabled: bool = false

@export var max_logs: int = 50

var local_coord_enabled: bool = false

var ai_logs: Array[AIDebugLog] = []


func _process(_delta: float) -> void:
	if not debug_enabled:
		return

	if coordinates_enabled != local_coord_enabled:
		local_coord_enabled = coordinates_enabled
		show_coordinates.emit(coordinates_enabled)


func show_ai_scores() -> bool:
	return debug_enabled and ai_scores_enabled


func show_unit_info() -> bool:
	return debug_enabled and unit_info_enabled


func update_selected_unit(unit: Unit) -> void:
	selected_unit_changed.emit(unit)


func record_ai_decision(ai_log: AIDebugLog) -> void:
	ai_logs.append(ai_log)

	if ai_logs.size() > max_logs:
		ai_logs.pop_front()

	refresh_ai_logs.emit()