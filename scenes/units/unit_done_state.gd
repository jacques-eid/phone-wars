class_name UnitDoneState
extends LimboState

var unit: Unit


func _setup() -> void:
	unit = agent


func _enter() -> void:
	print('entering done state')
	unit.exhausted = true
	unit.facing = unit.team.face_direction
	unit.reset_movement_points()
	unit.idling()
	unit.animated_sprite.material.set_shader_parameter("disabled", 0.5)


func _exit() -> void:
	unit.animated_sprite.stop()
	unit.animated_sprite.material.set_shader_parameter("disabled", 0.0)
	unit.exhausted = false


