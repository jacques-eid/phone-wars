
class_name CameraController
extends Node2D


@onready var camera: Camera2D = $Camera2D


var pan_enabled: bool = false


func setup(ui_controller: UIController, input_manager: InputManager, terrain_manager: TerrainManager) -> void:
	ui_controller.camera_pan_enabled.connect(_on_camera_pan_enabled)
	input_manager.pan_requested.connect(_on_pan_requested)

	camera.limit_left = terrain_manager.terrain_start_pos.x * Const.CELL_SIZE.x
	camera.limit_top = terrain_manager.terrain_start_pos.y * Const.CELL_SIZE.y
	camera.limit_right = terrain_manager.terrain_end_pos.x * Const.CELL_SIZE.x
	camera.limit_bottom = terrain_manager.terrain_end_pos.y * Const.CELL_SIZE.y
	camera.limit_enabled = true


	

func _on_camera_pan_enabled(enabled: bool) -> void:
	pan_enabled = enabled


func _on_pan_requested(delta: Vector2) -> void:
	if not pan_enabled:
		return

	move_by(delta)

	
func move_by(delta: Vector2) -> void:
	camera.position -= delta


func focus_on(pos: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "position", pos, 1.0)

	await tween.finished