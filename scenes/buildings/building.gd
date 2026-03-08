class_name Building
extends Area2D

signal owner_changed()

@export var building_profile: BuildingProfile
@export var production_list: ProductionList
@export var team: Team

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var cell_pos: Vector2i = Vector2i.ZERO


func _ready() -> void:
	# Make the material unique to this instance
	animated_sprite.material = animated_sprite.material.duplicate()
	z_index = Ordering.BUILDINGS
	add_to_group("buildings")
	

func setup() -> void:
	set_team(team)


func set_team(p_team: Team) -> void:
	team = p_team
	team.replace_building_colors(animated_sprite.material)


func captured(new_team: Team) -> void:
	set_team(new_team)
	owner_changed.emit()


func can_be_selected() -> bool:
	return production_list != null


# Unit profile getters
func defense() -> int:
	return building_profile.building_defense


func icon() -> Texture2D:
	return building_profile.building_icon


func type() -> BuildingType.Values:
	return building_profile.type


func max_capture_points() -> int:
	return building_profile.capture_points


func income() -> int:
	return building_profile.building_income
