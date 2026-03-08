class_name UnitIdleState
extends LimboState

var unit: Unit

func _setup() -> void:
	unit = agent


func _enter(_params: Dictionary = {}) -> void:
	unit.idling()


func _exit() -> void:
	unit.animated_sprite.stop()

