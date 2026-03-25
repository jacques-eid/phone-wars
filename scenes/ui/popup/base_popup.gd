class_name BasePopup
extends Control

@onready var panel_container: PanelContainer = $PanelContainer
@onready var border_texture: TextureRect = $BorderAnimation

func _ready() -> void:
	modulate.a = 0.0
	scale = Vector2.ZERO

	border_texture.material = border_texture.material.duplicate()
	border_texture.material.set_shader_parameter("alpha", 0.0)
	update_border()

	
func _notification(what):
	if what == NOTIFICATION_RESIZED:
		update_border()


func animate_in():
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "scale", Vector2.ONE, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "modulate:a", 1.0, 0.5)

	# display the border
	tween.tween_method(
		func(v): border_texture.material.set_shader_parameter("alpha", v),
		0.0, 1.0, 0.15
	)
	await tween.finished
	await get_tree().create_timer(0.5).timeout


func animate_out():
	if modulate.a == 0.0:
		return

	var tween = create_tween()
	tween.set_parallel(true)
	# hides the border alone
	tween.tween_method(
		func(v): border_texture.material.set_shader_parameter("alpha", v),
		1.0, 0.0, 0.2
	)

	# modulate the main panel
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)


func position_dialog(target: Node2D):
	var dialog_size: Vector2 = panel_container.size
	var viewport_size: Vector2 = get_viewport_rect().size
	var local_transform: Vector2 = target.get_screen_transform().origin
	global_position = local_transform - Vector2(0, dialog_size.y)

	var margin: float = 10.0
	# if the dialog is too high on the viewport, displays it below the unit
	if global_position.y - dialog_size.y / 2 - margin < 0:
		global_position += Vector2(0, 2*dialog_size.y)

	global_position.x = clamp(global_position.x, dialog_size.x / 2 + margin, viewport_size.x - dialog_size.x / 2 - margin)

	update_border()


func update_border():
	border_texture.position = panel_container.position
	border_texture.set_deferred("size", panel_container.size)
