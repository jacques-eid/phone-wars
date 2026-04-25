class_name InputManager
extends Node

signal short_tap(world_pos: Vector2)
signal double_tap(world_pos: Vector2)
signal long_press(world_pos: Vector2)
signal long_press_release(world_pos: Vector2)
signal pan_requested(delta: Vector2)

# Config
@export var long_press_time: float = 0.5 # seconds
@export var drag_threshold: float = 4.0

# State
var press_time: float = 0.0
var pressed: bool = false
var long_pressed: bool = false
var pressed_position: Vector2 = Vector2.ZERO
var locked: bool
var double_tap_delay: float = 0.200
var tap_count: int


func _unhandled_input(event: InputEvent) -> void:
	if locked:
		return

	if event is InputEventScreenDrag:
		if event.relative.length() < drag_threshold:
			return

		pan_requested.emit(event.relative)
		if not long_pressed:
			pressed = false

	elif event is InputEventScreenTouch:
		if event.pressed:
			on_touch_pressed(event.position)
		else:
			on_touch_released(event.position)


func _process(delta: float) -> void:
	if pressed and not long_pressed:
		press_time += delta
		if press_time >= long_press_time:
			pressed_position = to_world_pos(pressed_position)
			long_press.emit(pressed_position)
			long_pressed = true
	

# Called immediately on touch down
func on_touch_pressed(pos: Vector2) -> void:
	press_time = 0.0
	pressed = true
	long_pressed = false
	pressed_position = pos


# Called when finger/mouse released
func on_touch_released(pos: Vector2) -> void:
	# In the event we did a drag
	if not pressed:
		press_time = 0.0
		long_pressed = false
		return

	pos = to_world_pos(pos)
	if long_pressed:
		long_press_release.emit(pos)
	else:
		tap_count += 1
		handle_short_tap(pos)
		
	pressed = false
	press_time = 0.0
	long_pressed = false


func to_world_pos(pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * pos


func lock() -> void:
	locked = true


func unlock() -> void:
	locked = false


func handle_short_tap(pos: Vector2) -> void:
	if tap_count == 1:
		await get_tree().create_timer(double_tap_delay).timeout
	
	if tap_count == 1:
		short_tap.emit(pos)
	
	if tap_count == 2:
		double_tap.emit(pos)

	tap_count = 0