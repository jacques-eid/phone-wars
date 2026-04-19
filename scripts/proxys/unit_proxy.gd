class_name UnitProxy
extends Node2D


var weapon: Weapon
var facing: FaceDirection.Values
var animated_sprite: AnimatedSprite2D
var animation_player: AnimationPlayer
var weapon_muzzle: Marker2D

func _ready() -> void:
	position = Const.CELL_SIZE / 2.0


func load_from_unit(unit: Unit) -> void:
	animated_sprite = unit.animated_sprite.duplicate(true)
	animation_player = unit.animation_player.duplicate(true)
	weapon_muzzle = unit.weapon_muzzle.duplicate(true)
	facing = unit.facing
	weapon = unit.weapon.duplicate(true)
	
	add_child(animated_sprite)
	add_child(animation_player)
	add_child(weapon_muzzle)


func play_attack(fx_service: FXService) -> void:
	animated_sprite.flip_h = facing == FaceDirection.Values.RIGHT
	animation_player.play("attack")
	weapon._play_fire(self, weapon_muzzle.global_position, fx_service.play_ui_fx)

	await animation_player.animation_finished


func clear() -> void:
	remove_child(animated_sprite)
	remove_child(animation_player)
	remove_child(weapon_muzzle)