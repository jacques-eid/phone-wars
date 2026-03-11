class_name MachineGunWeapon
extends Weapon


@export var burst_count := 5
@export var burst_interval := 0.07
@export var spread_radius := 2.0


func _play_fire(attacker: Node2D, spawn_pos: Vector2, play_fx_func: Callable) -> void:
	for i in burst_count:
		spawn_bullet_flash(attacker, spawn_pos, play_fx_func)
		await attacker.get_tree().create_timer(burst_interval).timeout


func spawn_bullet_flash(attacker: Node2D, spawn_pos: Vector2, play_fx_func: Callable):
	# Anchor around attacker, biased toward target
	var dir: Vector2 = Vector2(-1, 0)
	var base_pos: Vector2 = spawn_pos

	if attacker.facing == FaceDirection.Values.RIGHT:
		base_pos.x += Const.CELL_SIZE.x
		dir = Vector2(1, 0)

	var offset: Vector2 = Vector2(
		randf_range(-spread_radius, spread_radius),
		randf_range(-spread_radius, spread_radius)
	)
	
	var world_pos: Vector2 = base_pos+offset
	play_fx_func.call(fire_scene, world_pos, dir.angle())
	AudioService.play_sfx(fire_sound, world_pos)


func _play_impact(attacker_facing: FaceDirection.Values, defender: Node2D, play_fx_func: Callable) -> void:
	for i in burst_count:
		spawn_bullet_impact(attacker_facing, defender, play_fx_func)
		await defender.get_tree().create_timer(burst_interval).timeout


func spawn_bullet_impact(attacker_facing: FaceDirection.Values, defender: Node2D, play_fx_func: Callable):
	# Anchor around attacker, biased toward target
	var dir: Vector2 = Vector2(-1, 0)
	var base_pos: Vector2 = defender.global_position
	base_pos.x -= Const.CELL_SIZE.x / 2.0 / 2.0

	if attacker_facing == FaceDirection.Values.LEFT:
		base_pos.x += Const.CELL_SIZE.x / 2.0
		dir = Vector2(1, 0)

	var offset: Vector2 = Vector2(
		randf_range(-spread_radius, spread_radius),
		randf_range(-spread_radius, spread_radius)
	)
	
	var world_pos: Vector2 = base_pos+offset
	play_fx_func.call(hit_scene, world_pos, dir.angle())
	AudioService.play_sfx(hit_sound, world_pos)
