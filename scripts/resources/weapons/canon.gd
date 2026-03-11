class_name Canon
extends Weapon


func _play_fire(attacker: Node2D, spawn_pos: Vector2, play_fx_func: Callable) -> void:
	# Anchor around attacker, biased toward target
	var dir: Vector2 = Vector2(-1, 0)
	var base_pos: Vector2 = spawn_pos

	if attacker.facing == FaceDirection.Values.RIGHT:
		base_pos.x += Const.CELL_SIZE.x
		dir = Vector2(1, 0)

	play_fx_func.call(fire_scene, base_pos, dir.angle())
	AudioService.play_sfx(fire_sound, base_pos)


func _play_impact(attacker_facing: FaceDirection.Values, defender: Node2D, play_fx_func: Callable) -> void:
	# Anchor around attacker, biased toward target
	var dir: Vector2 = Vector2(-1, 0)

	if attacker_facing == FaceDirection.Values.LEFT:
		dir = Vector2(1, 0)

	play_fx_func.call(hit_scene, defender.global_position, dir.angle())
	AudioService.play_sfx(hit_sound, defender.global_position)