class_name CombatPopup
extends BasePopup

@onready var attacker_damage_preview_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/AttackerDamagePreview
@onready var counter_damage_preview_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/CounterDamagePreview
@onready var defender_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DefenderIcon
@onready var defender_hp_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DefenderHP
@onready var terrain_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TerrainIcon
@onready var terrain_def_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TerrainDef


func with_estimated_damage(estimated_damage: float, counter_damage: float) -> void:
	attacker_damage_preview_label.text = "-%s %%" % (estimated_damage*10)
	counter_damage_preview_label.text = "-%s %%" % (counter_damage*10)


func with_unit(unit: Unit) -> void:
	defender_hp_label.text = "%s" %int(unit.actual_health)
	update_defender_icon(unit)


func with_building(building: Building) -> void:
	terrain_icon.texture = building.icon().duplicate()
	terrain_def_label.text = "+%s" %building.defense()

	var shader_material: ShaderMaterial = terrain_icon.material as ShaderMaterial
	shader_material.shader = load("res://resources/shaders/team_tint.gdshader")
	building.team.replace_building_colors(terrain_icon.material)


func with_terrain(terrain_data: TerrainData) -> void:
	terrain_icon.texture = terrain_data.icon.duplicate()
	terrain_def_label.text = "+%s" %terrain_data.defense_bonus

	var shader_material: ShaderMaterial = terrain_icon.material as ShaderMaterial
	shader_material.shader = null


func update_defender_icon(unit: Unit) -> void:
	var image: Image = unit.icon().get_image()
	if unit.team.face_direction == FaceDirection.Values.RIGHT:
		image.flip_x() 
		
	unit.team.replace_unit_colors(defender_icon.material)
	defender_icon.texture = ImageTexture.create_from_image(image)
