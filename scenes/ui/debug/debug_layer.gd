extends CanvasLayer


@onready var fps_label: Label = $Control/MarginContainer/VBoxContainer/FPSLabel
@onready var unit_label: Label = $Control/MarginContainer/VBoxContainer/UnitLabel
@onready var ai_container: VBoxContainer = $Control/MarginContainer/VBoxContainer/ScrollContainer/AIContainer


func _ready() -> void:
	DebugManager.selected_unit_changed.connect(update_unit_info)
	DebugManager.refresh_ai_logs.connect(refresh_ai_logs)


func _process(_delta: float) -> void:
	if not DebugManager.debug_enabled:
		visible = false
		return

	unit_label.visible = DebugManager.show_unit_info()
	ai_container.visible = DebugManager.show_ai_scores()
	visible = true

	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	

func update_unit_info(unit: Unit) -> void:
	unit_label.visible = true
		
	if unit == null:
		unit_label.text = ""
		return 

	unit_label.text = "%s\nHP: %d - Move: %d - Team: %d" % [unit.debug_name, unit.actual_health, unit.movement_points, unit.team.id]


func refresh_ai_logs() -> void:
	for child: Node in ai_container.get_children():
		child.queue_free()

	
	for ai_log: AIDebugLog in DebugManager.ai_logs:
		var label: Label = Label.new()
		label.text = format_ai_log(ai_log)
		label.add_theme_font_size_override("font_size", 4)
		label.add_theme_constant_override("line_spacing", 0)
		ai_container.add_child(label)


func format_ai_log(ai_log: AIDebugLog) -> String:
	var text = ""

	for result in ai_log.results:
		text += "%s\n" % result

	text += "→ %s\n" % ai_log.top_result

	return text
