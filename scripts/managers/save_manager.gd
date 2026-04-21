extends Node


class UnitData:
	var type: UnitType.Values
	var hp: float
	var position: Vector2i
	var team_id: int
	var exhausted: bool
	var capture_progress: int

	func to_dict() -> Dictionary:
		return {
			"type": type,
			"hp": hp,
			"position": var_to_str(position),
			"team_id": team_id,
			"exhausted": exhausted,
			"capture_progress": capture_progress
		}

	static func from_dict(data: Dictionary) -> UnitData:
		var ud: UnitData = UnitData.new()
		ud.type = data["type"]
		ud.hp = data["hp"]
		ud.position = str_to_var(data["position"])
		ud.team_id = data["team_id"]
		ud.exhausted = data["exhausted"]
		ud.capture_progress = data["capture_progress"]

		return ud


class BuildingData:
	var position: Vector2i
	var team_id: int

	func to_dict() -> Dictionary:
		return {
			"position": var_to_str(position),
			"team_id": team_id
		}

	static func from_dict(data: Dictionary) -> BuildingData:
		var bd: BuildingData = BuildingData.new()
		print(data)
		bd.position = str_to_var(data["position"])
		bd.team_id = data["team_id"]

		return bd


class TeamData:
	var id: int
	var funds: int

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"funds": funds
		}

	static func from_dict(data: Dictionary) -> TeamData:
		var td: TeamData = TeamData.new()
		td.id = data["id"]
		td.funds = data["funds"]

		return td


var save_path: String = "user://save_game.json"
var pending_data: Dictionary


func save_exists() -> bool:
	return FileAccess.file_exists(SaveManager.save_path)


func save_game(level_manager: LevelManager) -> void:
	var data: Dictionary = {}

	data["units"] = save_units_data(level_manager.units_manager)
	data["buildings"] = save_buildings_data(level_manager.buildings_manager)
	data["teams"] = save_teams_data(level_manager.teams)
	data["active_team"] = level_manager.active_team.id
	data["level"] = level_manager.get_tree().current_scene.scene_file_path

	print("saving data:\n%s"%JSON.stringify(data))

	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))


func save_units_data(units_manager: UnitsManager) -> Array[Dictionary]:
	var data: Array[Dictionary] = []

	for unit: Unit in units_manager.units.values():
		var ud: UnitData = UnitData.new()
		ud.type = unit.type
		ud.hp = unit.actual_health
		ud.position = unit.cell
		ud.team_id = unit.team.id
		ud.exhausted = unit.exhausted
		ud.capture_progress = unit.capture_process.progress if unit.capture_process != null else 0
		data.append(ud.to_dict())

	return data


func save_buildings_data(buildings_manager: BuildingsManager) -> Array[Dictionary]:
	var data: Array[Dictionary]

	for building: Building in buildings_manager.buildings.values():
		var bd: BuildingData = BuildingData.new()
		bd.team_id = building.team.id
		bd.position = building.cell
		data.append(bd.to_dict())

	return data


func save_teams_data(teams: Array[Team]) -> Array[Dictionary]:
	var data: Array[Dictionary]

	for team: Team in teams:
		var td: TeamData = TeamData.new()
		td.id = team.id
		td.funds = team.funds
		data.append(td.to_dict())

	return data


func load_game() -> String:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	var content: String = file.get_as_text()
	pending_data = JSON.parse_string(content)

	return pending_data["level"]


func load_from_save(level_manager: LevelManager) -> void:
	load_teams(level_manager.teams, pending_data["teams"])
	load_buildings(level_manager.buildings_manager, level_manager.teams, pending_data["buildings"])
	load_units(level_manager.units_manager, level_manager.teams, level_manager.buildings_manager, pending_data["units"])
	load_active_team(level_manager, pending_data["active_team"])

	pending_data.clear()


func load_active_team(level_manager: LevelManager, active_team_id: int) -> void:
	var idx: int = level_manager.teams.find_custom(func(t: Team): return t.id == active_team_id)
	if idx == -1:
		push_error("team id [%s] not found"%active_team_id)
		return

	level_manager.active_team = level_manager.teams[idx]



func load_teams(teams: Array[Team], teams_data: Array) -> void:
	for team_data: Dictionary in teams_data:
		var td: TeamData = TeamData.from_dict(team_data)
		var idx: int = teams.find_custom(func(t: Team): return t.id == td.id)
		if idx == -1:
			push_error("team id [%s] not found"%td.id)
			continue

		var team: Team = teams[idx]
		team.funds = td.funds


func load_buildings(
	buildings_manager: BuildingsManager,
	teams: Array[Team],
	buildings_data: Array) -> void:
	for building_data: Dictionary in buildings_data:
		var bd: BuildingData = BuildingData.from_dict(building_data)
		var building: Building = buildings_manager.get_building_at(bd.position)
		if building == null:
			push_error("building not found at position [%s]"%bd.position)
			continue

		var idx: int = teams.find_custom(func(t: Team): return t.id == bd.team_id)
		if idx == -1:
			push_error("team id [%s] not found"%bd.team_id)
			continue
			
		building.set_team(teams[idx])



func load_units(units_manager: UnitsManager, teams: Array[Team], buildings_manager: BuildingsManager, units_data: Array) -> void:
	units_manager.clear_units()

	for unit_data: Dictionary in units_data:
		var ud: UnitData = UnitData.from_dict(unit_data)

		var idx: int = teams.find_custom(func(t: Team): return t.id == ud.team_id)
		if idx == -1:
			push_error("team id [%s] not found"%ud.team_id)
			continue

		var unit: Unit = units_manager.add_unit(ud.type, ud.position, teams[idx])
		unit.take_dmg(unit.max_health() - ud.hp)

		if not ud.exhausted:
			unit.ready_to_move()

		if ud.capture_progress > 0:
			var building: Building = buildings_manager.get_building_at(ud.position)
			if building == null:
				push_error("building not found at position [%s]"%ud.position)
				continue

			unit.start_capture(building)
			unit.capture_process.progress = ud.capture_progress
		
