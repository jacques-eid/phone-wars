class_name DamageEffect
extends Control


@onready var damage_label: Label = $Label


func _ready() -> void:
	modulate .a = 0.0


func update(damage: float) -> void:
	damage_label.text = "-%s" %int(round(damage))


func play(target: Node2D):
	var local_transform: Vector2 = target.get_screen_transform().origin
	global_position = local_transform + Vector2(0, -size.y)
	modulate.a = 1.0

	var tween = create_tween()
	tween.parallel().tween_property(self, "position:y", position.y - 50, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)

	await tween.finished