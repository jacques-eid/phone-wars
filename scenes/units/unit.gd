class_name Unit
extends Area2D

signal unit_moved()
signal unit_killed(unit: Unit)

@export var speed: float = 100.0
@export var unit_profile: UnitProfile = null
@export var team: Team

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_muzzle: Marker2D = $WeaponMuzzle
@onready var hp_label_component: HPLabelComponent = $HPLabelComponent

@onready var capturing_component_scene: PackedScene = preload("res://scenes/component/capturing_component.tscn")
@onready var death_scene: PackedScene = preload("res://scenes/vfx/explosion.tscn")
@onready var death_sound: AudioStream = preload("res://assets/sounds/units/sfx_die3.wav")

var cell_pos: Vector2i = Vector2i.ZERO
var reachable_cells: Array[Vector2i]
var exhausted: bool = false
var capture_process: CaptureProcess
var actual_health: float = 0.0
var movement_points: int

var capturing_component: CapturingComponent

var facing: FaceDirection.Values

var fsm: StateMachine
var idle_state: UnitIdleState
var moving_state: UnitMovingState
var selected_state: UnitSelectedState
var done_state: UnitDoneState


func _ready() -> void:
	# Make the material unique to this instance
	animated_sprite.material = animated_sprite.material.duplicate()
	z_index = Ordering.UNITS


func _process(delta: float) -> void:
	fsm._process(delta)


func _physics_process(delta: float) -> void:
	fsm._physics_process(delta)


func setup() -> void:
	set_team(team)
	gain_health(max_health())
	reset_movement_points()
	
	if unit_profile.capture_capacity > 0:
		set_capture_component()
	
	idle_state = UnitIdleState.new("unit_idle", self)
	moving_state = UnitMovingState.new("unit_moving", self)
	selected_state = UnitSelectedState.new("unit_selected", self)
	done_state = UnitDoneState.new("unit_done", self)

	fsm = StateMachine.new(name, idle_state)


func set_team(p_team: Team) -> void:
	team = p_team
	facing = team.face_direction
	team.replace_unit_colors(animated_sprite.material)


func set_capture_component() -> void:
	var bottom_left: Vector2 = Vector2(0, Const.CELL_SIZE.y)
	capturing_component = capturing_component_scene.instantiate()
	var size: Vector2 = capturing_component.texture.get_size()
	var offset: Vector2 = Vector2(bottom_left.x - size.x / 2.0 + 1.0, bottom_left.y - size.y - 1.0)

	capturing_component.position = offset
	capturing_component.setup(team)
	add_child(capturing_component)


func select() -> void:
	fsm.change_state(selected_state)


func deselect() -> void:
	fsm.change_state(idle_state)


func exhaust() -> void:
	fsm.change_state(done_state)


func ready_to_move() -> void:
	fsm.change_state(idle_state)
	

func idling() -> void:
	animated_sprite.play("idle")
	animated_sprite.flip_h = facing == FaceDirection.Values.RIGHT


func move_following_path(p: Array[Vector2]) -> void:
	if p.is_empty():
		return

	print("Unit moving along path: %s" % str(p))

	fsm.change_state(moving_state, {"path": p})


func reset_movement_points() -> void:
	movement_points = max_movement_points()


func get_terrain_cost(terrain: TerrainType.Values) -> float:
	return unit_profile.movement_profile.get_cost(terrain)


func is_max_health() -> bool:
	return actual_health >= max_health()


func can_capture_building(building: Building) -> bool:
	if building.cell_pos != cell_pos:
		return false

	if team.is_same_team(building.team):
		return false

	return unit_profile.capture_capacity > 0


func capture_capacity() -> int:
	var ratio: float = actual_health / max_health()
	return round(ratio*unit_profile.capture_capacity)


func start_capture(building: Building) -> void:
	if capture_process != null:
		return

	capture_process = CaptureProcess.new(building, self)


func capture() -> CaptureProcess.CaptureResult:
	return capture_process.resolve()
	

func stop_capture() -> void:
	if capture_process == null:
		return

	capture_process.clear_capture()
	capture_process = null


func can_merge_with_unit(unit: Unit) -> bool:
	# not the same team
	if not team.is_same_team(unit.team):
		return false

	# not the same type
	if unit.type() != type():
		return false

	# one of them is full hp
	if unit.is_max_health() or is_max_health():
		return false

	return true


func gain_health(gain: float) -> void:
	actual_health += gain
	actual_health = min(actual_health, max_health())
	hp_label_component.update(actual_health)


func take_dmg(dmg: float) -> void:
	actual_health -= dmg
	print("dmg taken %s / health left %s" %[dmg, actual_health])
	hp_label_component.update(actual_health)


func die(audio_service: AudioService) -> void:
	stop_capture()
	animated_sprite.visible = false

	var explosion: Explosion = death_scene.instantiate()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
	audio_service.play_sfx(death_sound, global_position)

	await explosion.finished

	unit_killed.emit(self)


func attack(defender: Unit, fx_service: FXService, audio_service: AudioService) -> void:
	if defender.global_position.x < global_position.x:
		facing = FaceDirection.Values.LEFT
	elif defender.global_position.x < global_position.x:
		facing = FaceDirection.Values.RIGHT

	animated_sprite.flip_h = facing == FaceDirection.Values.RIGHT
	animation_player.play("attack")
	unit_profile.weapon._play_fire(self, weapon_muzzle.global_position, fx_service.play_world_fx, audio_service)

	await animation_player.animation_finished


func play_hit_reaction() -> void:
	var tween: Tween = create_tween()
	var pos: Vector2 = animated_sprite.position

	# shake
	tween.tween_property(animated_sprite, "position:x", animated_sprite.position.x + 4, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(animated_sprite, "position:x", animated_sprite.position.x - 4, 0.05)

	# blink
	tween.parallel().tween_property(animated_sprite, "modulate", Color(1,1,1,0.2), 0.05)
	tween.parallel().tween_property(animated_sprite, "modulate", Color.WHITE, 0.05)

	await tween.finished

	animated_sprite.position = pos



# Unit profile getters
func max_movement_points() -> int:
	return unit_profile.movement_points


func max_health() -> int:
	return unit_profile.health


func cost() -> int:
	return unit_profile.cost


func icon() -> Texture2D:
	return unit_profile.icon


func move_sound() -> AudioStream:
	return unit_profile.move_sound


func type() -> UnitType.Values:
	return unit_profile.type


func get_attack_dmg(defender_type: UnitType.Values) -> float:
	return unit_profile.attack_profile.get_attack_dmg(defender_type)


func get_defense_vs(attacker_type: UnitType.Values) -> float:
	return unit_profile.defense_profile.get_defense_vs(attacker_type)


func min_attack_range() -> int:
	return unit_profile.attack_profile.min_range


func max_attack_range() -> int:
	return unit_profile.attack_profile.max_range


func can_attack_after_movement() -> bool:
	return unit_profile.attack_profile.can_attack_after_movement


func weapon() -> Weapon:
	return unit_profile.weapon
