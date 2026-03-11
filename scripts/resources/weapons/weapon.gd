class_name Weapon
extends Resource

@export var fire_scene: PackedScene
@export var hit_scene: PackedScene
@export var fire_sound: AudioStream
@export var hit_sound: AudioStream


func _play_fire(_attacker: Node2D, _spawn_pos: Vector2, _play_fx_func: Callable) -> void:
	pass

	
func _play_impact(_attacker_facing: FaceDirection.Values, _defender: Node2D, _play_fx_func: Callable) -> void:
	pass