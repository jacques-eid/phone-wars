class_name InfoPopup
extends BasePopup

@onready var unit_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer
@onready var unit_type_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/UnitType
@onready var unit_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/UnitIcon
@onready var unit_hp_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/UnitHP
@onready var terrain_type_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/TerrainType
@onready var terrain_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/TerrainIcon
@onready var terrain_def_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/TerrainDef


func clear_unit_data() -> void:
	unit_container.hide()

	# await main panel container resize calculation
	await get_tree().process_frame


func with_unit(unit: Unit) -> void:
	unit_type_label.text = UnitType.get_name_from_type(unit.type())
	unit_hp_label.text = "%s" %int(unit.actual_health)
	update_unit_icon(unit)
	unit_container.show()
	
	# await main panel container resize calculation
	await get_tree().process_frame


func with_building(building: Building) -> void:
	print('building_type: ', building.type())
	terrain_type_label.text = BuildingType.get_name_from_type(building.type())
	terrain_icon.texture = building.icon().duplicate()
	terrain_def_label.text = "+%s" %building.defense()
	
	var shader_material: ShaderMaterial = terrain_icon.material as ShaderMaterial
	shader_material.shader = load("res://resources/shaders/team_tint.gdshader")
	building.team.replace_building_colors(terrain_icon.material)


func with_terrain(terrain_data: TerrainData) -> void:
	terrain_type_label.text = TerrainType.get_name_from_type(terrain_data.terrain_type)
	terrain_icon.texture = terrain_data.icon.duplicate()
	terrain_def_label.text = "+%s" %terrain_data.defense_bonus
	
	var shader_material: ShaderMaterial = terrain_icon.material as ShaderMaterial
	shader_material.shader = null


func update_unit_icon(unit: Unit) -> void:
	var image: Image = unit.icon().get_image()
	if unit.team.face_direction == FaceDirection.Values.RIGHT:
		image.flip_x() 
		
	unit.team.replace_unit_colors(unit_icon.material)
	unit_icon.texture = ImageTexture.create_from_image(image)

