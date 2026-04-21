class_name Toast
extends Control

@onready var label: Label = $MarginContainer/Label


func _ready() -> void:
	label.modulate.a = 0.0


func show_toast(text: String) -> void:
	label.text = text

	label.modulate.a = 1.0

	await get_tree().create_timer(1.5).timeout

	# fade out
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.5)