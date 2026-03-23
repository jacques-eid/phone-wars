class_name Team
extends Node

enum Type {
	PLAYABLE,
	AI,
	NEUTRAL,
}

@export var team_id: int = 1
@export var team_profile: TeamProfile
@export var team_type: Type = Type.NEUTRAL
@export var face_direction: FaceDirection.Values = FaceDirection.Values.LEFT
@export var funds: int = 1500

@export var controller: TeamController


func setup(
	units_manager: UnitsManager,
	buildings_manager: BuildingsManager,
	terrain_manager: TerrainManager) -> void:
	
	match team_type:
		Type.PLAYABLE:
			controller = HumanController.new(self, units_manager, buildings_manager, terrain_manager)
			add_child(controller)
			controller._setup()	
		Type.AI:
			controller = AIController.new(self, units_manager, buildings_manager, terrain_manager)
			add_child(controller)	
			controller._setup()
		

func end_turn() -> void:
	controller._end_turn()


func is_playable() -> bool:
	return team_type == Type.PLAYABLE


func neutral_team() -> bool:
	return team_type == Type.NEUTRAL


func is_same_team(team: Team) -> bool:
	return self == team


func can_buy(entry: ProductionEntry) -> bool:
	return entry.cost() <= funds
	


# Team profile getters
func replace_unit_colors(material: ShaderMaterial) -> void:
	if team_profile.unit_colors == null:
		return
	team_profile.unit_colors.replace_colors(material)

	
func replace_building_colors(material: ShaderMaterial) -> void:
	if team_profile.building_colors == null:
		return
	team_profile.building_colors.replace_colors(material)

	
func replace_ui_colors(material: ShaderMaterial) -> void:
	if team_profile.ui_colors == null:
		return
	team_profile.ui_colors.replace_colors(material)
	

func team_name() -> String:
	return team_profile.team_name