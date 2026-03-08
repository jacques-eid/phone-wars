class_name UnitSelectedState
extends LimboState

var unit: Unit


func _setup() -> void:
	unit = agent


func _enter(_params: Dictionary = {}) -> void:
	print('entering selected state')
	unit.idling()
	unit.animated_sprite.modulate = Color(0, 1, 0)  # Change color to green when selected
	

func _exit() -> void:
	unit.animated_sprite.stop()
	unit.animated_sprite.modulate = Color(1, 1, 1)  # Change color back to white when deselected
