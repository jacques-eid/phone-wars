class_name LevelManager
extends Node2D


@onready var main_menu_scene: PackedScene = preload("res://scenes/main_menu/main_menu.tscn")


@onready var grid: Grid = $Grid
@onready var ui_controller: UIController = $UIController
@onready var camera_controller: CameraController = $CameraController
@onready var terrain_manager: TerrainManager = $Terrain
@onready var indicators: Indicators = $Indicators
@onready var units_manager: UnitsManager = $Managers/UnitsManager
@onready var buildings_manager: BuildingsManager = $Managers/BuildingsManager
@onready var input_manager: InputManager = $Managers/InputManager
@onready var music_manager: MusicManager = $Managers/MusicManager
@onready var fx_service: FXService = $Services/FXService
@onready var music_service: MusicService = $Services/MusicService
@onready var economy_service: EconomyService = $Services/EconomyService


var teams: Array[Team] = []
var active_team: Team

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_controller.setup(self)
	grid.setup(input_manager, units_manager, terrain_manager)
	camera_controller.setup(ui_controller, input_manager, terrain_manager)
	indicators.setup(grid, ui_controller)
	fx_service.setup_ui(ui_controller.ui_fx_layer)
	music_manager.setup(music_service)
	units_manager.setup(grid)
	buildings_manager.setup()

	init_teams()

	ui_controller.game_paused.connect(_on_game_paused)
	ui_controller.game_resumed.connect(_on_game_resumed)
	ui_controller.exit_level.connect(_on_exit_level)

	call_deferred("connect_buildings")
	

func init_teams() -> void:
	for child in get_node("Teams").get_children():
		var team: Team = child as Team 
		if team != null:
			teams.append(team)
			team.setup(units_manager, buildings_manager, grid.terrain_manager)
			print("team added: %s" % team.name)
			if team.controller != null:
				team.controller.turn_end.connect(_on_turn_ended)
				team.controller.focus_on.connect(_on_focus_on)

	active_team = teams[0]
	start_turn()
	

func start_turn() -> void:
	ui_controller.switch_team(active_team)
	var new_income: int = economy_service.calculate_income(buildings_manager, active_team)

	ui_controller.lock()
	input_manager.lock()
	await ui_controller.show_start_turn_intro(active_team, active_team.funds+new_income)
	
	economy_service.add_money(active_team, new_income)
	
	await active_team.controller.focus(active_team.controller.get_default_focus_point())
	ui_controller.unlock()
	input_manager.unlock()

	active_team.controller._play_turn()


func _on_focus_on(controller: TeamController, focus_point: Vector2) -> void:
	await camera_controller.focus_on(focus_point)
	controller.focused_on.emit()


func _on_turn_ended() -> void:
	active_team = next_team(active_team)

	print("Turn ended. New team %s to play" % active_team.name)
	start_turn()


func _on_game_paused() -> void:
	input_manager.lock()


func _on_game_resumed() -> void:
	input_manager.unlock()


func next_team(current_team: Team) -> Team:
	var active_team_idx :int = teams.find(current_team, 0)
	active_team_idx +=1
	if active_team_idx >= teams.size():
		active_team_idx = 0

	var team: Team = teams.get(active_team_idx)
	if team.neutral_team():
		return next_team(team)
	
	return team


func connect_buildings() -> void:
	var buildings: Array[Node] = get_tree().get_nodes_in_group("buildings")

	for building: Building in buildings:
		building.owner_changed.connect(building_owner_changed)


func building_owner_changed() -> void:
	for team: Team in teams:
		if buildings_manager.get_hq_count(team) == 0:
			_on_exit_level()


func _on_exit_level() -> void:
	pass#get_tree().change_scene_to_packed(main_menu_scene)
