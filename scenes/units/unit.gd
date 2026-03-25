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

var cell: Vector2i = Vector2i.ZERO
var reachable_cells: Array[Vector2i]
var exhausted: bool = false
var capture_process: CaptureProcess
var actual_health: float = 0.0
var movement_points: int

var capturing_component: CapturingComponent

var facing: FaceDirection.Values

var state_machine: LimboHSM
var idle_state: UnitIdleState
var moving_state: UnitMovingState
var selected_state: UnitSelectedState
var done_state: UnitDoneState

const SELECTED_SIGNAL: String = "selected"
const DESELECTED_SIGNAL: String = "deselected"
const MOVE_SIGNAL: String = "move"
const EXHAUSTED_SIGNAL: String = "exhausted"
const RESET_SIGNAL: String = "reset"


func _ready() -> void:
	# Make the material unique to this instance
	animated_sprite.material = animated_sprite.material.duplicate()
	z_index = Ordering.UNITS


func setup() -> void:
	set_team(team)
	gain_health(max_health())
	reset_movement_points()
	
	if unit_profile.capture_capacity > 0:
		set_capture_component()
	
	init_state_machine()


func init_state_machine() -> void:
	idle_state = UnitIdleState.new()
	moving_state = UnitMovingState.new()
	selected_state = UnitSelectedState.new()
	done_state = UnitDoneState.new()

	state_machine = LimboHSM.new()
	add_child(state_machine)
	state_machine.add_child(idle_state)
	state_machine.add_child(moving_state)
	state_machine.add_child(selected_state)
	state_machine.add_child(done_state)

	state_machine.add_transition(idle_state, selected_state, SELECTED_SIGNAL)
	state_machine.add_transition(selected_state, idle_state, DESELECTED_SIGNAL)
	state_machine.add_transition(selected_state, moving_state, MOVE_SIGNAL)
	state_machine.add_transition(moving_state, selected_state, moving_state.EVENT_FINISHED)
	state_machine.add_transition(state_machine.ANYSTATE, done_state, EXHAUSTED_SIGNAL)
	state_machine.add_transition(done_state, idle_state, RESET_SIGNAL)

	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)



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
	state_machine.dispatch(SELECTED_SIGNAL)


func deselect() -> void:
	state_machine.dispatch(DESELECTED_SIGNAL)


func exhaust() -> void:
	state_machine.dispatch(EXHAUSTED_SIGNAL)


func ready_to_move() -> void:
	state_machine.dispatch(RESET_SIGNAL)
	

func idling() -> void:
	animated_sprite.play("idle")
	animated_sprite.flip_h = facing == FaceDirection.Values.RIGHT


func move_following_path(p: Array[Vector2]) -> void:
	if p.is_empty():
		return

	print("Unit %s moving along path: %s" % [self.name, str(p)])

	moving_state.path = p
	state_machine.dispatch(MOVE_SIGNAL)


func reset_movement_points() -> void:
	movement_points = max_movement_points()


func get_terrain_cost(terrain: TerrainType.Values) -> float:
	return unit_profile.movement_profile.get_cost(terrain)


func is_max_health() -> bool:
	return actual_health >= max_health()


func is_low_health() -> bool:
	return actual_health <= max_health() / 5.0


func can_capture_building(building: Building) -> bool:
	if building.cell != cell:
		return false

	if team.is_same_team(building.team):
		return false

	return can_capture()


func capture_capacity() -> int:
	var ratio: float = actual_health / max_health()
	return round(ratio*unit_profile.capture_capacity)


func start_capture(building: Building) -> void:
	if capture_process != null:
		return

	capture_process = CaptureProcess.new(building, self)


func capture() -> CaptureResult:
	return capture_process.resolve(self)
	

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


func die() -> void:
	stop_capture()
	unit_killed.emit(self)


func attack(defender: Unit, fx_service: FXService) -> void:
	if defender.global_position.x < global_position.x:
		facing = FaceDirection.Values.LEFT
	elif defender.global_position.x < global_position.x:
		facing = FaceDirection.Values.RIGHT

	animated_sprite.flip_h = facing == FaceDirection.Values.RIGHT
	animation_player.play("attack")
	unit_profile.weapon._play_fire(self, weapon_muzzle.global_position, fx_service.play_world_fx)

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


func play_death() -> void:
	visible = false

	var explosion: Explosion = death_scene.instantiate()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
	AudioService.play_sfx(death_sound, global_position)

	await explosion.finished

# Unit profile getters
func max_movement_points() -> int:
	return unit_profile.movement_points


func max_health() -> int:
	return unit_profile.health


func cost() -> int:
	return unit_profile.cost


func can_capture() -> bool:
	return unit_profile.capture_capacity > 0


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
	return not unit_profile.attack_profile.is_range


func is_range() -> bool:
	return unit_profile.attack_profile.is_range


func weapon() -> Weapon:
	return unit_profile.weapon
